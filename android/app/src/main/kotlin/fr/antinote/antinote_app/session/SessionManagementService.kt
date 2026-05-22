package fr.antinote.antinote_app.session

import android.accounts.AccountManager
import android.app.Service
import android.content.Intent
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.Looper
import android.os.Message
import android.os.Messenger
import android.os.Process
import android.os.RemoteException
import android.util.Log
import fr.antinote.antinote_app.R
import fr.antinote.antinote_app.auth.LoginManager
import fr.helomri.studies_management.antinote_ui.pigeon_posts.PollingState
import java.lang.ref.WeakReference
import java.util.LinkedList
import java.util.Queue
import kotlin.io.encoding.Base64


/**
 * Registers a new client to receive updates on the different accounts.
 *
 * Parameters are:
 * - `accounts` (string list, optional): The list of accounts the client wants to listen to.
 * Defaults to all.
 *
 * Returns:
 * - `client_id` (long): The ID of the client that was just registered.
 */
const val MSG_REGISTER_CLIENT = 1

/**
 * Unregisters an existing client to disconnect from the service.
 *
 * Parameters are:
 * - `client_id` (long): The ID of the client to unregister.
 *
 * Returns:
 * - `successful` (boolean): Whether the client was successfully unregistered.
 */
const val MSG_UNREGISTER_CLIENT = 2

/**
 * Edits an existing client's parameters.
 *
 * Parameters are:
 * - `client_id` (long): The ID of the client to edit.
 * - `accounts` (string array, optional): The list of accounts the client receives updates for.
 * Defaults to all.
 * - `listen_to` (string array, optional): The list of fields the client receives updates for.
 * Including `session_id` is recommended.
 *
 * Returns:
 * - `successful` (boolean): Whether the change was successful (`false` meaning the client doesn't
 * exist)
 */
const val MSG_EDIT_CLIENT = 3

/**
 * Asks to be put in the queue for an account UID to execute a task.
 *
 * Parameters are:
 * - `account` (string): The account UID for the task that's being run.
 * - `channels` (string array): List of IDs for the different channels required for the task to run.
 * - `last_session_version` (long, optional): The ID of the last seen version for the session that's asked.
 * - `client_id` (long): The ID of the client used to schedule this task.
 * - `client_task_id` (long): An ID provided by the client for the service to give back in the
 * response to correctly identify the task.
 *
 * Returns (when the client can run its task):
 * - `session` (byte array, optional): The serialized session the client uses to run its task. This is
 * included in the response if the client is outdated.
 * - `session_version` (long): The latest version of the session.
 * - `client_task_id` (long): Identical to the one in the request.
 * - `task_id` (long): The ID of the task that was just scheduled.
 */
const val MSG_SCHEDULE_TASK = 4

/**
 * Marks the current task as being finished so that the next one can run.
 *
 * Parameters are:
 * - `account` (string): The ID of the account for which the task was just finished.
 * - `task_id` (long): The ID of the task that just finished.
 * - `new_session` (byte array, optional): The new serialized session. Only include if it changed during
 * the task.
 *
 * Returns:
 * - `task_id` (long): The ID of the task that was just finished.
 * - `new_session_version` (long): The new latest version of the session.
 */
const val MSG_FINISH_TASK = 5

/**
 * Explicitly updates the session for an account. At the same time, we parse the JSON fields and
 * do our own diff to tell clients that listened to fields for the updated account that the session
 * got updated.
 *
 * Parameters are:
 * - `account` (string): The ID of the account whose session will get updated.
 * - `client_task_id` (long): The ID of the request set by the client.
 * - `new_session` (byte array): The new serialized session. This is a patch we put onto the existing
 * session (if there was any).
 *
 * Returns:
 * - `client_task_id` (long): Identical to the one in the request.
 * - `new_session_version` (long): The new latest version of the session.
 */
const val MSG_UPDATE_SESSION = 6

