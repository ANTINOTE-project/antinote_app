package fr.antinote.antinote_app.sync

import android.accounts.AccountManager
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
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
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class SyncWorker(appContext: Context, workerParams: WorkerParameters) : Worker(appContext, workerParams) {
    companion object {
        const val TAG = "SyncWorker"
    }

    override fun doWork(): Result {
        Log.i(TAG, "Starting sync...")

        val uid = inputData.getString("account_uid")!!
        val accountManager = AccountManager.get(applicationContext)
        if(accountManager.accounts.none { accountManager.getUserData(it, LoginManager.KEY_UID) == uid }) {
            return Result.failure()
        }


        val latch = CountDownLatch(1)
        var workResult: Result? = null;
        var engine: FlutterEngine? = null
        var sessionManager: SessionManager? = null

        Handler(Looper.getMainLooper()).post {
            val flutterLoader = FlutterInjector.instance().flutterLoader()

            flutterLoader.startInitialization(applicationContext)
            flutterLoader.ensureInitializationComplete(applicationContext, arrayOf())

            val newEngine = FlutterEngine(applicationContext)
            engine = newEngine
            val entrypoint = DartExecutor.DartEntrypoint(
                flutterLoader.findAppBundlePath(),
                "syncMain"
            )

            val newSessionManager = SessionManager(applicationContext, newEngine.dartExecutor.binaryMessenger)
            sessionManager = newSessionManager

            NativeSyncManager.setUp(
                newEngine.dartExecutor.binaryMessenger,
                object : NativeSyncManager {
                    override fun syncFinished(result: fr.antinote.studies_management.antinote_app.pigeon_posts.SyncResult) {
                        workResult = when (result.result) {
                            SyncResultType.SUCCESS -> Result.success()
                            SyncResultType.AUTH -> Result.failure()
                            SyncResultType.AVAILABILITY -> Result.retry()
                            SyncResultType.PARSING -> Result.failure()
                        }

                        latch.countDown()
                    }
                }
            )
            NativeCalendarManager.setUp(
                newEngine.dartExecutor.binaryMessenger,
                CalendarManager(applicationContext)
            )
            NativeLoginManager.setUp(newEngine.dartExecutor.binaryMessenger, LoginManager(applicationContext))
            NativeSessionManager.setUp(
                newEngine.dartExecutor.binaryMessenger,
                newSessionManager
            )

            newEngine.dartExecutor.executeDartEntrypoint(
                entrypoint,
                listOf(uid)
            )
        }

        try {
            val finished = latch.await(3, TimeUnit.MINUTES)
            if (!finished) {
                workResult = Result.retry()
            }
        } catch (_: InterruptedException) {
            workResult = Result.retry()
        } finally {
            Handler(Looper.getMainLooper()).post {
                sessionManager?.doUnbindService()
                engine?.destroy()
            }
        }

        return workResult ?: Result.failure()
    }

}