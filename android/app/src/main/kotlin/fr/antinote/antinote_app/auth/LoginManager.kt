package fr.antinote.antinote_app.auth

import android.accounts.Account
import android.accounts.AccountManager
import android.accounts.AccountManager.KEY_ACCOUNT_NAME
import android.accounts.AccountManager.KEY_ACCOUNT_TYPE
import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.CalendarContract
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Log
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.datastore.core.CorruptionException
import androidx.datastore.core.DataStore
import androidx.datastore.core.MultiProcessDataStoreFactory
import androidx.datastore.core.Serializer
import androidx.datastore.core.handlers.ReplaceFileCorruptionHandler
import androidx.fragment.app.FragmentActivity
import com.google.protobuf.Any
import com.google.protobuf.ByteString
import com.google.protobuf.InvalidProtocolBufferException
import com.google.protobuf.kotlin.toByteString
import fr.antinote.antinote_app.R
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import fr.antinote.antinote_app.protos.AccountRegistry
import fr.antinote.antinote_app.protos.AntinoteAccount
import fr.antinote.antinote_app.protos.EncryptedCredentials
import fr.antinote.antinote_app.protos.copy
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import kotlin.io.encoding.Base64

object AccountStoreSerializer : Serializer<AccountRegistry> {
    override val defaultValue: AccountRegistry = AccountRegistry.getDefaultInstance()

    override suspend fun readFrom(input: InputStream): AccountRegistry {
        try {
            return AccountRegistry.parseFrom(input)
        } catch (exception: InvalidProtocolBufferException) {
            throw CorruptionException("Cannot read proto.", exception)
        }
    }

    override suspend fun writeTo(t: AccountRegistry, output: OutputStream) {
        return t.writeTo(output)
    }
}

@Volatile
private var ACCOUNT_STORE_INSTANCE: DataStore<AccountRegistry>? = null

val Context.accountStore: DataStore<AccountRegistry>
    get() = ACCOUNT_STORE_INSTANCE ?: synchronized(this) {
        ACCOUNT_STORE_INSTANCE ?: MultiProcessDataStoreFactory.create(
            serializer = AccountStoreSerializer,
            corruptionHandler = ReplaceFileCorruptionHandler {
                Log.e("AccountRegistry", "Could not read accounts, recreating...", it)

                AccountRegistry.getDefaultInstance()
            },
        ) {
            File(filesDir, "session.pb")
        }.also { ACCOUNT_STORE_INSTANCE = it }
    }

class LoginManager(val context: Context, val activity: FragmentActivity?) : NativeLoginManager {
    companion object {
        private const val TAG = "LoginManager"
        const val KEY_UID = "uid"
        private const val AUTHENTICATORS =
            BiometricManager.Authenticators.BIOMETRIC_WEAK or BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.DEVICE_CREDENTIAL
        private const val CIPHER =
            "${KeyProperties.KEY_ALGORITHM_AES}/${KeyProperties.BLOCK_MODE_GCM}/${KeyProperties.ENCRYPTION_PADDING_PKCS7}"

        fun accountKeyAlias(uid: String): String = "TOKEN / $uid"

        fun accountForUid(context: Context, accountKey: String): Account {
            val am = AccountManager.get(context)
            return am.getAccountsByType(context.getString(R.string.account_type))
                .first { am.getUserData(it, KEY_UID) == accountKey }
        }
    }

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    val dekStore: MutableMap<String, SecretKey> = mutableMapOf()

