package fr.antinote.antinote_app.sync

import android.accounts.Account
import android.accounts.AccountManager
import android.content.AbstractThreadedSyncAdapter
import android.content.ContentProviderClient
import android.content.Context
import android.content.SyncResult
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.await
import fr.antinote.antinote_app.auth.LoginManager
import fr.antinote.antinote_app.calendar.CalendarManager
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import fr.antinote.antinote_app.session.SessionManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeCalendarManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeSessionManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeSyncManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.SyncResultType
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.runBlocking
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class SyncAdapter @JvmOverloads constructor(
    context: Context,
    autoInitialize: Boolean,
    allowParallelSyncs: Boolean = true
) : AbstractThreadedSyncAdapter(context, autoInitialize, allowParallelSyncs) {
    companion object {
        const val TAG = "SyncAdapter"
    }

    override fun onPerformSync(
        account: Account,
        extras: Bundle,
        authority: String,
        provider: ContentProviderClient,
        syncResult: SyncResult
    ) {
        Log.i(TAG, "Starting sync...")
        val manager = AccountManager.get(context)
        val uid = manager.getUserData(account, LoginManager.KEY_UID)

        val request = OneTimeWorkRequest.Builder(SyncWorker::class).run {
            setExpedited(
                OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST
            )
            setConstraints(
                Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()
            )
            setInputData(Data.Builder().putStringArray(SyncWorker.KEY_UIDS, arrayOf(uid)).build())

            build()
        }

        val op = WorkManager.getInstance(context).enqueue(request)

        runBlocking {
            op.await()
        }
    }
}