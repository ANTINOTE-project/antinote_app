import 'dart:async';
import 'dart:io';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/data/src/accounts/storage/base.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_session.g.dart';
import 'package:antinote_app/data/src/utils/antinote_account.dart';

// TODO: Move that to centralized place (it is duplicated in base.dart).
final NativeSessionManager _sessionManager = NativeSessionManager();
final _nativeSessionManagerSupported = Platform.isAndroid;

typedef SessionTaskCallback<T> = FutureOr<T> Function(RemoteSession session);

/// The states for which we consider a session could still be alive.
const _validSessionPollingStates = <PollingState>[
  .alive,
  .paused,
  .unavailable,
];

final class const RegisterableAccount({
  required final SessionWrapper wrapper,
  required final AntinoteAccount account,
});

final class const _SessionState({
  required final RemoteSession session,
  required final PollingState polling,
  required final int? version,
});

final class SessionWrapper({required final String accountUid}) {
  Completer<void>? _loginLock;
  final Map<String, Completer<void>?> _taskLocks = {};
  _SessionState? _state;

  RemoteSession? get unsafeSession => _state?.session;

  static RegisterableAccount register(
    LoginResult result,
    Credentials baseCredentials,
  ) {
    final account =
        (result.session.stack.demo
                ? baseCredentials
                : result.credentials ?? baseCredentials)
            .asAntinoteAccount(result.session);
    final wrapper = SessionWrapper(accountUid: account.uid);
    wrapper._state = .new(
      session: result.session,
      polling: .unavailable,
      version: null,
    );

    return .new(wrapper: wrapper, account: account);
  }

  Future<RemoteSession> ensureSession({
    required AccountStorage storage,
    required SessionOptions options,
    bool force = false,
  }) async {
    while (_loginLock != null) {
      await _loginLock!.future;
    }

    if (_state != null &&
        _validSessionPollingStates.contains(_state!.polling) &&
        !force) {
      return _state!.session;
    }

    return await _login(storage: storage, options: options);
  }

  Future<RemoteSession> _login({
    required AccountStorage storage,
    required SessionOptions options,
  }) async {
    _loginLock = Completer();

    try {
      AntinoteAccount? account = await storage.borrowAccountWithCredentials(
        accountUid,
      );
      if (account == null) {
        throw StateError('Tried to log in to a non-existent account.');
      }

      final RemoteSession newSession;

      try {
        final credentials = account.credentials;
        assert(
          credentials != null,
          'Tried to log in to an account that doesn\'t have credentials.',
        );

        final LoginResult(
          session: createdSession,
          credentials: newCredentials,
        ) = await credentials!.login(
          options: options,
        );

        newSession = createdSession;

        if (newCredentials != null) {
          account = account.setCredentials(
            newSession.stack.demo ? credentials : newCredentials,
          );
          await storage.updateAccount(account, accountUid);
        }
      } catch (e, st) {
        libLog.severe(
          'Couldn\'t login into account ${account?.uid}. Marking the account as invalid',
          e,
          st,
        );

        if (e is IOException) {
          libLog.warning(
            'The failure seems to be related to IO, is the network available?',
          );
        }

        account = account?.rebuild((acc) => acc.invalid = true);
        if (account != null) {
          await storage.updateAccount(account, accountUid);
        }

        rethrow;
      }

      final int? version;

      if (_nativeSessionManagerSupported) {
        version = await _sessionManager.registerSession(
          accountUid,
          newSession.exportBinary(),
        );
      } else {
        version = null;
      }

      _state = .new(
        session: newSession,
        polling: .unavailable,
        version: version,
      );

      return newSession;
    } finally {
      _loginLock?.complete();
      _loginLock = null;
    }
  }

  void updatePollingState(PollingState newState) {
    if (_state == null) return;

    _state = .new(
      session: _state!.session,
      polling: newState,
      version: _state!.version,
    );
  }

  Future<T> runTask<T>({
    required SessionTaskCallback<T> callback,
    required AccountStorage storage,
    required SessionOptions options,
    Set<String> channels = const {'communication'},
    String? debugLabel,
    bool retry = false,
    bool sendSession = true,
  }) async {
    ScheduledTask? task;
    Completer<void>? createdLock;

    try {
      if (_nativeSessionManagerSupported) {
        task = await _sessionManager.scheduleTask(
          accountUid,
          channels.toList(growable: false),
          _state?.version,
          debugLabel,
        );

        if (task.session != null) {
          _state = .new(
            session: await RemoteSession.restoreBinary(
              task.session!,
              options: options,
            ),
            polling: _state?.polling ?? .unavailable,
            version: task.sessionVersion,
          );
        } else if (_state != null && _state!.version != task.sessionVersion) {
          _state = .new(
            session: _state!.session,
            polling: _state!.polling,
            version: task.sessionVersion,
          );
        }
      } else {
        task = null;

        while (true) {
          bool goMode = true;
          createdLock = Completer();
          for (final channel in channels) {
            final lock = _taskLocks[channel];
            if (lock != null && !lock.isCompleted) {
              goMode = false;

              createdLock.complete();
              await lock.future;

              break;
            }

            _taskLocks[channel] = createdLock;
          }

          if (goMode) break;
        }
      }

      final tryCount = retry || _state?.polling == .unavailable ? 2 : 1;
      for (int curTry = 1; curTry <= tryCount; curTry++) {
        try {
          final session = await ensureSession(
            storage: storage,
            options: options,
          );

          return await callback(session);
        } on SessionException {
          if (_state != null) {
            _state = .new(
              session: _state!.session,
              polling: .dead,
              version: _state!.version,
            );
          }

          if (_nativeSessionManagerSupported) {
            await _sessionManager.updatePollingState(accountUid, .dead, null);
          }

          libLog.severe('Session exception... ($curTry/$tryCount)');
          if (curTry == tryCount) rethrow;
        } catch (e, st) {
          libLog.severe('Failed to run callback... ($curTry/$tryCount)', e, st);
          if (curTry == tryCount) rethrow;
        }
      }

      // Dart does not resolve the check in the catch as being complete, so we
      // need to add this so that the code compiles (although this exception
      // cannot actually be called).
      throw UnimplementedError();
    } finally {
      if (_nativeSessionManagerSupported) {
        if (task != null) {
          final newVersion = await _sessionManager.finishTask(
            accountUid,
            task.taskId,
            sendSession ? _state?.session.exportBinary() : null,
          );

          if (newVersion != null && _state != null) {
            _state = .new(
              session: _state!.session,
              polling: _state!.polling,
              version: newVersion,
            );
          }
        }
      } else if (createdLock != null) {
        createdLock.complete(null);

        for (final channel in channels) {
          if (_taskLocks[channel] == createdLock) _taskLocks[channel] = null;
        }
      }
    }
  }
}
