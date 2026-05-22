import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_ui/backend/src/accounts/storage/base.dart';
import 'package:antinote_ui/backend/src/session/holder.dart';
import 'package:antinote_ui/ui/ui.dart';
import 'package:flutter/material.dart';

typedef RunCallback<T> = FutureOr<T> Function(PronoteSession session);

enum TaskType { normal, pollingListener }

class SessionManager extends InheritedModel<TaskType>
    with WidgetsBindingObserver {
  final SessionDataHolder state;
  final VoidCallback onNewSessionSet;

  const SessionManager({
    super.key,
    required this.state,
    required this.onNewSessionSet,
    required super.child,
  });

  /// A function made to ensure [SessionDataHolder.lastSeenAccountUid] from
  /// [state] is never [null]. The logic taken is as follows:
  /// - If [SessionDataHolder.lastSeenAccountUid] is not null, return ;
  /// - Else, we check for a default account in the account list. If we find
  ///   any, we just put it by default ;
  /// - If no default account exists, we start the picker which will make the
  ///   user either pick another account or create a new one.
  Future<String> ensureAccountUid(BuildContext context) async {
    if (state.lastSeenAccountUid != null) return state.lastSeenAccountUid!;

    final defaultAccount = await AccountStorage.of(context).getDefaultAccount();

    if (defaultAccount != null) {
      state.lastSeenAccountUid = defaultAccount.uid;
      return defaultAccount.uid;
    }

    if (!context.mounted) {
      throw Exception(
        'Context got unmounted by the time we checked if any '
        'default account existed',
      );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    return state.lastSeenAccountUid!;
  }

  Future<PronoteSession> ensureSession({
    required BuildContext context,
    String? accountUid,
  }) {
    if (!context.mounted) {
      throw Exception(
        'Wanted to ensure session existed but context is unmounted...',
      );
    }

    return state.ensureSession(
      storage: AccountStorage.of(context),
      accountUid: accountUid,
    );
  }

  static SessionManager of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SessionManager>();
    assert(result != null, 'No SessionManager in context');

    return result!;
  }

  Future<T> runTask<T>({
    required BuildContext? context,
    List<String> channels = const ['communication'],
    required RunCallback<T> callback,
    bool bypassStateLock = false,
  }) async {
    if (state.stateLock != null && !bypassStateLock) {
      await state.stateLock!.future;

      if (context != null && !context.mounted) {
        throw Exception(
          'Waited for state lock to lift in order to not repeat requests from this '
          'client. By that time, the state got unmounted.',
        );
      }
    }

    if (!bypassStateLock) {
      state.stateLock = Completer();
    }

    try {
      if (state.lastSeenAccountUid == null) {
        if (context == null || !context.mounted) {
          throw Exception(
            'Wanted to run a task without having picked an account '
            'ID and without a valid context...',
          );
        }

        await ensureAccountUid(context);
      }

      final as = context == null || !context.mounted
          ? null
          : AccountStorage.of(context);

      return state.runTask(
        sessionEnsurer: () {
          assert(
            as != null,
            'Wanted to run a task without having a session '
            'and without a valid context...',
          );

          return state.ensureSession(storage: as!);
        },
        callback: callback,
        channels: channels,
      );
    } finally {
      if (!bypassStateLock) {
        final lock = state.stateLock;
        state.stateLock = null;
        if (!(lock?.isCompleted ?? true)) {
          lock?.complete();
        }
      }

      if (state.dirty) {
        onNewSessionSet();
        state.dirty = false;
      }
    }
  }

  static Future<T> run<T>({
    required BuildContext context,
    List<String> channels = const ['communication'],
    required RunCallback<T> callback,
  }) async {
    final result = context.dependOnInheritedWidgetOfExactType<SessionManager>(
      aspect: TaskType.normal,
    );
    assert(result != null, 'No "SessionManager" in tree...');

    return result!.runTask(
      context: context,
      channels: channels,
      callback: callback,
    );
  }

  static Future<T> runSubscribe<T>({
    required BuildContext context,
    List<String> channels = const [],
    required RunCallback<T> callback,
  }) async {
    final result = context.dependOnInheritedWidgetOfExactType<SessionManager>(
      aspect: TaskType.pollingListener,
    );
    assert(result != null, 'No "SessionManager" in tree...');

    return result!.runTask(
      context: context,
      channels: channels,
      callback: callback,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != .resumed) return;

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  bool updateShouldNotify(covariant SessionManager old) {
    if (state.dirty) {
      state.dirty = false;
      return true;
    }

    return false;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant SessionManager oldWidget,
    Set<TaskType> dependencies,
  ) {
    if (dependencies.contains(TaskType.pollingListener)) {
      print("Updated a polling listener...");
      return true;
    }

    return false;
  }
}
