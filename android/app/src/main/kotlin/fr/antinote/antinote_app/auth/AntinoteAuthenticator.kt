package fr.antinote.antinote_app.auth

import android.accounts.AbstractAccountAuthenticator
import android.accounts.Account
import android.accounts.AccountAuthenticatorResponse
import android.accounts.AccountManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import fr.antinote.antinote_app.R

class AntinoteAuthenticator(val context: Context) : AbstractAccountAuthenticator(context) {
    companion object {
        private const val TAG = "AntinoteAuthenticator"
    }

    override fun addAccount(
        response: AccountAuthenticatorResponse,
        accountType: String,
        authTokenType: String?,
        requiredFeatures: Array<out String?>?,
        options: Bundle
    ): Bundle {
        return Bundle().apply {
            putParcelable(
                AccountManager.KEY_INTENT,
                Intent(context, AuthActivity::class.java).apply {
                    putParcelable(AccountManager.KEY_ACCOUNT_AUTHENTICATOR_RESPONSE, response)
                })
        }
    }

    override fun confirmCredentials(
        response: AccountAuthenticatorResponse,
        account: Account,
        options: Bundle?
    ): Bundle? {
        Log.i(TAG, "Tried to confirm credentials")
        TODO("Not yet implemented")
    }

    override fun editProperties(
        response: AccountAuthenticatorResponse,
        accountType: String
    ): Bundle? {
        Log.i(TAG, "Tried to edit properties")
        TODO("Not yet implemented")
    }

    override fun getAuthToken(
        response: AccountAuthenticatorResponse,
        account: Account,
        authTokenType: String,
        options: Bundle
    ): Bundle? {
        return Bundle().apply {
            putString(AccountManager.KEY_ACCOUNT_NAME, account!!.name)
            putString(AccountManager.KEY_ACCOUNT_TYPE, account.type)
            putString(
                AccountManager.KEY_AUTHTOKEN,
                AccountManager.get(context).peekAuthToken(account, authTokenType!!)
            )
        }
    }

    override fun getAuthTokenLabel(authTokenType: String): String {
        return context.getString(R.string.app_name)
    }

    override fun hasFeatures(
        response: AccountAuthenticatorResponse,
        account: Account,
        features: Array<out String?>
    ): Bundle? {
        Log.i(TAG, "Tried to get features for account for features $features")

        return Bundle().apply {
            putBoolean(AccountManager.KEY_BOOLEAN_RESULT, true)
        }
    }

    override fun updateCredentials(
        response: AccountAuthenticatorResponse?,
        account: Account?,
        authTokenType: String?,
        options: Bundle?
    ): Bundle? {
        Log.i(TAG, "Tried to update credentials")
        TODO("Not yet implemented")
    }
}