import 'dart:async';
import 'dart:io';

import 'package:antinote_api/antinote_api.dart';
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

final class const _SessionHook({
  required final SessionTaskCallback callback,
  required final int lastRanSessionVersion,
  required final String? debugLabel,

  required final Set<String> channels,
}) {
  _SessionHook copyWith({
    SessionTaskCallback? callback,

    int? lastRanSessionVersion,

    String? debugLabel,
    bool clearDebugLabel = false,

    Set<String>? channels,
  }) => _SessionHook(
    callback: callback ?? this.callback,
    lastRanSessionVersion: lastRanSessionVersion ?? this.lastRanSessionVersion,
    debugLabel: clearDebugLabel ? null : debugLabel ?? this.debugLabel,
    channels: channels ?? this.channels,
  );
}

final class const _SessionState({
  required final RemoteSession session,
  required final PollingState polling,
  required final int? version,

  /// The same list should always be kept (and should be growable).
  required final List<_SessionHook> hooks,
}) {
  _SessionState copyWith({
    RemoteSession? session,
    PollingState? polling,
    int? version,
    bool clearVersion = false,

    List<_SessionHook>? hooks,
  }) => _SessionState(
    session: session ?? this.session,
    polling: polling ?? this.polling,
    version: clearVersion ? null : version ?? this.version,
    hooks: hooks ?? this.hooks,
  );
}

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
      hooks: [],
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
        hooks: _state?.hooks ?? [],
      );

      return newSession;
    } finally {
      _loginLock?.complete();
      _loginLock = null;
    }
  }

  void _registerHook(_SessionHook hook) {
    if (_state == null) return;

    for (final existingHook in _state!.hooks) {
      if (existingHook.callback == hook.callback) return;
    }

    _state!.hooks.add(hook);
  }

  Future<void> _updateHooks({
    required Set<String> alreadyOwnedChannels,
    required AccountStorage storage,
    required SessionOptions options,
  }) async {
    if (_state == null || _state!.hooks.isEmpty) return;

    bool ranHook = false;
    do {
      List<int> hooksToDelete = [];

      for (final (index, hook) in _state!.hooks.indexed) {
        if (hook.lastRanSessionVersion != _state!.session.stack.sessionId) {
          ranHook = true;

          try {
            await runTask(
              callback: hook.callback,
              storage: storage,
              options: options,
              channels: hook.channels.difference(alreadyOwnedChannels),
              debugLabel: hook.debugLabel,
              runHooks: false,
            );

            _state!.hooks[index] = hook.copyWith(
              lastRanSessionVersion: _state!.session.stack.sessionId,
            );
          } catch (e, st) {
            libLog.severe(
              'Failed to run hook "${hook.debugLabel}" upon session change, '
              'deleting the hook...',
              e,
              st,
            );
            hooksToDelete.add(index);
          }
        }
      }

      for (final toDelete in hooksToDelete.reversed) {
        _state!.hooks.removeAt(toDelete);
      }
    } while (ranHook);
  }

  void unregisterHook(SessionTaskCallback callback) {
    if (_state == null) return;

    _state!.hooks.removeWhere((element) => element.callback == callback);
  }

  void updatePollingState(PollingState newState) {
    if (_state == null) return;

    _state = _state!.copyWith(polling: newState);
  }

  Future<T> runTask<T>({
    required SessionTaskCallback<T> callback,
    required AccountStorage storage,
    required SessionOptions options,
    Set<String> channels = const {'communication'},
    String? debugLabel,
    bool retry = false,
    bool sendSession = true,

    bool runHooks = true,
    bool registerHook = false,
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
            hooks: _state?.hooks ?? [],
          );
        } else if (_state != null && _state!.version != task.sessionVersion) {
          _state = _state!.copyWith(version: task.sessionVersion);
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

      final oldPollingState = _state?.polling;

      var tryCount = retry ? 2 : 1;
      for (int curTry = 1; curTry <= tryCount; curTry++) {
        try {
          final session = await ensureSession(
            storage: storage,
            options: options,
          );

          if (runHooks) {
            await _updateHooks(
              alreadyOwnedChannels: channels,
              storage: storage,
              options: options,
            );
          }

          final result = await callback(session);

          if (_state != null) {
            _state = _state!.copyWith(polling: .alive);

            if (registerHook) {
              _registerHook(
                _SessionHook(
                  callback: callback,
                  lastRanSessionVersion: session.stack.sessionId,
                  debugLabel: debugLabel,
                  channels: channels,
                ),
              );
            }
          }

          if (channels.isNotEmpty &&
              _nativeSessionManagerSupported &&
              sendSession) {
            libLog.info(
              'Marking $accountUid polling as ALIVE because task '
              'using network succeeded ($debugLabel).',
            );
            await _sessionManager.updatePollingState(accountUid, .alive, null);
          }

          return result;
        } on SessionException {
          if ((oldPollingState == .unavailable || oldPollingState == .paused) &&
              curTry == 1 &&
              !retry) {
            // We give the callback one more chance to run since we probably did
            // not know the session already died and the death of the session
            // wasn't its fault.
            tryCount++;

            libLog.info(
              'Giving the task one more chance to perform since the '
              'session was probably already dead when the task started.',
            );
          }

          if (_state != null) {
            _state = _state!.copyWith(polling: .dead);
          }

          if (_nativeSessionManagerSupported) {
            await _sessionManager.updatePollingState(accountUid, .dead, null);
          }

          libLog.info('Session exception... ($curTry/$tryCount)');
          if (curTry == tryCount) rethrow;
        } catch (e, st) {
          libLog.info('Failed to run callback... ($curTry/$tryCount)', e, st);
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
            _state = _state!.copyWith(version: newVersion);
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
