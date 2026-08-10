package fr.antinote.antinote_app

import android.app.Application
import android.util.Log
import androidx.datastore.core.CorruptionException
import androidx.datastore.core.DataStore
import androidx.datastore.core.MultiProcessDataStoreFactory
import androidx.datastore.core.Serializer
import androidx.datastore.core.handlers.ReplaceFileCorruptionHandler
import androidx.datastore.deviceProtectedDataStore
import androidx.work.Configuration
import com.google.protobuf.InvalidProtocolBufferException
import fr.antinote.antinote_app.protos.SerializedAccountRegistry
import fr.antinote.antinote_app.protos.SessionRegistry
import io.flutter.embedding.engine.FlutterEngineGroup
import java.io.File
import java.io.InputStream
import java.io.OutputStream

object AccountStoreSerializer : Serializer<SerializedAccountRegistry> {
    override val defaultValue: SerializedAccountRegistry =
        SerializedAccountRegistry.getDefaultInstance()

    override suspend fun readFrom(input: InputStream): SerializedAccountRegistry {
        try {
            return SerializedAccountRegistry.parseFrom(input)
        } catch (exception: InvalidProtocolBufferException) {
            throw CorruptionException("Cannot read proto.", exception)
        }
    }

    override suspend fun writeTo(t: SerializedAccountRegistry, output: OutputStream) {
        return t.writeTo(output)
    }
}
object SessionRegistrySerializer : Serializer<SessionRegistry> {
    override val defaultValue: SessionRegistry = SessionRegistry.getDefaultInstance()

    override suspend fun readFrom(input: InputStream): SessionRegistry {
        try {
            return SessionRegistry.parseFrom(input)
        } catch (exception: InvalidProtocolBufferException) {
            throw CorruptionException("Cannot read proto.", exception)
        }
    }

    override suspend fun writeTo(t: SessionRegistry, output: OutputStream) {
        return t.writeTo(output)
    }
}

class App : Application(), Configuration.Provider {
    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder().build()

    lateinit var engineGroup: FlutterEngineGroup

    override fun onCreate() {
        super.onCreate()
        engineGroup = FlutterEngineGroup(this)
    }

    @Volatile
    private var accountStoreInstance: DataStore<SerializedAccountRegistry>? = null

    val accountStore: DataStore<SerializedAccountRegistry>
        get() = accountStoreInstance ?: synchronized(this) {
            accountStoreInstance ?: MultiProcessDataStoreFactory.create(
                serializer = AccountStoreSerializer,
                corruptionHandler = ReplaceFileCorruptionHandler {
                    Log.e("SerializedAccountRegistry", "Could not read accounts, recreating...", it)

                    SerializedAccountRegistry.getDefaultInstance()
                },
            ) {
                File(filesDir, "session.pb")
            }.also { accountStoreInstance = it }
        }

    val sessionStore: DataStore<SessionRegistry> by deviceProtectedDataStore(
        fileName = "session.pb",
        serializer = SessionRegistrySerializer,
        corruptionHandler = ReplaceFileCorruptionHandler {
            Log.e("SessionRegistry", "Could not read accounts, recreating...", it)

            SessionRegistry.getDefaultInstance()
        }
    )
}