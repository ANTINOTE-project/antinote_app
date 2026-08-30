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
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.asFlow
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.Operation
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.workDataOf
import com.google.protobuf.Any
import com.google.protobuf.ByteString
import com.google.protobuf.kotlin.toByteString
import fr.antinote.antinote_app.App
import fr.antinote.antinote_app.R
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import fr.antinote.antinote_app.protos.AntinoteAccount
import fr.antinote.antinote_app.protos.EncryptedCredentials
import fr.antinote.antinote_app.protos.copy
import fr.antinote.antinote_app.sync.SyncWorker
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.dropWhile
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.security.KeyStore
import java.util.concurrent.ConcurrentHashMap
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

class LoginManager(val context: Context, val activity: FragmentActivity?) : NativeLoginManager {
    companion object {
        private const val TAG = "LoginManager"
        const val KEY_UID = "uid"
        private const val AUTHENTICATORS =
            BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.DEVICE_CREDENTIAL
        private const val CIPHER =
            "${KeyProperties.KEY_ALGORITHM_AES}/${KeyProperties.BLOCK_MODE_GCM}/${KeyProperties.ENCRYPTION_PADDING_NONE}"

        private const val TYPE_PREFIX = "type.antinote.fr"

        private const val FORCE_SYNC_WORK_ID = "manual-"

        fun accountKeyAlias(uid: String): String = "TOKEN / $uid"

        fun accountForUid(context: Context, accountKey: String): Account {
            val am = AccountManager.get(context)
            return am.getAccountsByType(context.getString(R.string.account_type))
                .first { am.getUserData(it, KEY_UID) == accountKey }
        }
    }

    val dekStore: MutableMap<String, SecretKey> = ConcurrentHashMap()

    suspend fun encryptCredentials(
        uid: String,
        data: Any,
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
        val iv = cipher.iv.toByteString()
        val ciphertext = cipher.doFinal(data.toByteArray()).toByteString()

        val encryptedDek: ByteString
        val dekIv: ByteString

        if (hadDek) {
            encryptedDek = oldCredentials.dekData
            dekIv = oldCredentials.dekIv
        } else {
            val hwKey = getOrCreateSecretKey(accountKeyAlias(uid))
            cipher.init(Cipher.ENCRYPT_MODE, hwKey)

            if (!getStoreKeyForAccount(cipher)) return null

            dekIv = cipher.iv.toByteString()
            encryptedDek = cipher.doFinal(dek.encoded).toByteString()
        }

        return EncryptedCredentials.newBuilder().run {
            setCredentialData(ciphertext)
            setCredentialIv(iv)

            setDekData(encryptedDek)
            setDekIv(dekIv)

            build()
        }
    }

