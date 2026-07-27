import "dart:async";
import "dart:io";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/backend/src/settings/networking.dart";
import "package:antinote_app/main.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/foundation.dart";

final NativeSessionManager _sessionManager = NativeSessionManager();
final _nativeSessionManagerSupported = Platform.isAndroid;

class SessionDataHolder extends ChangeNotifier {
  RemoteSession? _curSession;

  RemoteSession? get lastSeenSession => _curSession;
  set lastSeenSession(RemoteSession? newValue) {
    if (_curSession == newValue) return;

    final shouldNotify =
        newValue?.stack.sessionId != _curSession?.stack.sessionId;

    _curSession = newValue;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  int? lastSeenSessionVersion;
  String? lastSeenAccountUid;
  Completer<void>? stateLock;

  NetworkingSettings _settings;

  SessionDataHolder._({
    required this._curSession,
    required this.lastSeenSessionVersion,
    required this.lastSeenAccountUid,
    required this.stateLock,
    required this._settings,
  });

  SessionDataHolder.create({
    required NetworkingSettings settings,
    AntinoteAccount? account,
  }) : this._(
         curSession: null,
         lastSeenSessionVersion: null,
         lastSeenAccountUid: account?.uid,
         stateLock: null,
         settings: settings,
       );

  Future<RemoteSession> relogin({required AccountStorage storage}) async {
    var account = (await storage.borrowAccountWithCredentials(
      lastSeenAccountUid!,
    ))!;

    final credentials = account.credentials;
    if (credentials == null) {
      throw Exception("No credentials linked to account ${account.uid}");
    }

    final (refreshCredentials: newCreds, session: session) = await credentials
        .login(options: _settings.sessionOptions);

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

    return lastSeenSession!;
  }

  Future<RemoteSession> ensureSession({
    required AccountStorage storage,
    String? accountUid,
  }) async {
    assert(
      lastSeenAccountUid != null || accountUid != null,
      "Tried to ensure session for an "
      "account UID we did not have...",
    );

    if (lastSeenSession != null &&
        (accountUid == null || lastSeenAccountUid == accountUid)) {
      return lastSeenSession!;
    }

    if (accountUid != null) {
      lastSeenAccountUid = accountUid;
    }

    await relogin(storage: storage);

    return lastSeenSession!;
  }

  Future<T> runTask<T>({
    required FutureOr<RemoteSession> Function() sessionEnsurer,
    List<String> channels = const ["communication"],
    bool retry = false,
    required RunCallback<T> callback,
  }) async {
    assert(
      lastSeenAccountUid != null,
      "Tried to run a task but we do not have "
      "the session's account UID",
    );

    late final ScheduledTask? task;

    if (_nativeSessionManagerSupported) {
      task = await _sessionManager.scheduleTask(
        lastSeenAccountUid!,
        channels,
        lastSeenSessionVersion,
      );

      if (task.session != null &&
          task.sessionVersion > (lastSeenSessionVersion ?? -1)) {
        lastSeenSessionVersion = task.sessionVersion;

        try {
          lastSeenSession = await RemoteSession.restoreBinary(
            task.session!,
            options: _settings.sessionOptions,
          );
          await _sessionManager.setCurrentAccountsListener([
            lastSeenAccountUid!,
          ]);
        } catch (e, st) {
          talker.error("Couldn't read the session sent by the manager", e, st);
        }
      }
    } else {
      task = null;
    }

    bool needToApply = false;
    RemoteSession? currentlyAppliedSession = lastSeenSession;

    if (currentlyAppliedSession == null) {
      if (_nativeSessionManagerSupported) {
        await _sessionManager.setCurrentAccountsListener([lastSeenAccountUid!]);
      }
      currentlyAppliedSession = await sessionEnsurer();
      needToApply = true;
    }

    final beforeCounter = currentlyAppliedSession.stack.order(.communication);

    late T callbackResult;
    try {
      for (var curTry = retry ? 1 : 2; curTry <= 2; curTry++) {
        try {
          callbackResult = await callback.call(currentlyAppliedSession!);

          break;
        } on SessionException {
          final errorCounter = currentlyAppliedSession!.stack.order(
            .communication,
          );
          talker.warning("Error counter at $errorCounter");

          await currentlyAppliedSession.access(
            const DisconnectionAccessor.unlogged(),
          );

          if (beforeCounter + 2 >= errorCounter && curTry == 1) {
            talker.info("Restarting session to retry callback...");

            // Probably due to an expired session, retrying once.
            // TODO: Print information about the session exception.
            _curSession = null;
            currentlyAppliedSession = await sessionEnsurer();
            needToApply = true;
          } else {
            // Caused by the actual callback. No need to retry...
            rethrow;
          }
        }
      }
    } on SessionException {
      lastSeenSession = null;

      rethrow;
    } finally {
      if (task != null) {
        final newVersion = await _sessionManager.finishTask(
          lastSeenAccountUid!,
          task.taskId,
          currentlyAppliedSession?.exportBinary(),
        );

        lastSeenSessionVersion = newVersion;
      }
    }

    if (needToApply) {
      lastSeenSession = currentlyAppliedSession;
    }

    if (lastSeenSession != null &&
        channels.contains("communication") &&
        beforeCounter == lastSeenSession!.stack.order(.communication)) {
      talker.warning(
        "Callback did not send any request but still asked "
        "for communication channel...",
      );
    } else if (lastSeenSession != null &&
        !channels.contains("communication") &&
        beforeCounter > lastSeenSession!.stack.order(.communication)) {
      talker.warning(
        "Callback sent communication requests but did not "
        "ask for the channel...",
      );
    }

    return callbackResult;
  }
}
