import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";

typedef RefreshIndicatorBuilder =
    Widget Function({required Widget child, bool pullable});

mixin TabMixin<T extends StatefulWidget> on State<T> {
  List<String> get loadChannels => ["communication"];
  FutureOr<void> loadActiveDataFromSession(PronoteSession session);

  bool loaded = false;
  Future<void>? _loader;

  SessionManager? manager;
  void _sessionUpdateCallback() {
    if (!mounted) return;

    manager?.unsubscribeSession(callback: reload);

    try {
      _loader = SessionManager.execute(
        context: context,
        channels: loadChannels,
        callback: (session) async {
          await loadActiveDataFromSession(session);

          if (mounted) {
            manager?.subscribeSession(callback: reload);
          }

          if (mounted) {
            setState(() {
              loaded = true;
              _loader = null;
            });
          }
        },
      );
    } on SessionException {
      manager?.subscribeSession(callback: reload);
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    if (manager == null) {
      manager = SessionManager.of(context);

      manager!.subscribeSession(callback: reload);
      await reload();
    } else {
      manager = SessionManager.of(context);
    }
  }

  @override
  void dispose() {
    manager?.unsubscribeSession(callback: reload);
    super.dispose();
  }

  // We put two distinct refresh indicators because both can be visible at the
  // same time while we animate a transition between both states.
  final GlobalKey<RefreshIndicatorState> unloadedRefreshIndicator = GlobalKey();
  final GlobalKey<RefreshIndicatorState> loadedRefreshIndicator = GlobalKey();

  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  );

  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) => const LoadingWidget();

  Widget buildErrored(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    Object? error,
  ) => buildLoading(context, buildRefreshIndicator);

  Future<void> reload({bool fromRefreshIndicator = false}) async {
    if (_loader != null) {
      return _loader;
    }

    if (!fromRefreshIndicator) {
      if (loadedRefreshIndicator.currentState != null) {
        return loadedRefreshIndicator.currentState!.show();
      } else if (unloadedRefreshIndicator.currentState != null) {
        return unloadedRefreshIndicator.currentState!.show();
      }
    }

    _sessionUpdateCallback();

    return _loader;
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    Future<void> refreshFunction() async =>
        await reload(fromRefreshIndicator: true);

    Widget buildRefreshIndicator({
      required Widget child,
      bool pullable = true,
    }) => RefreshIndicator(
      key: loaded ? loadedRefreshIndicator : unloadedRefreshIndicator,
      onRefresh: refreshFunction,

      child: child,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.fastOutSlowIn,
      switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),
      child: FutureBuilder(
        future: _loader,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return buildErrored(context, buildRefreshIndicator, snapshot.error);
          }

          if (snapshot.connectionState == .done ||
              (loaded && snapshot.connectionState == .none)) {
            return buildLoaded(context, buildRefreshIndicator);
          }

          return buildLoading(context, buildRefreshIndicator);
        },
      ),
    );
  }
}
