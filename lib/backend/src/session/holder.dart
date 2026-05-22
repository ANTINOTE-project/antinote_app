import "dart:async";
import "dart:io";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/accounts/storage/base.dart";
import "package:antinote_app/backend/src/pigeon_posts/native_session.g.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/main.dart";
import "package:antinote_app/protos/account.pb.dart";

import "../helpers/antinote_account.dart";

final NativeSessionManager _sessionManager = NativeSessionManager();
final _nativeSessionManagerSupported = Platform.isAndroid;

class SessionDataHolder {
  PronoteSession? lastSeenSession;
  int? lastSeenSessionVersion;
  String? lastSeenAccountUid;
  Completer<void>? stateLock;
  bool dirty = false;

  SessionDataHolder({
    required this.lastSeenSession,
    required this.lastSeenSessionVersion,
    required this.lastSeenAccountUid,
    required this.stateLock,
  });

  SessionDataHolder.create([AntinoteAccount? account])
    : this(
        lastSeenSession: null,
        lastSeenSessionVersion: null,
        lastSeenAccountUid: account?.uid,
        stateLock: null,
      );

  Future<PronoteSession> relogin({required AccountStorage storage}) async {
    var account = (await storage.borrowAccountWithCredentials(lastSeenAccountUid!))!;

    final credentials = account.credentials;
    if (credentials == null) {
      throw Exception("No credentials linked to account ${account.uid}");
    }

    final (refreshCredentials: newCreds, session: session) = await credentials.login();

    account = account.setCredentials(newCreds);
    await storage.updateAccount(account, lastSeenAccountUid!);

    lastSeenSession = session;
    if (_nativeSessionManagerSupported) {
      lastSeenSessionVersion = await _sessionManager.registerSession(
        lastSeenAccountUid!,
        session.exportBinary(),
      );
    } else {
      lastSeenSessionVersion = 0;
    }
    dirty = true;

    return lastSeenSession!;
  }

  Future<PronoteSession> ensureSession({required AccountStorage storage, String? accountUid}) async {
    assert(
      lastSeenAccountUid != null || accountUid != null,
      "Tried to ensure session for an "
      "account UID we did not have...",
    );

    if (lastSeenSession != null && (accountUid == null || lastSeenAccountUid == accountUid)) {
      return lastSeenSession!;
    }

    if (accountUid != null) {
      lastSeenAccountUid = accountUid;
    }

    await relogin(storage: storage);

    return lastSeenSession!;
  }

  Future<T> runTask<T>({
    required FutureOr<PronoteSession> Function() sessionEnsurer,
    List<String> channels = const ["communication"],
    required RunCallback<T> callback,
  }) async {
    assert(
      lastSeenAccountUid != null,
      "Tried to run a task but we do not have "
      "the session's account UID",
    );

    late final ScheduledTask? task;

    if (_nativeSessionManagerSupported) {
      task = await _sessionManager.scheduleTask(lastSeenAccountUid!, channels, lastSeenSessionVersion);

      if (task.session != null && task.sessionVersion > (lastSeenSessionVersion ?? -1)) {
        lastSeenSessionVersion = task.sessionVersion;

        try {
          lastSeenSession = await PronoteSession.restoreBinary(task.session!);
          await _sessionManager.setCurrentAccountsListener([lastSeenAccountUid!]);
        } catch (e, st) {
          talker.error("Couldn't read the session sent by the manager", e, st);
        }

        dirty = true;
      }
    } else {
      task = null;
    }

    if (lastSeenSession == null) {
      if (_nativeSessionManagerSupported) {
        await _sessionManager.setCurrentAccountsListener([lastSeenAccountUid!]);
      }
      lastSeenSession = await sessionEnsurer();
      assert(
        lastSeenSession != null,
        "Called session ensurer but session is "
        "still missing",
      );

      dirty = true;
    }

    final beforeCounter = lastSeenSession!.stack.order(.communication);

    late T callbackResult;
    try {
      for (var curTry = 1; curTry <= 2; curTry++) {
        try {
          callbackResult = await callback.call(lastSeenSession!);

          break;
        } on SessionException {
          final errorCounter = lastSeenSession!.stack.order(.communication);
          talker.warning("Error counter at $errorCounter");

          await lastSeenSession!.access(const DisconnectionAccessor.unlogged());

          if (beforeCounter + 2 >= errorCounter && curTry == 1) {
            // Probably due to an expired session, retrying once.
            // TODO: Print information about the session exception.
            lastSeenSession = null;
            lastSeenSession = await sessionEnsurer();
            dirty = true;
          } else {
            // Caused by the actual callback. No need to retry...
            rethrow;
          }
        }
      }
    } on SessionException {
      lastSeenSession = null;
      dirty = true;

      rethrow;
    } finally {
      if (task != null) {
        final newVersion = await _sessionManager.finishTask(
          lastSeenAccountUid!,
          task.taskId,
          lastSeenSession?.exportBinary(),
        );

        lastSeenSessionVersion = newVersion;
      }
    }

    if (channels.contains("communication") && beforeCounter == lastSeenSession!.stack.order(.communication)) {
      talker.warning(
        "Callback did not send any request but still asked "
        "for communication channel...",
      );
    } else if (!channels.contains("communication") &&
        beforeCounter > lastSeenSession!.stack.order(.communication)) {
      talker.warning(
        "Callback sent communication requests but did not "
        "ask for the channel...",
      );
    }

    return callbackResult;
  }
}
