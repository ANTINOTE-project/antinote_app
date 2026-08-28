package fr.antinote.antinote_app.sync

import android.accounts.Account
import android.accounts.AccountManager
import android.content.AbstractThreadedSyncAdapter
import android.content.ContentProviderClient
import android.content.ContentResolver
import android.content.Context
import android.content.SyncResult
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo
import android.os.Bundle
import android.provider.CalendarContract
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.await
import fr.antinote.antinote_app.R
import fr.antinote.antinote_app.auth.LoginManager
import fr.antinote.antinote_app.protos.SyncTaskType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext

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

    override fun onSecurityException(
        account: Account,
        extras: Bundle,
        authority: String,
        syncResult: SyncResult
    ) {
        val accountUid = AccountManager.get(context).getUserData(account, LoginManager.KEY_UID)
        Log.i(TAG, "Could not sync account: permission not granted for account $accountUid")

        ContentResolver.setSyncAutomatically(account, authority, false)

        runBlocking(Dispatchers.Main) {
            Toast.makeText(
                context.applicationContext,
                R.string.calendar_permission_message,
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    override fun onUnsyncableAccount(): Boolean {
        if (ContextCompat.checkSelfPermission(
                context,
                "android.permission.READ_CALENDAR"
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.i(TAG, "Could not sync account: permission not granted")

            runBlocking(Dispatchers.Main) {
                Toast.makeText(
                    context.applicationContext,
                    R.string.calendar_permission_message,
                    Toast.LENGTH_SHORT
                ).show()
            }

            return false
        }

        Log.i(TAG, "Could not sync account: unknown reason")

        return true
    }

    override fun onSyncCanceled(thread: Thread) {
        WorkManager.getInstance(context).cancelUniqueWork(LEGACY_SYNC_WORK + thread.name)

        super.onSyncCanceled(thread)
    }
}