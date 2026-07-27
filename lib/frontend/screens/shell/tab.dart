import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:flutter/material.dart";

typedef RefreshIndicatorBuilder = Widget Function({
  required Widget child,
  bool pullable,
});

mixin TabMixin<T extends StatefulWidget> on State<T> {
  List<String> get loadChannels => ["communication"];
  Stream<double?> load(RemoteSession session);

  bool loaded = false;
  Stream<double?>? _loader;

  SessionManager? manager;
  void _sessionUpdateCallback() {
    if (!mounted) return;

    manager?.unsubscribeSession(callback: reload);

    try {
      final controller = StreamController<double?>.broadcast();
      _loader = controller.stream;

      context.sm.runTask(
        context: context,
        channels: loadChannels,
        callback: (session) async {
          await for (final event in load(session)) {
            controller.add(event);
          }

          controller.close();

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
    bool partial,
  );

  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    double? progress,
  ) => LoadingWidget(progress: progress);

  // TODO: Custom message when error occurs
  Widget buildErrored(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    Object? error,
  ) => buildLoading(context, buildRefreshIndicator, .5);

  Future<void> reload({bool fromRefreshIndicator = false}) async {
    if (_loader != null) {
      await _loader!.length;
      return;
    }

    if (!fromRefreshIndicator) {
      if (loadedRefreshIndicator.currentState != null) {
        return loadedRefreshIndicator.currentState!.show();
      } else if (unloadedRefreshIndicator.currentState != null) {
        return unloadedRefreshIndicator.currentState!.show();
      }
    }

    _sessionUpdateCallback();

    await _loader?.length;
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

    return StreamBuilder(
      stream: _loader,
      builder: (context, snapshot) {
        late Widget child;

        if (snapshot.hasError) {
          child = buildErrored(context, buildRefreshIndicator, snapshot.error);
        } else if (snapshot.connectionState == .done ||
            (snapshot.connectionState == .active && snapshot.hasData) ||
            (loaded && snapshot.connectionState == .none)) {
          child = buildLoaded(
            context,
            buildRefreshIndicator,
            snapshot.connectionState == .active,
          );
        } else {
          child = buildLoading(context, buildRefreshIndicator, snapshot.data);
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),
          child: child,
        );
      },
    );
  }
}