/**
 * Broadcast server-side-only message to any client listening to the account specified.
 *
 * Returns:
 * - `account` (string): The ID of the account which was updated.
 * - `polling_state` (int): The polling state for the account.
 * - `server_signature` (string, optional): The current enforced signature from the server.
 */
const val MSG_POLLING_UPDATED = 7

/**
 * Fetches the state of polling for a specific account.
 *
 * Parameters are:
 * - `account` (string): The ID of the account whose polling state will get fetched.
 *
 * Returns:
 * - `account` (string): The ID of the account whose polling state got fetched.
 * - `state` (int): The polling state for the account (see [fr.helomri.studies_management.antinote_ui.pigeon_posts.PollingState]).
 */
const val MSG_GET_POLLING_STATE = 8

/**
 * Updates the state of polling for a specific account.
 *
 * Parameters are:
 * - `account` (string): The ID of the account whose polling state will get updated.
 * - `state` (int): The new polling state (see [fr.helomri.studies_management.antinote_ui.pigeon_posts.PollingState]).
 * - `server_signature` (string, optional): The newly enforced server signature, if available.
 *
 * Returns:
 * - `successful` (boolean): Whether the change was successful.
 */
const val MSG_UPDATE_POLLING_STATE = 9

/**
 * Broadcast message to any client listening to the account specified. We work on a FIFO system.
 *
 * Returns:
 * - `confirmed` (boolean): Whether the client will get for sure the job (in which state the client
 * MUST start polling and MUST NOT answer this message).
 * - `account` (string): The ID of the account the client got asked to do polling for.
 *
 * Parameters are:
 * - `client_id` (long): The ID of the client that agreed or not to take the job.
 * - `account` (String): The ID of the relevant account.
 * - `agree` (boolean): Whether the client agrees to take the job.
 */
const val MSG_ASK_TO_TAKE_POLLING = 10

class SessionManagementService : Service() {
    companion object {
        private const val TAG = "SessionManageService"
        private const val AUTH_TOKEN_TYPE = "session"
    }

    internal data class SessionManagementClient(
        var listenedAccounts: List<String>?,
        val dest: Messenger
    )

    private var nextClientId = 0L
    private val clients = mutableMapOf<Long, SessionManagementClient>()

    internal data class SessionTask(
        val id: Long,
        val ownerClientId: Long,
        val clientTaskId: Long,
        val scheduler: Messenger,
        val channels: List<String>,
        val accountId: String
    )

    internal data class AccountSessionManager(
        val busyChannels: MutableSet<String> = mutableSetOf(),
        val lockOwners: MutableMap<Long, SessionTask> = mutableMapOf(),
        val taskQueue: Queue<SessionTask> = LinkedList(),
        var latestVersion: Long = 0L,
        var pollingState: PollingState = PollingState.UNAVAILABLE,
        var pollingOwner: Long? = null
    )

    private var nextTaskId = 0L
    private val accountSessionManagers = mutableMapOf<String, AccountSessionManager>()

    private fun createOrGetManager(
        accountId: String,
        advertise: Boolean = true
    ): AccountSessionManager? {
        val manager = accountSessionManagers.getOrPut(accountId) {
            val am = AccountManager.get(this)
            val account = am.accounts.firstOrNull {
                it.type == getString(R.string.account_type) && am.getUserData(
                    it,
                    LoginManager.KEY_UID
                ) == accountId
            }
            if (account == null) return null
            AccountSessionManager()
        }

        if (manager.pollingState == PollingState.UNAVAILABLE && advertise) {
            advertisePollingJob(accountId)
        }

        return manager
    }

    private fun advertisePollingJob(accountId: String) {
        Log.i(TAG, "Advertising polling job...")

        val msg = Message.obtain(null, MSG_ASK_TO_TAKE_POLLING)
        msg.data.putBoolean("confirmed", false)
        msg.data.putString("account", accountId)
        msg.replyTo = messenger

        for (client in clients) {
            if (client.value.listenedAccounts?.contains(accountId) ?: false) {
                Log.i(TAG, "Sending ad to client ${client.key}")
                client.value.dest.send(msg)
            }
        }
    }

