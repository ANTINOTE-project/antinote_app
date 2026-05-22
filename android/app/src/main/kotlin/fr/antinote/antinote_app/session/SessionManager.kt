package fr.antinote.antinote_app.session

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.Message
import android.os.Messenger
import android.os.RemoteException
import android.util.Log
import fr.helomri.studies_management.antinote_ui.pigeon_posts.NativeSessionManager
import fr.helomri.studies_management.antinote_ui.pigeon_posts.PollingManager
import fr.helomri.studies_management.antinote_ui.pigeon_posts.PollingState
import fr.helomri.studies_management.antinote_ui.pigeon_posts.ScheduledTask
import io.flutter.plugin.common.BinaryMessenger

class SessionManager(val context: Context, binaryMessenger: BinaryMessenger) :
    NativeSessionManager, ServiceConnection {
    init {
        doBindService()
    }

    private var isBound = false
    private var mService: Messenger? = null
    private var clientId: Long? = null
    private var nextClientTaskId = 0L
    var currentAccountUids: List<String> = listOf()
    private val schedulingTasks: MutableMap<Long, (Result<ScheduledTask>) -> Unit> = mutableMapOf()
    private val finishingTasks: MutableMap<Long, (Result<Long?>) -> Unit> = mutableMapOf()
    private val updatingSessions: MutableMap<Long, (Result<Long>) -> Unit> = mutableMapOf()
    private val gettingPollingState: MutableMap<String, MutableList<(Result<PollingState>) -> Unit>> =
        mutableMapOf()

    private val messenger = Messenger(IncomingHandler(this))
    private val flutterApi = PollingManager(binaryMessenger)

    internal class IncomingHandler(val manager: SessionManager) :
        Handler(Looper.myLooper() ?: Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            when (msg.what) {
                MSG_REGISTER_CLIENT -> {
                    manager.clientId = msg.data.getLong("client_id")
                }

                MSG_UNREGISTER_CLIENT -> {
                    manager.clientId = null
                }

                MSG_SCHEDULE_TASK -> {
                    val session = msg.data.getByteArray("session")
                    val sessionVersion = msg.data.getLong("session_version")
                    val clientTaskId = msg.data.getLong("client_task_id")
                    val taskId = msg.data.getLong("task_id")

                    if (!manager.schedulingTasks.containsKey(clientTaskId)) {
                        Log.w(
                            TAG, "Received schedule confirmation for a task we did not " +
                                    "await."
                        )
                        return
                    }

                    manager.schedulingTasks.remove(clientTaskId)!!(
                        Result.success(
                            ScheduledTask(
                                session = session,
                                sessionVersion = sessionVersion,
                                taskId = taskId
                            )
                        )
                    )
                }

                MSG_FINISH_TASK -> {
                    val taskId = msg.data.getLong("task_id")
                    val newSessionVersion = msg.data.getLong("new_session_version")

                    if (!manager.finishingTasks.containsKey(taskId)) {
                        Log.w(
                            TAG, "Received finish confirmation for a task we did not " +
                                    "await."
                        )
                        return
                    }

                    manager.finishingTasks.remove(taskId)!!(
                        Result.success(newSessionVersion)
                    )
                }

                MSG_UPDATE_SESSION -> {
                    val clientTaskId = msg.data.getLong("client_task_id")
                    val newSessionVersion = msg.data.getLong("new_session_version")

                    if (!manager.updatingSessions.containsKey(clientTaskId)) {
                        Log.w(
                            TAG, "Received update confirmation for a task we did not " +
                                    "await."
                        )
                        return
                    }

                    manager.updatingSessions.remove(clientTaskId)!!(
                        Result.success(newSessionVersion)
                    )
                }

                MSG_GET_POLLING_STATE -> {
                    val state = PollingState.ofRaw(msg.data.getInt("state"))!!
                    val accountId = msg.data.getString("account")!!

                    if (manager.gettingPollingState[accountId].isNullOrEmpty()) {
                        Log.w(
                            TAG,
                            "Received polling state fetching results but did not await any..."
                        )
                        return
                    }

                    manager.gettingPollingState[accountId]!!.forEach {
                        it.invoke(Result.success(state))
                    }
                }

                MSG_UPDATE_POLLING_STATE -> {
                    val successful = msg.data.getBoolean("successful")

                    if (!successful) {
                        Log.w(TAG, "Invalid polling state update.")
                    }
                }

                MSG_ASK_TO_TAKE_POLLING -> {
                    val confirmed = msg.data.getBoolean("confirmed")
                    val accountId = msg.data.getString("account")!!

                    if (confirmed) {
                        manager.flutterApi.startPolling(accountId) {
                            if (it.isFailure) {
                                Log.e(
                                    TAG,
                                    "Couldn't start polling for account $accountId",
                                    it.exceptionOrNull()
                                )
                            }
                        }
                    } else {
                        manager.flutterApi.askToTakePolling(accountId) { agree ->
                            val res = obtainMessage(MSG_ASK_TO_TAKE_POLLING)
                            res.data.putLong("client_id", manager.clientId!!)
                            res.data.putString("account", accountId)
                            res.data.putBoolean("agree", agree.getOrNull() ?: false)
                            res.replyTo = manager.messenger

                            try {
                                manager.mService?.send(res)
                            } catch (_: RemoteException) {
                            }
                        }
                    }
                }

                else -> super.handleMessage(msg)
            }
        }
    }

    override fun onServiceConnected(
        name: ComponentName?,
        service: IBinder?
    ) {
        mService = Messenger(service!!)
        try {
            val msg = Message.obtain(null, MSG_REGISTER_CLIENT)
            msg.data.putStringArray("accounts", currentAccountUids.toTypedArray())
            msg.replyTo = this@SessionManager.messenger
            mService?.send(msg)
        } catch (_: RemoteException) {
        }
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        mService = null
        clientId = null

        val e = RemoteException("Got disconnected from service before we got a response.")

        for (entry in finishingTasks.values + updatingSessions.values) {
            entry.invoke(Result.failure(e))
        }
        for (entry in schedulingTasks.values) {
            entry.invoke(Result.failure(e))
        }

        finishingTasks.clear()
        updatingSessions.clear()
        schedulingTasks.clear()
    }


    fun doBindService() {
        context.bindService(
            Intent(context, SessionManagementService::class.java),
            this,
            Context.BIND_AUTO_CREATE
        )
        isBound = true
    }

    fun doUnbindService() {
        if (isBound) {
            if (mService != null) {
                try {
                    val msg = Message.obtain(null, MSG_UNREGISTER_CLIENT)
                    msg.data.putLong("client_id", clientId!!)
                    msg.replyTo = this@SessionManager.messenger
                } catch (_: RemoteException) {
                }
            }

            context.unbindService(this)
        }
    }


    override fun setCurrentAccountsListener(accountUid: List<String>) {
        currentAccountUids = accountUid
        if (!isBound) {
            doBindService()
        } else {
            val msg = Message.obtain(null, MSG_EDIT_CLIENT)
            msg.data.putLong("client_id", clientId!!)
            msg.data.putStringArray("accounts", accountUid.toTypedArray())

            msg.replyTo = this@SessionManager.messenger

            try {
                mService?.send(msg)
            } catch (_: RemoteException) {
            }
        }
    }

    override fun scheduleTask(
        accountUid: String,
        channels: List<String>,
        lastSessionVersion: Long?,
        callback: (Result<ScheduledTask>) -> Unit
    ) {
        if (!isBound) doBindService()

        val clientTaskId = nextClientTaskId++
        val msg = Message.obtain(null, MSG_SCHEDULE_TASK)

        msg.data.putString("account", accountUid)
        msg.data.putStringArray("channels", channels.toTypedArray())
        if (lastSessionVersion != null) {
            msg.data.putLong("last_session_version", lastSessionVersion)
        }
        msg.data.putLong("client_id", clientId!!)
        msg.data.putLong("client_task_id", clientTaskId)

        msg.replyTo = this@SessionManager.messenger

        schedulingTasks[clientTaskId] = callback

        try {
            mService?.send(msg)
        } catch (e: RemoteException) {
            schedulingTasks.remove(clientTaskId)
            callback(Result.failure(e))
        }
    }

    override fun finishTask(
        accountUid: String,
        taskId: Long,
        newSession: ByteArray?,
        callback: (Result<Long?>) -> Unit
    ) {
        if (!isBound) doBindService()

        val msg = Message.obtain(null, MSG_FINISH_TASK)
        msg.data.putString("account", accountUid)
        msg.data.putLong("task_id", taskId)
        if (newSession != null) {
            msg.data.putByteArray("new_session", newSession)
        }

        msg.replyTo = this@SessionManager.messenger

        finishingTasks[taskId] = callback

        try {
            mService?.send(msg)
        } catch (e: RemoteException) {
            finishingTasks.remove(taskId)
            callback(Result.failure(e))
        }
    }

    override fun registerSession(
        accountUid: String,
        session: ByteArray,
        callback: (Result<Long>) -> Unit
    ) {
        if (!isBound) doBindService()

        val clientTaskId = nextClientTaskId++
        val msg = Message.obtain(null, MSG_UPDATE_SESSION)
        msg.data.putString("account", accountUid)
        msg.data.putLong("client_task_id", clientTaskId)
        msg.data.putByteArray("new_session", session)

        msg.replyTo = this@SessionManager.messenger

        updatingSessions[clientTaskId] = callback

        try {
            mService?.send(msg)
        } catch (e: RemoteException) {
            updatingSessions.remove(clientTaskId)
            callback(Result.failure(e))
        }
    }

    override fun getPollingState(
        accountUid: String,
        callback: (Result<PollingState>) -> Unit
    ) {
        if (!isBound) doBindService()

        val msg = Message.obtain(null, MSG_GET_POLLING_STATE)
        msg.data.putString("account", accountUid)
        msg.replyTo = this@SessionManager.messenger

        gettingPollingState.putIfAbsent(accountUid, mutableListOf())
        gettingPollingState[accountUid]!!.add(callback)

        try {
            mService?.send(msg)
        } catch (e: RemoteException) {
            gettingPollingState[accountUid]!!.remove(callback)
            callback(Result.failure(e))
        }
    }

    override fun updatePollingState(
        accountUid: String,
        newState: PollingState,
        newServerSignature: String?
    ) {
        if (!isBound) doBindService()

        val msg = Message.obtain(null, MSG_UPDATE_POLLING_STATE)
        msg.data.putString("account", accountUid)
        msg.data.putInt("state", newState.raw)
        msg.data.putString("server_signature", newServerSignature)
        msg.replyTo = this@SessionManager.messenger

        try {
            mService?.send(msg)
        } catch (_: RemoteException) {

        }
    }

    companion object {
        private const val TAG = "SessionManager"
    }
}