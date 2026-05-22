package fr.antinote.antinote_app.auth

import android.accounts.Account
import android.accounts.AccountManager
import android.accounts.AccountManager.KEY_ACCOUNT_NAME
import android.accounts.AccountManager.KEY_ACCOUNT_TYPE
import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.CalendarContract
import android.util.Log
import com.google.protobuf.Any
import fr.antinote.antinote_app.R
import fr.antinote.antinote_app.auth.LoginManager.Companion.KEY_BASE_URL
import fr.antinote.antinote_app.auth.LoginManager.Companion.KEY_ESTABLISHMENT_NAME
import fr.antinote.antinote_app.auth.LoginManager.Companion.KEY_NAME
import fr.antinote.antinote_app.auth.LoginManager.Companion.KEY_UID
import fr.antinote.antinote_app.auth.LoginManager.Companion.KEY_USERNAME
import fr.antinote.antinote_app.auth.LoginManager.Companion.KEY_WORKSPACE_NAME
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import fr.antinote.antinote_app.protos.Account.AntinoteAccount
import kotlin.io.encoding.Base64

fun AntinoteAccount.toUserdataBundle(): Bundle {
    return Bundle().apply {
        putString(KEY_UID, uid)
        putString(KEY_NAME, name)
        putString(KEY_USERNAME, username)
        putString(KEY_ESTABLISHMENT_NAME, establishmentName)
        putString(KEY_BASE_URL, baseUrl)
        putString(KEY_WORKSPACE_NAME, workspaceName)
    }
}

fun listUserdataKeys(): List<String> = listOf(
    KEY_UID,
    KEY_NAME,
    KEY_USERNAME,
    KEY_ESTABLISHMENT_NAME,
    KEY_BASE_URL,
    KEY_WORKSPACE_NAME,
)

fun Account.asAntinoteAccount(
    manager: AccountManager,
    putCredentials: Boolean = false
): AntinoteAccount {
    return AntinoteAccount.newBuilder().apply {
        uid = manager.getUserData(this@asAntinoteAccount, KEY_UID)
        name = manager.getUserData(this@asAntinoteAccount, KEY_NAME)
        username = manager.getUserData(this@asAntinoteAccount, KEY_USERNAME)
        establishmentName = manager.getUserData(this@asAntinoteAccount, KEY_ESTABLISHMENT_NAME)
        baseUrl = manager.getUserData(this@asAntinoteAccount, KEY_BASE_URL)
        workspaceName = manager.getUserData(this@asAntinoteAccount, KEY_WORKSPACE_NAME)

        if (putCredentials) {
            tokenCredentials = Any.parseFrom(Base64.decode(manager.getPassword(this@asAntinoteAccount)))
        }
    }.build()
}

class LoginManager(val context: Context) : NativeLoginManager {
    companion object {
        private const val TAG = "LoginManager"
        const val KEY_UID = "uid"
        const val KEY_NAME = "name"
        const val KEY_USERNAME = "username"
        const val KEY_ESTABLISHMENT_NAME = "establishment_name"
        const val KEY_BASE_URL = "base_url"
        const val KEY_WORKSPACE_NAME = "workspace_name"
        const val KEY_IS_DEFAULT = "is_default"

        fun accountForUid(context: Context, accountKey: String): Account {
            val am = AccountManager.get(context)
            return am.accounts.first { am.getUserData(it, KEY_UID) == accountKey }
        }
    }

    override fun addAccount(rawAccount: ByteArray) {
        val account = AntinoteAccount.parseFrom(rawAccount)
        val manager = AccountManager.get(context)

        Log.i(TAG, "In total, there are ${manager.accounts.size} accounts")
        for (account in manager.accounts) {
            Log.d(TAG, "-> '${account.name}:${account.type}'")
        }

        val nativeAccount = Account(account.name, context.getString(R.string.account_type))
        val result = manager.addAccountExplicitly(
            nativeAccount,
            Base64.encode(account.tokenCredentials!!.toByteArray()),
            account.toUserdataBundle()
        )

        if (!result) {
            Log.e(TAG, "Could not create account...")

            if (context is AuthActivity) {
                context.setResult(Activity.RESULT_CANCELED)
                context.finish()
            }

            return
        }

        // TODO: Add a check for whether we have the calendar permission
        ContentResolver.setSyncAutomatically(nativeAccount, CalendarContract.AUTHORITY, true)

        Log.d(TAG, "Added account to manager with UID ${account.uid}")

        if (context is AuthActivity) {
            val resultIntent = Intent().apply {
                putExtra(KEY_ACCOUNT_NAME, account.name)
                putExtra(
                    KEY_ACCOUNT_TYPE,
                    context.getString(R.string.account_type)
                )
            }

            context.setAccountAuthenticatorResult(resultIntent.extras)
            context.setResult(Activity.RESULT_OK, resultIntent)
            context.finish()
        }
    }

    override fun deleteAccount(uid: String) {
        val manager = AccountManager.get(context)

        manager.removeAccountExplicitly(manager.accounts.find {
            return@find manager.getUserData(
                it,
                KEY_UID
            ) == uid && it.type == context.getString(R.string.account_type)
        }!!)
    }

    override fun deleteAllAccounts() {
        val manager = AccountManager.get(context)

        for (account in manager.accounts) {
            if (account.type == context.getString(R.string.account_type)
            ) {
                manager.removeAccountExplicitly(account)
            }
        }
    }

    override fun updateAccount(newRawAccount: ByteArray, uid: String) {
        val newAccount = AntinoteAccount.parseFrom(newRawAccount)
        val manager = AccountManager.get(context)
        val account = manager.accounts.find {
            it.type == context.getString(R.string.account_type) && manager.getUserData(
                it,
                KEY_UID
            ) == uid
        }!!

        val bundle = newAccount.toUserdataBundle()
        listUserdataKeys().forEach {
            manager.setUserData(account, it, bundle.getString(it))
        }

        if (newAccount.hasTokenCredentials()) {
            manager.setPassword(account, Base64.encode(newAccount.tokenCredentials.toByteArray()))
        }
    }

    override fun listAccounts(): List<ByteArray> {
        val manager = AccountManager.get(context)

        return manager.accounts.map {
            it.asAntinoteAccount(manager).toByteArray()
        }
    }

    override fun getAccountWithCredentials(uid: String): ByteArray? {
        val manager = AccountManager.get(context)

        return manager.accounts.singleOrNull { manager.getUserData(it, KEY_UID) == uid }
            ?.asAntinoteAccount(manager, true)?.toByteArray()
    }

    override fun getDefaultAccount(): ByteArray? {
        val manager = AccountManager.get(context)

        val defaultAccount = manager.accounts.firstOrNull {
            manager.getUserData(it, KEY_IS_DEFAULT) == "true"
        }

        return defaultAccount?.asAntinoteAccount(manager)?.toByteArray()
    }

    override fun setDefaultAccount(uid: String?) {
        val manager = AccountManager.get(context)

        manager.accounts.forEach {
            manager.setUserData(
                it,
                KEY_IS_DEFAULT,
                if (manager.getUserData(it, KEY_UID) == uid) "true" else "false"
            )
        }
    }

    override fun getCredentials(rawAccount: ByteArray): ByteArray {
        val manager = AccountManager.get(context)

        return AntinoteAccount.parseFrom(rawAccount).toBuilder().apply {
            tokenCredentials =
                Any.parseFrom(Base64.decode(manager.getPassword(manager.accounts.find { it.name == name })))
        }.build().toByteArray()
    }
}