    private fun updatePollingState(
        accountId: String,
        newPollingState: PollingState,
        newServerSignature: String?
    ) {
        val manager = createOrGetManager(accountId)
        if (manager == null) {
            Log.w(TAG, "UpdatePollingState: Manager not found for account $accountId")
            return
        }

        manager.pollingState = newPollingState

        sendAccountUpdate(accountId, newServerSignature)
    }

    private fun sendAccountUpdate(accountId: String, newServerSignature: String?) {
        val manager = createOrGetManager(accountId)
        if (manager == null) {
            Log.w(TAG, "SendAccountUpdate: Manager not found for account $accountId")
            return
        }

        val msg = Message.obtain(null, MSG_POLLING_UPDATED)
        msg.data.putString("account", accountId)
        msg.data.putInt("polling_state", manager.pollingState.raw)
        if (newServerSignature != null) {
            msg.data.putString("server_signature", newServerSignature)
        }

        for (client in clients) {
            if (client.value.listenedAccounts?.contains(accountId) ?: false) {
                client.value.dest.send(msg)
            }
        }
    }

    private fun processTaskQueue(manager: AccountSessionManager): List<SessionTask> {
        val startedTasks = mutableListOf<SessionTask>()
        val iter = manager.taskQueue.iterator()

        while (iter.hasNext()) {
            val candidate = iter.next()
            if (candidate.channels.none { manager.busyChannels.contains(it) }) {
                manager.busyChannels.addAll(candidate.channels)
                manager.lockOwners[candidate.id] = candidate
                iter.remove()
                startedTasks.add(candidate)
            }
        }
        return startedTasks
    }

    private fun scheduleTask(
        accountId: String,
        channels: List<String>,
        scheduler: Messenger,
        clientTaskId: Long,
        ownerClientId: Long
    ): Long? {
        val manager = createOrGetManager(accountId)

        if (manager == null) {
            Log.w(TAG, "ScheduleTask: Manager not found for account $accountId")
            return null
        }

        val taskId = nextTaskId++
        val newTask = SessionTask(
            id = taskId,
            ownerClientId = ownerClientId,
            clientTaskId = clientTaskId,
            scheduler = scheduler,
            channels = channels,
            accountId = accountId
        )

        // We can directly run the task without waiting.
        if (channels.none {
                manager.busyChannels.contains(it)
            }) {
            manager.busyChannels.addAll(channels)
            manager.lockOwners[taskId] = newTask
            return taskId
        } else {
            manager.taskQueue.add(
                newTask
            )
            return null
        }
    }

    private fun updateSession(accountId: String, newSession: ByteArray): Long {
        val manager = createOrGetManager(accountId)

        if (manager == null) {
            Log.w(TAG, "UpdateSession: Manager not found for account $accountId")
            return -1L
        }

        val am = AccountManager.get(this)
        val account = am.accounts.firstOrNull {
            it.type == getString(R.string.account_type) &&
                    am.getUserData(it, LoginManager.KEY_UID) == accountId
        }
        if (account != null) {

            am.setAuthToken(account, AUTH_TOKEN_TYPE, Base64.encode(newSession))
            manager.latestVersion++
        }

        return manager.latestVersion
    }

    private fun finishTask(
        accountId: String,
        taskId: Long,
        newSession: ByteArray?
    ): Pair<Long, List<SessionTask>?> {
        val manager = createOrGetManager(accountId)

        if (manager == null) {
            Log.w(TAG, "FinishTask: Manager not found for account $accountId")
            return Pair(-1L, null)
        }

        if (newSession != null) {
            updateSession(accountId, newSession)
        }

        val task = manager.lockOwners.remove(taskId)
        if (task == null) {
            Log.w(TAG, "FinishTask: Task ID $taskId does not own any locks.")
            return Pair(manager.latestVersion, null)
        }

        manager.busyChannels.removeAll(task.channels.toSet())

        val newTasks = processTaskQueue(manager)

        return Pair(manager.latestVersion, newTasks)
    }

