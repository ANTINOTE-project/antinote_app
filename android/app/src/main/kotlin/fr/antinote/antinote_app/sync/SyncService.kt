package fr.antinote.antinote_app.sync

import android.app.Service
import android.content.Intent
import android.os.IBinder

class SyncService : Service() {
    companion object {
        // Storage for an instance of the sync adapter
        private var sSyncAdapter: SyncAdapter? = null

        // Object to use as a thread-safe lock
        private val sSyncAdapterLock = Any()
    }

    override fun onCreate() {
        synchronized(sSyncAdapterLock) {
            sSyncAdapter = SyncAdapter(applicationContext, true)
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        return sSyncAdapter?.syncAdapterBinder ?: throw IllegalStateException()
    }

}