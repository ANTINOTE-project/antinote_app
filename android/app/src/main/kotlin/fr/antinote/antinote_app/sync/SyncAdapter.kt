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

class SyncAdapter @JvmOverloads constructor(
    context: Context,
    autoInitialize: Boolean,
    allowParallelSyncs: Boolean = true
) : AbstractThreadedSyncAdapter(context, autoInitialize, allowParallelSyncs) {
    override fun onPerformSync(
        account: Account,
        extras: Bundle,
        authority: String,
        provider: ContentProviderClient,
        syncResult: SyncResult
    ) {
        val accountManager = AccountManager.get(context)
        val uid = accountManager.getUserData(account, LoginManager.KEY_UID)

        val latch = CountDownLatch(1)
        var engine: FlutterEngine? = null
        var sessionManager: SessionManager? = null

        Handler(Looper.getMainLooper()).post {
            val applicationContext = context.applicationContext
            val flutterLoader = FlutterInjector.instance().flutterLoader()

            flutterLoader.startInitialization(applicationContext)
            flutterLoader.ensureInitializationComplete(applicationContext, arrayOf())

            val newEngine = FlutterEngine(applicationContext)
            engine = newEngine
            val entrypoint = DartExecutor.DartEntrypoint(
                flutterLoader.findAppBundlePath(),
                "syncMain"
            )

            val newSessionManager = SessionManager(context, newEngine.dartExecutor.binaryMessenger)
            sessionManager = newSessionManager

            NativeSyncManager.setUp(
                newEngine.dartExecutor.binaryMessenger,
                object : NativeSyncManager {
                    override fun syncFinished(result: fr.antinote.studies_management.antinote_app.pigeon_posts.SyncResult) {
                        when (result.result) {
                            SyncResultType.SUCCESS -> syncResult.clear()
                            SyncResultType.AUTH -> syncResult.stats.numAuthExceptions++
                            SyncResultType.AVAILABILITY -> syncResult.stats.numIoExceptions++
                            SyncResultType.PARSING -> syncResult.stats.numParseExceptions++
                        }

                        syncResult.stats.numEntries = result.totalEntries
                        syncResult.stats.numDeletes = result.removedEntries
                        syncResult.stats.numInserts = result.addedEntries
                        syncResult.stats.numUpdates = result.updatedEntries

                        syncResult.databaseError = result.dbIssue

                        latch.countDown()
                    }
                }
            )
            NativeCalendarManager.setUp(
                newEngine.dartExecutor.binaryMessenger,
                CalendarManager(context)
            )
            NativeLoginManager.setUp(newEngine.dartExecutor.binaryMessenger, LoginManager(context))
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
            val finished = latch.await(10, TimeUnit.MINUTES)
            if (!finished) {
                syncResult.stats.numIoExceptions++
            }
        } catch (_: InterruptedException) {
            syncResult.stats.numIoExceptions++
        } finally {
            Handler(Looper.getMainLooper()).post {
                sessionManager?.doUnbindService()
                engine?.destroy()
            }
        }
    }
}