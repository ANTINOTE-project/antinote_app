import 'dart:io';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/accounts/storage/base.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_session.g.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  String? _curAccount;
  String? get curAccountUid => _curAccount;

  bool get accountPicked => _curAccount != null;

  bool managesAccount(String accountUid) => _sessions.containsKey(accountUid);

  Future<void> ensureAccountPicked({required BuildContext context}) async {
    assert(
      context.mounted,
      'Tried to ensure the account is picked with an unmounted context',
    );

    if (_curAccount != null) return;

    final router = GoRouter.of(context);

    final defaultAccount = await _storage.getDefaultAccount();
    if (defaultAccount != null && !defaultAccount.invalid) {
      _curAccount = defaultAccount.uid;
      return;
    }

    // This never returns until [accountPicked] is true.
    await router.push(Routes.auth.accounts);

    assert(accountPicked);
  }

  Future<bool> pickAccount(String accountUid) async {
    _curAccount = accountUid;
    final wrapper = curSession ?? SessionWrapper(accountUid: accountUid);
    _sessions[accountUid] = wrapper;

    try {
      await wrapper.runTask(
        callback: (session) {
          libLog.info(
            'Logged in to account $accountUid with session ID ${session.stack.sessionId}!',
          );
        },
        storage: _storage,
        options: settings.sessionOptions,
        channels: {},
        debugLabel: 'Logging in to account $accountUid',
      );

      if (_nativeSessionManagerSupported) {
        await _sessionManager.setCurrentAccountsListener(
          _sessions.keys.toList(growable: false),
        );
      }

      return true;
    } catch (e, st) {
      libLog.severe('Failed to log in to newly picked account', e, st);
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

      final session = entry.wrapper.unsafeSession;
      if (_nativeSessionManagerSupported && session != null) {
        await _sessionManager.registerSession(
          entry.account.uid,
          session.exportBinary(),
        );
      }

      _sessions[entry.account.uid] = entry.wrapper;

      if (shouldPickAccount) {
        return await pickAccount(entry.account.uid);
      }

      return true;
    } catch (e, st) {
      libLog.severe('Failed to register account to storage/manager', e, st);

      return false;
    }
  }

  Future<T> runTask<T>({
    required BuildContext context,
    required SessionTaskCallback<T> callback,
    Set<String> channels = const {'communication'},
    required String? debugLabel,
  }) async {
    await ensureAccountPicked(context: context);

    return runRawTask(
      callback: callback,
      channels: channels,
      debugLabel: debugLabel,
    );
  }

  /// Use [runTask] in most situations. using this is unsafe unless the
  /// situation ensures we have a valid and selected account.
  Future<T> runRawTask<T>({
    required SessionTaskCallback<T> callback,
    Set<String> channels = const {'communication'},
    required String? debugLabel,
  }) async {
    return curSession!.runTask(
      callback: callback,
      channels: channels,
      debugLabel: debugLabel,
      storage: _storage,
      options: settings.sessionOptions,
    );
  }
}
