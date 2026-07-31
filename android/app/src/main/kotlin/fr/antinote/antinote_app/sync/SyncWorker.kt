package fr.antinote.antinote_app.sync

import android.content.Context
import android.util.Log
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import fr.antinote.antinote_app.R
import fr.antinote.antinote_app.auth.LoginManager
import fr.antinote.antinote_app.auth.accountStore
import fr.antinote.antinote_app.calendar.CalendarManager
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import fr.antinote.antinote_app.protos.AntinoteAccount
import fr.antinote.antinote_app.session.SessionManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeCalendarManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeSessionManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeSyncManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.SyncResultType
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.minutes

class SyncWorker(appContext: Context, workerParams: WorkerParameters) : CoroutineWorker(appContext, workerParams) {
    companion object {
        const val TAG = "SyncWorker"
        const val KEY_UIDS = "account_uids"
        const val SYNC_NOTIFICATION_CHANNEL_ID = "sync_channel"

        fun shouldDoSync(account: AntinoteAccount): Boolean = !account.storeSecurely && (account.syncCalendar || account.syncNotifications)
    }

    data class JobData(var workResult: Result? = null, var engine: FlutterEngine? = null, var sessionManager: SessionManager? = null)

    private val mainScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override suspend fun doWork(): Result {
        Log.i(TAG, "Starting sync...")

        val uids = inputData.getStringArray(KEY_UIDS)
        val validUids = mutableListOf<String>()

        for(account in applicationContext.accountStore.data.first().accountsList) {
            if(!shouldDoSync(account)) continue
            if(uids != null && !uids.contains(account.uid)) continue

            validUids.add(account.uid)
        }

        val data = JobData()

        val syncLock: CompletableDeferred<Unit> = CompletableDeferred()

        val job: Job = mainScope.launch {
            val flutterLoader = FlutterInjector.instance().flutterLoader()

            flutterLoader.startInitialization(applicationContext)
            flutterLoader.ensureInitializationComplete(applicationContext, arrayOf())

            data.engine = FlutterEngine(applicationContext)

            val entrypoint = DartExecutor.DartEntrypoint(
                flutterLoader.findAppBundlePath(),
                "syncMain"
            )

            data.sessionManager = SessionManager(applicationContext, data.engine!!.dartExecutor.binaryMessenger)

            NativeSyncManager.setUp(
                data.engine!!.dartExecutor.binaryMessenger,
                object : NativeSyncManager {
                    override fun syncFinished(result: fr.antinote.studies_management.antinote_app.pigeon_posts.SyncResult) {
                        data.workResult = when (result.result) {
                            SyncResultType.SUCCESS -> Result.success()
                            SyncResultType.AUTH -> Result.failure()
                            SyncResultType.AVAILABILITY -> Result.retry()
                            SyncResultType.PARSING -> Result.failure()
                        }

                        syncLock.complete(Unit)
                    }
                }
            )
            NativeCalendarManager.setUp(
                data.engine!!.dartExecutor.binaryMessenger,
                CalendarManager(applicationContext)
            )
            NativeLoginManager.setUp(data.engine!!.dartExecutor.binaryMessenger, LoginManager(applicationContext, null))
            NativeSessionManager.setUp(
                data.engine!!.dartExecutor.binaryMessenger,
                data.sessionManager
            )

            data.engine!!.dartExecutor.executeDartEntrypoint(
                entrypoint,
                validUids
            )
        }

        var result: Result

        try {
            withTimeout(validUids.size.minutes) {
                job.join()
                syncLock.await()
            }

            result = data.workResult ?: Result.failure()
        } catch (_: TimeoutCancellationException) {
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
            NotificationChannelCompat.Builder(SYNC_NOTIFICATION_CHANNEL_ID,
                NotificationManagerCompat.IMPORTANCE_MIN).build())

        return ForegroundInfo(
            0,
            NotificationCompat.Builder(applicationContext, SYNC_NOTIFICATION_CHANNEL_ID).run {
                setContentTitle(applicationContext.getString(R.string.syncing))
                setSmallIcon(R.drawable.rounded_sync_arrow_down_24)

                // TODO: Make sync have a progress indicator using the NativeSyncManager.

                build()
            }
        )
    }
}