    private fun cleanupDeadClient(deadClientId: Long) {
        Log.i(TAG, "Cleaning up dead client ID: $deadClientId")

        clients.remove(deadClientId)
        accountSessionManagers.values.forEach { manager ->
            if (manager.pollingOwner == deadClientId) {
                manager.pollingState = PollingState.UNAVAILABLE
                manager.pollingOwner = null
            }

            val queueIter = manager.taskQueue.iterator()
            while (queueIter.hasNext()) {
                if (queueIter.next().ownerClientId == deadClientId) {
                    queueIter.remove()
                }
            }

            val activeDeadTasks =
                manager.lockOwners.filter { it.value.ownerClientId == deadClientId }

            activeDeadTasks.keys.forEach { taskId ->
                val task = manager.lockOwners.remove(taskId)
                if (task != null) {
                    Log.i(TAG, "Force finishing task $taskId due to client death.")
                    manager.busyChannels.removeAll(task.channels.toSet())
                }
            }

            val newlyScheduled = processTaskQueue(manager)
            newlyScheduled.forEach { task ->
                IncomingHandler(WeakReference(this), workerThread.looper).sendTaskScheduledMessage(
                    target = task.scheduler,
                    clientTaskId = task.clientTaskId,
                    taskId = task.id,
                    lastSessionVersion = manager.latestVersion,
                    accountId = task.accountId
                )
            }
        }
    }

    private lateinit var workerThread: HandlerThread
    private lateinit var messenger: Messenger

    override fun onCreate() {
        super.onCreate()

        workerThread = HandlerThread("SessionServiceWorker", Process.THREAD_PRIORITY_BACKGROUND)
        workerThread.start()

        messenger = Messenger(IncomingHandler(WeakReference(this), workerThread.looper))
    }

    override fun onBind(intent: Intent?): IBinder? = messenger.binder

    override fun onDestroy() {
        workerThread.quitSafely()
        super.onDestroy()
    }

    class IncomingHandler(
        val serviceRef: WeakReference<SessionManagementService>,
        looper: Looper
    ) : Handler(looper), IBinder.DeathRecipient {
        val service: SessionManagementService?
            get() = serviceRef.get()

        fun sendTaskScheduledMessage(
            target: Messenger,
            clientTaskId: Long,
            taskId: Long,
            lastSessionVersion: Long,
            accountId: String
        ) {
            val svc = service ?: return
            val msg = obtainMessage(MSG_SCHEDULE_TASK)

            if (!svc.accountSessionManagers.containsKey(accountId)) {
                msg.arg1 = 1 // Signifies there's an error. (TODO: Document that)
                msg.data.putLong("client_task_id", clientTaskId)
                msg.data.putString("account", accountId)
                try {
                    target.send(msg)
                } catch (_: RemoteException) {
                }
                return
            }

            val am = AccountManager.get(svc)
            val account = am.accounts.firstOrNull {
                it.type == svc.getString(R.string.account_type) && am.getUserData(
                    it,
                    LoginManager.KEY_UID
                ) == accountId
            }

            val manager = svc.accountSessionManagers[accountId]!!

            val at = am.peekAuthToken(account, AUTH_TOKEN_TYPE)
            if (account != null && at != null && lastSessionVersion < manager.latestVersion) {

                msg.data.putByteArray(
                    "session",
                    Base64.decode(at)
                )
            }

            msg.data.putLong("session_version", manager.latestVersion)
            msg.data.putLong("client_task_id", clientTaskId)
            msg.data.putLong("task_id", taskId)

            try {
                target.send(msg)
            } catch (_: RemoteException) {
                Log.i(
                    TAG, "Client died before receiving schedule confirmation."
                )
            }
        }

        override fun handleMessage(msg: Message) {
            val svc = service ?: return

            if (msg.replyTo == null) {
                Log.i(TAG, "Received a message without a replyTo... ${msg.what} ${msg.data}")
            }

            when (msg.what) {
                MSG_REGISTER_CLIENT -> {
                    val accounts = msg.data.getStringArray("accounts")?.asList()

                    val clientId = svc.nextClientId++

                    svc.clients[clientId] = SessionManagementClient(
                        listenedAccounts = accounts,
                        dest = msg.replyTo
                    )

                    try {
                        msg.replyTo.binder.linkToDeath(this, 0)
                    } catch (_: RemoteException) {
                        svc.clients.remove(clientId)
                        return
                    }

                    val res = Message.obtain(null, MSG_REGISTER_CLIENT)
                    res.data.putLong("client_id", clientId)

                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }
                }

                MSG_EDIT_CLIENT -> {
                    val clientId = msg.data.getLong("client_id", -1L)
                    val client = svc.clients[clientId]

                    if (client == null) {
                        val res = obtainMessage(MSG_EDIT_CLIENT)
                        res.data.putBoolean("successful", false)
                        try {
                            msg.replyTo.send(res)
                        } catch (_: RemoteException) {
                        }
                        return
                    }

                    // Safe parsing
                    client.listenedAccounts =
                        msg.data.getStringArray("accounts")?.toList() ?: client.listenedAccounts

                    val res = obtainMessage(MSG_EDIT_CLIENT)
                    res.data.putBoolean("successful", true)
                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }
                }

                MSG_UNREGISTER_CLIENT -> {
                    val clientId = msg.data.getLong("client_id", -1L)
                    svc.cleanupDeadClient(clientId)

                    val res = obtainMessage(MSG_UNREGISTER_CLIENT)
                    res.data.putBoolean("successful", true)
                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }
                }