    suspend fun encryptCredentials(
        uid: String,
        data: ByteArray,
        oldCredentials: EncryptedCredentials?
    ): EncryptedCredentials? {
        var dek = dekStore[uid]
        val hadDek = dek != null && oldCredentials != null

        if (hadDek) {
            dekStore.remove(uid)
        } else {
            val keyGen = KeyGenerator.getInstance("AES")
            keyGen.init(256)
            dek = keyGen.generateKey()
        }

        val cipher = Cipher.getInstance(
            CIPHER
        )
        cipher.init(Cipher.ENCRYPT_MODE, dek)
        val ciphertext = cipher.doFinal(data)


        val encryptedDek: ByteString
        val dekIv: ByteString

        if (hadDek) {
            encryptedDek = oldCredentials.dekData
            dekIv = oldCredentials.dekIv
        } else {
            val hwKey = getOrCreateSecretKey(accountKeyAlias(uid))
            val hwCipher = Cipher.getInstance(CIPHER)
            hwCipher.init(Cipher.ENCRYPT_MODE, hwKey)

            if (!getStoreKeyForAccount(hwCipher)) return null

            encryptedDek = hwCipher.doFinal(dek.encoded).toByteString()
            dekIv = hwCipher.iv.toByteString()
        }

        return EncryptedCredentials.newBuilder().run {
            setCredentialData(ciphertext.toByteString())
            setCredentialIv(cipher.iv.toByteString())

            setDekData(encryptedDek)
            setDekIv(dekIv)

            build()
        }
    }

    suspend fun decryptCredentials(
        uid: String,
        credentials: EncryptedCredentials
    ): ByteArray? {
        val hwKey = getOrCreateSecretKey(accountKeyAlias(uid))
        val hwCipher = Cipher.getInstance(
            CIPHER
        )
        hwCipher.init(
            Cipher.DECRYPT_MODE, hwKey, GCMParameterSpec(
                128,
                credentials.dekIv.toByteArray()
            )
        )

        if (!getStoreKeyForAccount(hwCipher)) {
            return null
        }

        val dekBytes = hwCipher.doFinal(credentials.dekData.toByteArray())
        val dek = SecretKeySpec(dekBytes, "AES")
        dekStore[uid] = dek

        val dataCipher = Cipher.getInstance(CIPHER)
        dataCipher.init(
            Cipher.DECRYPT_MODE,
            dek,
            GCMParameterSpec(128, credentials.credentialIv.toByteArray())
        )

        return dataCipher.doFinal(credentials.dekData.toByteArray())
    }

