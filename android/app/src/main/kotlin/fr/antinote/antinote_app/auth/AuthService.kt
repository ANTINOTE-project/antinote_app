package fr.antinote.antinote_app.auth

import android.app.Service
import android.content.Intent
import android.os.IBinder

class AuthService : Service() {
    private lateinit var mAuthenticator: AntinoteAuthenticator

    override fun onCreate() {
        mAuthenticator = AntinoteAuthenticator(applicationContext)
    }

    override fun onBind(intent: Intent?): IBinder? = mAuthenticator.iBinder
}