package fr.antinote.antinote_app

import android.content.pm.ApplicationInfo
import android.util.Log
import fr.antinote.antinote_app.auth.LoginManager
import fr.antinote.antinote_app.calendar.CalendarManager
import fr.antinote.antinote_app.pigeon_posts.NativeLoginManager
import fr.antinote.antinote_app.session.SessionManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeCalendarManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.NativeSessionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "StudiesManagement"
    }

    lateinit var sessionManager: SessionManager
    private var isFirstLaunch = true

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sessionManager = SessionManager(this, flutterEngine.dartExecutor.binaryMessenger)
        NativeLoginManager.setUp(flutterEngine.dartExecutor.binaryMessenger, LoginManager(this))
        NativeSessionManager.setUp(flutterEngine.dartExecutor.binaryMessenger, sessionManager)
        NativeCalendarManager.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            CalendarManager(context)
        )

        // Is in debug mode
        if ((applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            Log.i(TAG, "Listening for new isolates to restart service on hot restart")
            flutterEngine.dartExecutor.setIsolateServiceIdListener {
                if (isFirstLaunch) {
                    isFirstLaunch = false
                } else {
                    Log.i(TAG, "Detected a hot restart, restarting service connection")
                    // This should restart the service when we hot restart if nothing else is going on.
                    sessionManager.doUnbindService()
                    sessionManager.doBindService()
                }
            }
        }
    }

    override fun onDestroy() {
        sessionManager.doUnbindService()
        super.onDestroy()
    }
}
