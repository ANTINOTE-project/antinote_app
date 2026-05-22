package fr.antinote.antinote_app.auth

import android.accounts.AccountAuthenticatorResponse
import android.accounts.AccountManager
import android.os.Build
import android.os.Bundle
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class AuthActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        NativeLoginManager.setUp(flutterEngine.dartExecutor.binaryMessenger, LoginManager(this))
    }

    private var mAccountAuthenticatorResponse: AccountAuthenticatorResponse? = null
    private var mResultBundle: Bundle? = null

    /**
     * Set the result that is to be sent as the result of the request that caused this
     * Activity to be launched. If result is null or this method is never called then
     * the request will be canceled.
     * @param result this is returned as the result of the AbstractAccountAuthenticator request
     */
    fun setAccountAuthenticatorResult(result: Bundle?) {
        mResultBundle = result
    }

    /**
     * Retrieves the AccountAuthenticatorResponse from either the intent of the icicle, if the
     * icicle is non-zero.
     * @param icicle the save instance data of this Activity, may be null
     */
    override fun onCreate(icicle: Bundle?) {
        super.onCreate(icicle)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            mAccountAuthenticatorResponse =
                intent.getParcelableExtra(
                    AccountManager.KEY_ACCOUNT_AUTHENTICATOR_RESPONSE,
                    AccountAuthenticatorResponse::class.java
                )
        } else {
            @Suppress("DEPRECATION")
            mAccountAuthenticatorResponse =
                intent.getParcelableExtra(
                    AccountManager.KEY_ACCOUNT_AUTHENTICATOR_RESPONSE,
                )
        }

        if (mAccountAuthenticatorResponse != null) {
            mAccountAuthenticatorResponse!!.onRequestContinued()
        }
    }

    /**
     * Sends the result or a [AccountManager.ERROR_CODE_CANCELED] error if a result isn't present.
     */
    override fun finish() {
        if (mAccountAuthenticatorResponse != null) {
            if (mResultBundle != null) {
                mAccountAuthenticatorResponse!!.onResult(mResultBundle)
            } else {
                mAccountAuthenticatorResponse!!.onError(
                    AccountManager.ERROR_CODE_CANCELED,
                    "canceled"
                )
            }
            mAccountAuthenticatorResponse = null
        }

        super.finish()
    }
}