    private suspend fun getStoreKeyForAccount(
        cipher: Cipher
    ): Boolean {
        if (activity == null) throw IllegalStateException("Tried to authenticate user although login manager not attached to an activity")

        val cryptoObject = BiometricPrompt.CryptoObject(cipher)

        return withContext(Dispatchers.Main) {
            suspendCancellableCoroutine { continuation ->
                val promptInfo = BiometricPrompt.PromptInfo.Builder().apply {
                    setTitle(context.getString(R.string.biometric_prompt_title))
                    setSubtitle(context.getString(R.string.biometric_prompt_subtitle))
                    setDescription(context.getString(R.string.biometric_prompt_description))

                    // Since we enable device credentials, we do not need to define this.
                    // setNegativeButtonText(context.getString(R.string.biometric_prompt_cancel))

                    setConfirmationRequired(false)
                    setAllowedAuthenticators(AUTHENTICATORS)
                }.build()

                val executor = ContextCompat.getMainExecutor(context)

                val prompt = BiometricPrompt(
                    activity,
                    executor,
                    object : BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                            if (continuation.isActive) continuation.resume(true) { _, _, _ ->
                            }
                        }

                        override fun onAuthenticationError(
                            errorCode: Int,
                            errString: CharSequence
                        ) {
                            if (continuation.isActive) continuation.resume(false) { _, _, _ ->
                            }
                        }

                        override fun onAuthenticationFailed() {}
                    })

                continuation.invokeOnCancellation {
                    prompt.cancelAuthentication()
                }

                prompt.authenticate(promptInfo, cryptoObject)
            }
        }
    }

    private fun getOrCreateSecretKey(alias: String): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

        if (keyStore.containsAlias(alias)) {
            return (keyStore.getEntry(alias, null) as KeyStore.SecretKeyEntry).secretKey
        }

        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore"
        )

        val builder = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        ).apply {
            setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            setUserAuthenticationRequired(true)
            setInvalidatedByBiometricEnrollment(true)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                setUserAuthenticationParameters(
                    0,
                    KeyProperties.AUTH_BIOMETRIC_STRONG or KeyProperties.AUTH_DEVICE_CREDENTIAL
                )
            }
        }

        keyGenerator.init(builder.build())
        return keyGenerator.generateKey()
    }

    override fun addAccount(rawAccount: ByteArray, callback: (Result<Boolean>) -> Unit) {
        scope.launch {
            val account = AntinoteAccount.parseFrom(rawAccount)

            val credentials: Any? = if (account.storeSecurely) {
                encryptCredentials(account.uid, account.tokenCredentials.toByteArray(), null)?.run {
                    Any.parseFrom(toByteArray())
                }
            } else {
                account.tokenCredentials
            }

            if (credentials == null) {
                callback(Result.success(false))
                return@launch
            }

            val manager = AccountManager.get(context)

            Log.i(TAG, "In total, there are ${manager.accounts.size} accounts")
            for (account in manager.getAccountsByType(context.getString(R.string.account_type))) {
                Log.d(
                    TAG,
                    "-> '${account.name}:${account.type}' (${
                        manager.getUserData(
                            account,
                            KEY_UID
                        )
                    })"
                )
            }

            val nativeAccount = Account(account.name, context.getString(R.string.account_type))
            val nativeResult = manager.addAccountExplicitly(
                nativeAccount,
                Base64.encode(account.tokenCredentials!!.toByteArray()),
                Bundle().apply {
                    putString(KEY_UID, account.uid)
                }
            )

            if (!nativeResult) {
                Log.e(TAG, "Account already exists...")

                if (activity is AuthActivity) {
                    activity.setResult(Activity.RESULT_CANCELED)
                    activity.finish()
                }

                callback(Result.success(false))
                return@launch
            }

            context.accountStore.updateData {
                it.copy {
                    accounts.add(account.copy {
                        tokenCredentials = credentials
                    })
                }
            }

            ContentResolver.setSyncAutomatically(nativeAccount, CalendarContract.AUTHORITY, false)

            Log.d(TAG, "Added account to manager with UID ${account.uid}")

            if (activity is AuthActivity) {
                val resultIntent = Intent().apply {
                    putExtra(KEY_ACCOUNT_NAME, account.name)
                    putExtra(
                        KEY_ACCOUNT_TYPE,
                        context.getString(R.string.account_type)
                    )
                }

                activity.setAccountAuthenticatorResult(resultIntent.extras)
                activity.setResult(Activity.RESULT_OK, resultIntent)
                activity.finish()
            }

            callback(Result.success(true))
        }
    }

    private suspend fun deleteAccounts(accountList: List<String>? = null) {
        val manager = AccountManager.get(context)

        for (account in manager.getAccountsByType(context.getString(R.string.account_type))) {
            if (accountList != null && !accountList.contains(
                    manager.getUserData(
                        account,
                        KEY_UID
                    )
                )
            ) {
                continue
            }

            if (account.type == context.getString(R.string.account_type)
            ) {
                manager.removeAccountExplicitly(account)
            }
        }

        context.accountStore.updateData { registry ->
            registry.copy {
                val toKeep = mutableListOf<AntinoteAccount>()
                val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                for (account in accounts) {
                    if (accountList != null && !accountList.contains(account.uid)) {
                        toKeep.add(account)
                        continue
                    }

                    if (account.storeSecurely) {
                        val alias = accountKeyAlias(account.uid)
                        if (keyStore.isKeyEntry(alias)) {
                            keyStore.deleteEntry(alias)
                        }
                    }
                }

                accounts.clear()
                accounts.addAll(toKeep)
            }
        }
    }

    override fun deleteAccount(uid: String, callback: (Result<Unit>) -> Unit) {
        scope.launch {
            deleteAccounts(listOf(uid))
            callback(Result.success(Unit))
        }
    }

    override fun deleteAllAccounts(callback: (Result<Unit>) -> Unit) {
        scope.launch {
            deleteAccounts(null)
            callback(Result.success(Unit))
        }
    }

    override fun updateAccount(
        newRawAccount: ByteArray,
        uid: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        scope.launch {
            val newAccount = AntinoteAccount.parseFrom(newRawAccount)

            context.accountStore.updateData { registry ->
                registry.copy {
                    val accIndex = accounts.indexOfFirst { it.uid == uid }
                    if (accIndex == -1) {
                        callback(Result.failure(IllegalStateException("Tried to update an account that does not exist")))
                        return@updateData registry
                    }

                        val oldAccount = accounts[accIndex]
                        accounts[accIndex] = newAccount.copy {
                            if (hasTokenCredentials() && newAccount.storeSecurely) {
                                val newCredentials = encryptCredentials(
                                    uid, newAccount.tokenCredentials.toByteArray(),
                                    if (oldAccount.storeSecurely) {
                                        EncryptedCredentials.parseFrom(oldAccount.tokenCredentials.toByteArray())
                                    } else null
                                )

                                if (newCredentials == null) {
                                    callback(Result.success(false))
                                    return@updateData registry
                                }

                                tokenCredentials = Any.parseFrom(newCredentials.toByteArray())
                            }
                        }

                    callback(Result.success(true))

                }
            }
        }
    }

    override fun listAccounts(callback: (Result<List<ByteArray>>) -> Unit) {
        scope.launch {
            val manager = AccountManager.get(context)
            val nativeAccountUids =
                manager.getAccountsByType(context.getString(R.string.account_type))
                    .map { manager.getUserData(it, KEY_UID) }

            val accountIdsToDelete = mutableListOf<String>()
            val rawAccounts = mutableListOf<ByteArray>()

            for (account in context.accountStore.data.first().accountsList) {
                if (!nativeAccountUids.contains(account.uid)) {
                    accountIdsToDelete.add(account.uid)
                    continue
                }

                rawAccounts.add(account.toByteArray())
            }

            deleteAccounts(accountIdsToDelete)

            callback(Result.success(rawAccounts))
        }
    }

    override fun getAccountWithCredentials(uid: String, callback: (Result<ByteArray?>) -> Unit) {
        scope.launch {
            val account =
                context.accountStore.data.first().accountsList.firstOrNull { it.uid == uid }

            if (account == null) {
                callback(Result.success(null))
                return@launch
            }

            if (!account.storeSecurely) {
                callback(Result.success(account.toByteArray()))
                return@launch
            }

            val decrypted = decryptCredentials(
                uid,
                EncryptedCredentials.parseFrom(account.tokenCredentials.toByteArray())
            )

            if (decrypted == null) {
                callback(Result.success(null))
                return@launch
            }

            callback(
                Result.success(
                    account.copy {
                        tokenCredentials = Any.parseFrom(decrypted.toByteString())
                    }.toByteArray()
                )
            )
        }
    }

    override fun getDefaultAccount(callback: (Result<ByteArray?>) -> Unit) {
        scope.launch {
            val registry = context.accountStore.data.first()

            if (registry.defaultAccountId == null) {
                callback(Result.success(null))
                return@launch
            }

            val account = registry.accountsList.firstOrNull { it.uid == registry.defaultAccountId }

            if (account == null) {
                callback(Result.success(null))
                return@launch
            }

            callback(Result.success(account.toByteArray()))

        }
    }

    override fun setDefaultAccount(uid: String?, callback: (Result<Unit>) -> Unit) {
        scope.launch {
            context.accountStore.updateData { registry ->
                registry.copy {
                    if (uid == null) {
                        clearDefaultAccountId()
                    } else {
                        defaultAccountId = uid
                    }
                }
            }

            callback(Result.success(Unit))
        }
    }
}