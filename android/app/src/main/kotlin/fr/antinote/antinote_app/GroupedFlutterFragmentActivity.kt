package fr.antinote.antinote_app

import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.ApplicationInfoLoader

abstract class GroupedFlutterFragmentActivity : FlutterFragmentActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        val app = context.applicationContext as App

        val info = ApplicationInfoLoader.load(applicationContext)

        val entrypoint = DartExecutor.DartEntrypoint(
            info.flutterAssetsDir,
            dartEntrypointFunctionName
        )

        return app.engineGroup.createAndRunEngine(
            FlutterEngineGroup.Options(context).setDartEntrypoint(entrypoint)
                .setAutomaticallyRegisterPlugins(true)
                .setDartEntrypointArgs(dartEntrypointArgs).setInitialRoute(initialRoute)
        )
    }
}