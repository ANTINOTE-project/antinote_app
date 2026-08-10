package fr.antinote.antinote_app.sync

import android.content.Context
import android.util.Log
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import fr.antinote.antinote_app.App
import fr.antinote.antinote_app.R
import fr.antinote.antinote_app.auth.LoginManager
import fr.antinote.antinote_app.calendar.CalendarManager
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import fr.antinote.antinote_app.protos.AntinoteAccount
import fr.antinote.antinote_app.protos.SyncTaskType
import fr.antinote.antinote_app.session.SessionManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeCalendarManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeSessionManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.SyncManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.SyncRequest
import fr.antinote.studies_management.antinote_app.pigeon_posts.SyncResponse
import fr.antinote.studies_management.antinote_app.pigeon_posts.SyncResultType
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.completeWith
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.minutes

class SyncWorker(appContext: Context, workerParams: WorkerParameters) :
    CoroutineWorker(appContext, workerParams) {
    companion object {
        const val TAG = "SyncWorker"
        const val KEY_UIDS = "account_uids"
        const val KEY_FORCED_TASKS = "forced"
        const val SYNC_NOTIFICATION_CHANNEL_ID = "sync_channel"

        fun shouldDoSync(account: AntinoteAccount): Boolean =
            !account.storeSecurely && account.syncDataList.any { it.enabled }
    }

    data class JobData(
        var workResult: Result? = null,
        var engine: FlutterEngine? = null,
        var sessionManager: SessionManager? = null
    )

    private val mainScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override suspend fun doWork(): Result {
        Log.i(TAG, "Starting sync...")

        val app = applicationContext as App

        val uids = inputData.getStringArray(KEY_UIDS)
        val validUids = mutableListOf<String>()

        val forcedTasks =
            inputData.getIntArray(KEY_FORCED_TASKS)?.map { SyncTaskType.forNumber(it) }

        for (account in app.accountStore.data.first().accountsList) {
            Log.i(TAG, "Checking whether we should sync ${account.uid}...")

            if(account.storeSecurely) continue
            if(!shouldDoSync(account) && uids == null) {
                Log.i(TAG, "We skip sync for account ${account.uid} because it doesn't have any task to run.")
                continue
            }
            if (uids != null && !uids.contains(account.uid)) {
                Log.i(TAG, "We skip sync for account ${account.uid} for now to focus on provided accounts.")
                continue
            }

            validUids.add(account.uid)
        }

        if (validUids.isEmpty()) {
            Log.i(TAG, "Sync finished because no UIDs with applicable run tasks were found.")
            return Result.failure()
        }

        val data = JobData()

        val syncLock: CompletableDeferred<Unit> = CompletableDeferred()

        val job: Job = mainScope.launch {
            val flutterLoader = FlutterInjector.instance().flutterLoader()

            flutterLoader.startInitialization(applicationContext)
            flutterLoader.ensureInitializationComplete(applicationContext, null)

            val entrypoint = DartExecutor.DartEntrypoint(
                flutterLoader.findAppBundlePath(),
                "syncMain"
            )

            val options = FlutterEngineGroup.Options(applicationContext).run {
                setAutomaticallyRegisterPlugins(false)
                setDartEntrypoint(entrypoint)
            }

            data.engine = app.engineGroup.createAndRunEngine(options)
            data.engine!!.plugins.add(SharedPreferencesPlugin())

            data.sessionManager =
                SessionManager(applicationContext, data.engine!!.dartExecutor.binaryMessenger)

            val syncManager = SyncManager(data.engine!!.dartExecutor.binaryMessenger)
            val loginManager = LoginManager(applicationContext, null)

            NativeCalendarManager.setUp(
                data.engine!!.dartExecutor.binaryMessenger,
                CalendarManager(applicationContext)
            )
            NativeLoginManager.setUp(
                data.engine!!.dartExecutor.binaryMessenger,
                loginManager
            )
            NativeSessionManager.setUp(
                data.engine!!.dartExecutor.binaryMessenger,
                data.sessionManager
            )

            var curResponseLevel: SyncResultType = SyncResultType.SUCCESS

            val accounts = loginManager.scanAndGetAccounts(uidFilter = validUids)
            for(account in accounts) {
                val completer = CompletableDeferred<SyncResponse>()

                syncManager.syncAccount(
                    SyncRequest(
                        account = account.toByteArray(),
                        forcedScope = forcedTasks?.map { it.number.toLong() }
                    )
                ) { res ->
                    completer.completeWith(res)
                }

                val res = completer.await()

                if(res.result == SyncResultType.RETRY) {
                    curResponseLevel = res.result
                } else if(res.result == SyncResultType.FAILURE && curResponseLevel == SyncResultType.SUCCESS) {
                    curResponseLevel = res.result
                }
            }

            data.workResult = when (curResponseLevel) {
                SyncResultType.SUCCESS -> Result.success()
                SyncResultType.RETRY -> Result.retry()
                SyncResultType.FAILURE -> Result.failure()
            }
            syncLock.complete(Unit)
        }

        var result: Result

        try {
            withTimeout(validUids.size.minutes) {
                job.join()
                syncLock.await()
            }

            result = data.workResult ?: Result.failure()
        } catch (_: TimeoutCancellationException) {
            Log.e(TAG, "Timeout while trying to update accounts.")
            result = Result.retry()
        } finally {
            mainScope.launch {
                data.sessionManager?.doUnbindService()
                data.engine?.destroy()
            }.join()
        }

        return result
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        NotificationManagerCompat.from(applicationContext).createNotificationChannel(
            NotificationChannelCompat.Builder(
                SYNC_NOTIFICATION_CHANNEL_ID,
                NotificationManagerCompat.IMPORTANCE_MIN
            ).build()
        )

        return ForegroundInfo(
            0,
            NotificationCompat.Builder(applicationContext, SYNC_NOTIFICATION_CHANNEL_ID).run {
                setContentTitle(applicationContext.getString(R.string.syncing))
                setSmallIcon(R.drawable.rounded_sync_arrow_down_24)

                // TODO: Make sync have a progress indicator using the SyncManager.

                build()
            }
        )
    }
}