    suspend fun decryptCredentials(
        uid: String,
        credentials: EncryptedCredentials
    ): Any? {
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

        return Any.parseFrom(dataCipher.doFinal(credentials.credentialData.toByteArray()))
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

    override suspend fun addAccount(rawAccount: ByteArray): Boolean {
        val app = context.applicationContext as App

        val account = AntinoteAccount.parseFrom(rawAccount)

        val credentials: Any? = if (account.storeSecurely) {
            encryptCredentials(account.uid, account.tokenCredentials, null)?.run {
                Any.newBuilder().run {
                    setTypeUrl("$TYPE_PREFIX/${javaClass.name}")
                    setValue(toByteString())
                    build()
                }
            }
        } else {
            account.tokenCredentials
        }

        if (credentials == null) {
            return false
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
            null,
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

            return false
        }

        app.accountStore.updateData {
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

        return true
    }

    private suspend fun deleteAccounts(accountList: List<String>? = null) {
        val manager = AccountManager.get(context)

        for (account in manager.getAccountsByType(context.getString(R.string.account_type))) {
            val uid = manager.getUserData(
                account,
                KEY_UID
            )

            if (accountList != null && !accountList.contains(uid)) {
                continue
            }

            manager.removeAccountExplicitly(account)
        }

        val app = context.applicationContext as App

        app.accountStore.updateData { registry ->
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

    override suspend fun deleteAccount(uid: String) {
        deleteAccounts(listOf(uid))
    }

    override suspend fun deleteAllAccounts() {
        deleteAccounts(null)
    }

    override suspend fun updateAccount(
        newRawAccount: ByteArray,
        uid: String,
    ): Boolean {
        val app = context.applicationContext as App

        val newAccount = AntinoteAccount.parseFrom(newRawAccount)

        var result = true

        app.accountStore.updateData { registry ->
            registry.copy {
                val accIndex = accounts.indexOfFirst { it.uid == uid }
                if (accIndex == -1) {
                    throw IllegalStateException("Tried to update an account that does not exist")
                }

                val oldAccount = accounts[accIndex]
                accounts[accIndex] = newAccount.copy {
                    if (newAccount.storeSecurely != oldAccount.storeSecurely) {
                        if (newAccount.storeSecurely) {
                            val newCredentials =
                                encryptCredentials(uid, oldAccount.tokenCredentials, null)

                            if (newCredentials == null) {
                                Log.i(
                                    TAG,
                                    "Could not encrypt credentials for the first time, probably canceled."
                                )
                                result = false
                                return@updateData registry
                            }

                            tokenCredentials = Any.newBuilder().run {
                                setValue(newCredentials.toByteString())
                                setTypeUrl("${TYPE_PREFIX}/${newCredentials.javaClass.name}")
                                build()
                            }
                        } else {
                            val newCredentials = decryptCredentials(
                                uid,
                                EncryptedCredentials.parseFrom(oldAccount.tokenCredentials.value)
                            )

                            if (newCredentials == null) {
                                Log.i(
                                    TAG,
                                    "Could not decrypt credentials for the first time, probably canceled."
                                )
                                result = false
                                return@updateData registry
                            }

                            tokenCredentials = newCredentials
                        }
                    } else if (hasTokenCredentials() && newAccount.storeSecurely) {
                        val newCredentials = encryptCredentials(
                            uid, newAccount.tokenCredentials,
                            if (oldAccount.storeSecurely) {
                                EncryptedCredentials.parseFrom(oldAccount.tokenCredentials.value)
                            } else null
                        )

                        if (newCredentials == null) {
                            result = false
                            return@updateData registry
                        }

                        tokenCredentials = Any.newBuilder().run {
                            setValue(newCredentials.toByteString())
                            setTypeUrl("${TYPE_PREFIX}/${newCredentials.javaClass.name}")
                            build()
                        }
                    } else if(!hasTokenCredentials()) {
                        tokenCredentials = oldAccount.tokenCredentials
                    }
                }

                assert(accounts[accIndex].hasTokenCredentials())
            }
        }

        return result
    }

    override suspend fun listAccounts(): List<ByteArray> {
        return scanAndGetAccounts(null).map { it.toByteArray() }
    }

    suspend fun scanAndGetAccounts(uidFilter: List<String>?): List<AntinoteAccount> {
        val accounts = mutableListOf<AntinoteAccount>()
        val manager = AccountManager.get(context)

        val remainingAccountUids =
            manager.getAccountsByType(context.getString(R.string.account_type))
                .mapNotNull { manager.getUserData(it, KEY_UID) }
                .toMutableSet()
        val filterSet = uidFilter?.toSet()

        val accountsToDelete = mutableListOf<String>()

        val app = context.applicationContext as App

        for (account in app.accountStore.data.first().accountsList) {
            if (remainingAccountUids.contains(account.uid)) {
                remainingAccountUids.remove(account.uid)
            } else {
                accountsToDelete.add(account.uid)
                continue
            }

            if (filterSet != null && !filterSet.contains(account.uid)) continue

            accounts.add(account.copy { clearTokenCredentials() })
        }

        deleteAccounts((remainingAccountUids + accountsToDelete).toList())

        return accounts.toList()
    }

    override suspend fun getAccountWithCredentials(uid: String): ByteArray? {
        val app = context.applicationContext as App

        val account =
            app.accountStore.data.first().accountsList.firstOrNull { it.uid == uid }

        if (account == null) {
            Log.w(TAG, "Could not find any account with uid $uid")
            return null
        }

        if (!account.storeSecurely) {
            if(!account.hasTokenCredentials()) {
                Log.e(TAG, "Non-secure account does not have credentials")
                return null
            }

            return account.toByteArray()
        }

        if (!account.hasTokenCredentials() || account.tokenCredentials.typeUrl != "$TYPE_PREFIX/${EncryptedCredentials::class.java.name}") {
            Log.e(TAG, "Secure account $uid strangely does not contain any token credentials")
            return null
        }

        val decrypted = decryptCredentials(
            uid,
            EncryptedCredentials.parseFrom(account.tokenCredentials.value)
        )

        if (decrypted == null) {
            return null
        }

        return account.copy {
            tokenCredentials = decrypted
        }.toByteArray()
    }

    override suspend fun getAccount(uid: String): ByteArray? {
        val account = scanAndGetAccounts(listOf(uid)).singleOrNull()
        return account?.toByteArray()
    }

    override suspend fun getDefaultAccount(): ByteArray? {
        val app = context.applicationContext as App
        val registry = app.accountStore.data.first()

        if (!registry.hasDefaultAccountId()) {
            return null
        }

        val account = registry.accountsList.firstOrNull { it.uid == registry.defaultAccountId }

        if (account == null) {
            return null
        }

        return account.copy { clearTokenCredentials() }.toByteArray()

    }

    override suspend fun setDefaultAccount(uid: String?) {
        val app = context.applicationContext as App

        app.accountStore.updateData { registry ->
            registry.copy {
                if (uid == null) {
                    clearDefaultAccountId()
                } else {
                    defaultAccountId = uid
                }
            }
        }
    }

    override suspend fun manuallySyncAccount(uid: String): Boolean {
        scanAndGetAccounts(listOf(uid)).singleOrNull() ?: return false

        val workRequest = OneTimeWorkRequestBuilder<SyncWorker>().apply {
            setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            setInputData(
                workDataOf(
                    SyncWorker.KEY_UIDS to arrayOf(uid)
                )
            )
        }.build()

        val workManager = WorkManager.getInstance(context)

        workManager.enqueueUniqueWork(
            FORCE_SYNC_WORK_ID + uid,
            ExistingWorkPolicy.KEEP,
            workRequest
        )

        val workInfo = workManager.getWorkInfoByIdFlow(workRequest.id)
            .filterNotNull()
            .first { it.state.isFinished }

        return workInfo.state == WorkInfo.State.SUCCEEDED
    }

    override suspend fun cancelManualSync(uid: String) {
        val workManager = WorkManager.getInstance(context)
        workManager.cancelUniqueWork(FORCE_SYNC_WORK_ID + uid)
    }
}