                MSG_SCHEDULE_TASK -> {
                    val accountId = msg.data.getString("account")
                    val channels = msg.data.getStringArray("channels")?.asList()
                    val clientTaskId = msg.data.getLong("client_task_id", -1L)
                    val ownerClientId = msg.data.getLong("client_id", -1L)

                    if (accountId == null || channels == null || clientTaskId == -1L || ownerClientId == -1L) {
                        Log.e(
                            TAG,
                            "Schedule Task failed: Missing required fields (account, channels, client_task_id, or client_id)"
                        )
                        return
                    }

                    if (!svc.clients.containsKey(ownerClientId)) {
                        Log.e(TAG, "Schedule Task failed: Invalid Client ID provided")
                        return
                    }

                    val resultTaskId = svc.scheduleTask(
                        accountId = accountId,
                        channels = channels,
                        scheduler = msg.replyTo,
                        clientTaskId = clientTaskId,
                        ownerClientId = ownerClientId
                    )

                    if (resultTaskId != null && resultTaskId != -1L) {
                        sendTaskScheduledMessage(
                            msg.replyTo,
                            clientTaskId,
                            resultTaskId,
                            msg.data.getLong("last_session_version", -1L),
                            accountId
                        )
                    }
                }

                MSG_FINISH_TASK -> {
                    val accountId = msg.data.getString("account")
                    val taskId = msg.data.getLong("task_id", -1L)

                    if (accountId == null || taskId == -1L) {
                        Log.e(TAG, "Finish Task failed: Missing account or task_id")
                        return
                    }

                    val result = svc.finishTask(
                        accountId = accountId,
                        taskId = taskId,
                        newSession = msg.data.getByteArray("new_session")
                    )

                    val res = obtainMessage(MSG_FINISH_TASK)
                    res.data.putLong("task_id", taskId)
                    res.data.putLong("new_session_version", result.first)

                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }

