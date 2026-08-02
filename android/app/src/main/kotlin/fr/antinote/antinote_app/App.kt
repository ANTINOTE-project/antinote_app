package fr.antinote.antinote_app

import android.app.Application
import androidx.work.Configuration
import io.flutter.embedding.engine.FlutterEngineGroup

class App : Application(), Configuration.Provider {
    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder().build()

    lateinit var engineGroup: FlutterEngineGroup

    override fun onCreate() {
        super.onCreate()
        engineGroup = FlutterEngineGroup(this)
    }


}