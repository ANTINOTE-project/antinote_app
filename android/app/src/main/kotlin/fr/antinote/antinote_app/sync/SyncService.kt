package fr.antinote.antinote_app.sync

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class SyncService : Service() {
    companion object {
        // Storage for an instance of the sync adapter
        private var sSyncAdapter: SyncAdapter? = null

        // Object to use as a thread-safe lock
        private val sSyncAdapterLock = Any()

        private const val TAG = "SyncService"
    }

    override fun onCreate() {
        synchronized(sSyncAdapterLock) {
            sSyncAdapter = SyncAdapter(applicationContext, true)
            Log.i(TAG, "Sync service created")
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        Log.i(TAG, "Bound sync adapter")
        return sSyncAdapter?.syncAdapterBinder ?: throw IllegalStateException()
    }

}