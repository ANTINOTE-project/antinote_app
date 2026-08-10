package fr.antinote.antinote_app.sync

import android.accounts.Account
import android.accounts.AccountManager
import android.content.AbstractThreadedSyncAdapter
import android.content.ContentProviderClient
import android.content.ContentResolver
import android.content.Context
import android.content.SyncResult
import android.os.Bundle
import android.provider.CalendarContract
import android.util.Log
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.await
import fr.antinote.antinote_app.auth.LoginManager
import fr.antinote.antinote_app.protos.SyncTaskType
import kotlinx.coroutines.runBlocking

class SyncAdapter @JvmOverloads constructor(
    context: Context,
    autoInitialize: Boolean,
    allowParallelSyncs: Boolean = true
) : AbstractThreadedSyncAdapter(context, autoInitialize, allowParallelSyncs) {
    companion object {
        const val TAG = "SyncAdapter"
        const val LEGACY_SYNC_WORK = "legacy_sync_"
    }

    override fun onPerformSync(
        account: Account,
        extras: Bundle,
        authority: String,
        provider: ContentProviderClient,
        syncResult: SyncResult
    ) {
        val isManual = extras.getBoolean(ContentResolver.SYNC_EXTRAS_MANUAL, false)
        val isInitialization = extras.getBoolean(ContentResolver.SYNC_EXTRAS_INITIALIZE, false)
        val isExpedited = extras.getBoolean(ContentResolver.SYNC_EXTRAS_EXPEDITED, false)
        if (!isManual && !isInitialization && !isExpedited) {
//            ContentResolver.setSyncAutomatically(account, authority, false)
            Log.i(TAG, "OS tried to sync calendar using the legacy sync adapter.")
            return
        }

        Log.i(TAG, "Redirecting sync adapter task to worker...")
        val manager = AccountManager.get(context)
        val uid = manager.getUserData(account, LoginManager.KEY_UID)

        Log.i(TAG, "The UID we should perform sync on is $uid")

        val request = OneTimeWorkRequest.Builder(SyncWorker::class).run {
            setExpedited(
                OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST
            )
            setConstraints(
                Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()
            )
            setInputData(Data.Builder().run {
                putStringArray(SyncWorker.KEY_UIDS, arrayOf(uid))
                putIntArray(
                    SyncWorker.KEY_FORCED_TASKS, intArrayOf(
                        when (authority) {
                            CalendarContract.AUTHORITY -> SyncTaskType.CALENDAR.number
                            else -> throw IllegalArgumentException("Unknown provider authority: $authority")
                        }
                    )
                )

                build()
            })

            build()
        }

        val thread = Thread.currentThread()

        val operation = WorkManager.getInstance(context)
            .enqueueUniqueWork(LEGACY_SYNC_WORK + thread.name, ExistingWorkPolicy.REPLACE, request)

        runBlocking {
            operation.await()
        }
    }

    override fun onSyncCanceled(thread: Thread) {
        WorkManager.getInstance(context).cancelUniqueWork(LEGACY_SYNC_WORK + thread.name)

        super.onSyncCanceled(thread)
    }
}