import 'dart:async';
import 'dart:io';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/accounts/storage/base.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_session.g.dart';
import 'package:antinote_app/ui/screens/auth/lists/accounts.dart';
import 'package:material_ui/material_ui.dart';

import '../session/wrapper.dart';
import '../settings/networking.dart';

final NativeSessionManager _sessionManager = NativeSessionManager();
final _nativeSessionManagerSupported = Platform.isAndroid;

final class AccountRegistry({
  required final AccountStorage _storage,
  required final NetworkingSettings settings,
}) {
  AccountStorage get storage => _storage;

  final Map<String, SessionWrapper> _sessions = {};

  SessionWrapper? get curSession =>
      _curAccount == null ? null : _sessions[_curAccount];

  SessionWrapper? specificSession(String accountUid) => _sessions[accountUid];

  String? _curAccount;

  String? get curAccountUid => _curAccount;

  bool get accountPicked => _curAccount != null;
  Completer<void>? pickLock;

  bool managesAccount(String accountUid) => _sessions.containsKey(accountUid);

  Future<void> ensureAccountPicked({required BuildContext context}) async {
    assert(
      context.mounted,
      'Tried to ensure the account is picked with an unmounted context',
    );

    if (pickLock != null) {
      await pickLock!.future;
    }

    pickLock = Completer();

    try {
      if (_curAccount != null) return;

      final defaultAccount = await _storage.getDefaultAccount();
      if (defaultAccount != null && !defaultAccount.invalid) {
        await loadAccount(defaultAccount.uid);
        return;
      }

      logger.info('Sent user to account pick screen');

      // This never returns until [accountPicked] is true.
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const AccountsListScreen();
            },
          ),
        );
      }

      assert(accountPicked);
    } finally {
      pickLock?.complete();
      pickLock = null;
    }
  }

  Future<bool> loadAccount(String accountUid, {bool pick = true}) async {
    if (pick) {
      _curAccount = accountUid;
    }
    final wrapper = curSession ?? SessionWrapper(accountUid: accountUid);
    _sessions[accountUid] = wrapper;

    try {
      await wrapper.runTask(
        callback: (session) {
          logger.info(
            'Logged in to account $accountUid with session ID ${session.stack.sessionId}!',
          );
        },
        storage: _storage,
        options: settings.sessionOptions,
        channels: {},
        debugLabel: 'Logging in to account $accountUid',
        retry: true,
      );

      if (_nativeSessionManagerSupported) {
        await _sessionManager.setCurrentAccountsListener(
          _sessions.keys.toList(growable: false),
        );
      }

      return true;
    } catch (e, st) {
      logger.severe('Failed to log in to newly picked account', e, st);
      _curAccount = null;

      return false;
    }
  }

  void unpickAccount() => _curAccount = null;

  Future<bool> registerAccount(
    RegisterableAccount entry, {
    bool shouldPickAccount = true,
  }) async {
    try {
      await _storage.addAccount(entry.account);

      await entry.wrapper.tryRegisterSession();

      _sessions[entry.account.uid] = entry.wrapper;

      return await loadAccount(entry.account.uid, pick: shouldPickAccount);
    } catch (e, st) {
      logger.severe('Failed to register account to storage/manager', e, st);

      return false;
    }
  }

  Future<T> runTask<T>({
    required BuildContext context,
    required SessionTaskCallback<T> callback,
    Set<String> channels = const {'communication'},
    required String? debugLabel,
    bool retry = false,
    bool registerHook = false,
    String? forceAccountId,
  }) async {
    if (forceAccountId == null) {
      await ensureAccountPicked(context: context);
    } else {
      await loadAccount(forceAccountId, pick: false);
    }

    return runRawTask(
      callback: callback,
      channels: channels,
      debugLabel: debugLabel,
      retry: retry,
      registerHook: registerHook,
    );
  }

  /// Use [runTask] in most situations. using this is unsafe unless the
  /// situation ensures we have a valid and selected account.
  Future<T> runRawTask<T>({
    required SessionTaskCallback<T> callback,
    Set<String> channels = const {'communication'},
    required String? debugLabel,
    bool retry = false,
    bool registerHook = false,
    String? forceAccountId,
  }) async {
    return specificSession(forceAccountId ?? _curAccount!)!.runTask(
      callback: callback,
      channels: channels,
      debugLabel: debugLabel,
      storage: _storage,
      options: settings.sessionOptions,
      retry: retry,
      registerHook: registerHook,
    );
  }

  void unregisterHook(SessionTaskCallback callback) {
    for (final wrapper in _sessions.values) {
      wrapper.unregisterHook(callback);
    }
  }
}