                    val newTasks = result.second
                    newTasks?.forEach { newTask ->
                        sendTaskScheduledMessage(
                            target = newTask.scheduler,
                            clientTaskId = newTask.clientTaskId, // Use clientTaskId, not id (which is internal)
                            taskId = newTask.id,
                            lastSessionVersion = result.first,
                            accountId = newTask.accountId
                        )
                    }
                }

                MSG_UPDATE_SESSION -> {
                    val accountId = msg.data.getString("account")
                    val clientTaskId = msg.data.getLong("client_task_id", -1L)
                    val newSession = msg.data.getByteArray("new_session")

                    if (accountId == null || clientTaskId == -1L || newSession == null) {
                        Log.e(
                            TAG,
                            "Update Session failed: Missing account, client_task_id, or task_id"
                        )
                        return
                    }

                    val result = svc.updateSession(accountId, newSession)

                    val res = obtainMessage(MSG_UPDATE_SESSION)
                    res.data.putLong("client_task_id", clientTaskId)
                    res.data.putLong("new_session_version", result)

                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }
                }

                MSG_POLLING_UPDATED -> {
                    Log.e(TAG, "Received a server-only message (MSG_SESSION_UPDATED)")
                    return
                }

                MSG_GET_POLLING_STATE -> {
                    val accountId = msg.data.getString("account")

                    if (accountId == null) {
                        Log.e(TAG, "Get Polling State failed: Missing account")
                        return
                    }

                    val manager = svc.createOrGetManager(accountId)

                    if (manager == null) {
                        Log.w(TAG, "GetPollingState: Manager not found for account $accountId")
                        return
                    }

                    val res = obtainMessage(MSG_GET_POLLING_STATE)
                    res.data.putInt("state", manager.pollingState.raw)
                    res.data.putString("account", accountId)

                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }
                }

                MSG_UPDATE_POLLING_STATE -> {
                    val accountId = msg.data.getString("account")
                    val state = PollingState.ofRaw(msg.data.getInt("state"))
                    val serverSignature = msg.data.getString("server_signature")
                    if (accountId == null || !msg.data.containsKey("state") || !msg.data.containsKey(
                            "server_signature"
                        )
                    ) {
                        Log.e(
                            TAG,
                            "Update Polling State failed: Missing account, state, or server_signature"
                        )
                        return
                    }

                    if (state == null) {
                        Log.e(TAG, "Unknown PollingState ID: ${msg.data.getInt("state")}")
                        return
                    }

                    svc.updatePollingState(accountId, state, serverSignature)

                    val res = obtainMessage(MSG_UPDATE_POLLING_STATE)
                    res.data.putBoolean("successful", true)

                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }
                }

                MSG_ASK_TO_TAKE_POLLING -> {
                    val clientId = msg.data.getLong("client_id")
                    val accountId = msg.data.getString("account")
                    val agree = msg.data.getBoolean("agree")

                    if (!msg.data.containsKey("client_id") || accountId == null || !msg.data.containsKey(
                            "agree"
                        )
                    ) {
                        Log.e(
                            TAG,
                            "Ask To Take Polling failed: Missing client_id, account_id, or agree"
                        )
                        return
                    }

                    if (!agree) {
                        return
                    }

                    val manager = svc.createOrGetManager(accountId, false)
                    if (manager == null) {
                        Log.e(TAG, "No manager for $accountId")
                        return
                    }


                    if (manager.pollingState != PollingState.UNAVAILABLE || manager.pollingOwner != null) {
                        Log.w(
                            TAG, "Polling job already got taken by a client, but someone " +
                                    "else agreed to do it"
                        )
                        return
                    }

                    manager.pollingOwner = clientId
                    manager.pollingState = PollingState.ALIVE

                    val res = obtainMessage(MSG_ASK_TO_TAKE_POLLING)
                    res.data.putBoolean("confirmed", true)
                    res.data.putString("account", accountId)

                    try {
                        msg.replyTo.send(res)
                    } catch (_: RemoteException) {
                    }
                }

                else -> super.handleMessage(msg)
            }
        }

        override fun binderDied() {
            Log.i(TAG, "Binder died, scheduling cleanup.")
        }

        override fun binderDied(who: IBinder) {
            super.binderDied(who)

            post {
                val deadEntry =
                    service?.clients?.entries?.find { it.value.dest.binder == who } ?: return@post
                service?.cleanupDeadClient(deadEntry.key)
            }
        }
    }
}