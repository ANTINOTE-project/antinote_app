import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/holder.dart";
import "package:antinote_app/frontend/extensions/account_storage.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

typedef RunCallback<T> = FutureOr<T> Function(PronoteSession session);

class SessionManager extends InheritedWidget {
  final SessionDataHolder state;

  const SessionManager({super.key, required this.state, required super.child});

  /// A function made to ensure [SessionDataHolder.lastSeenAccountUid] from
  /// [state] is never [null]. The logic taken is as follows:
  /// - If [SessionDataHolder.lastSeenAccountUid] is not null, return ;
  /// - Else, we check for a default account in the account list. If we find
  ///   any, we just put it by default ;
  /// - If no default account exists, we start the picker which will make the
  ///   user either pick another account or create a new one.
  Future<String> ensureAccountUid(BuildContext context) async {
    if (state.lastSeenAccountUid != null) return state.lastSeenAccountUid!;

    final defaultAccount = await context.as.getDefaultAccount();

    if (defaultAccount != null) {
      state.lastSeenAccountUid = defaultAccount.uid;
      return defaultAccount.uid;
    }

    if (!context.mounted) {
      throw Exception(
        "Context got unmounted by the time we checked if any "
        "default account existed",
      );
    }

    await context.push(Routes.auth.login);

    return state.lastSeenAccountUid!;
  }

  Future<PronoteSession> ensureSession({
    required BuildContext context,
    String? accountUid,
  }) {
    if (!context.mounted) {
      throw Exception(
        "Wanted to ensure session existed but context is unmounted...",
      );
    }

    return state.ensureSession(storage: context.as, accountUid: accountUid);
  }

  static SessionManager of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SessionManager>();
    assert(result != null, "No SessionManager in context");

    return result!;
  }

  Future<T> runTask<T>({
    required BuildContext? context,
    List<String> channels = const ["communication"],
    required RunCallback<T> callback,
    bool bypassStateLock = false,
  }) async {
    if (state.stateLock != null && !bypassStateLock) {
      await state.stateLock!.future;

      if (context != null && !context.mounted) {
        throw Exception(
          "Waited for state lock to lift in order to not repeat requests from this "
          "client. By that time, the state got unmounted.",
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
            "Wanted to run a task without having picked an account "
            "ID and without a valid context...",
          );
        }

        await ensureAccountUid(context);
      }

      final as = context == null || !context.mounted ? null : context.as;

      return await state.runTask(
        sessionEnsurer: () {
          assert(
            as != null,
            "Wanted to run a task without having a session "
            "and without a valid context...",
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
    }
  }

  static Future<T> execute<T>({
    required BuildContext context,
    List<String> channels = const ["communication"],
    required RunCallback<T> callback,
  }) async {
    final result = context.dependOnInheritedWidgetOfExactType<SessionManager>();
    assert(result != null, 'No "SessionManager" in tree...');

    return result!.runTask(
      context: context,
      channels: channels,
      callback: callback,
    );
  }

  void subscribeSession({required VoidCallback callback}) {
    state.addListener(callback);
  }

  void unsubscribeSession({required VoidCallback callback}) {
    state.removeListener(callback);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
