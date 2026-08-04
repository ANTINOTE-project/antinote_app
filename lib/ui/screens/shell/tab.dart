import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:flutter/material.dart';

typedef RefreshIndicatorBuilder = Widget Function({
  required Widget child,
  bool pullable,
});

mixin PageMixin<T extends StatefulWidget> on State<T> {
  Stream<double?> loadPage();

  bool loaded = false;
  Stream<double?>? _loader;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    if (!loaded && _loader == null) {
      await reload();
    }
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

  void _updateCallback() {
    final controller = StreamController<double?>.broadcast();
    _loader = controller.stream;

    libLog.info('Loading page $runtimeType...');

    () async {
      try {
        await for (final event in loadPage()) {
          controller.add(event);
        }
      } catch (e, st) {
        controller.addError(e, st);
      }

      controller.close();
    }().whenComplete(() {
      if (mounted) {
        setState(() {
          loaded = true;
          _loader = null;
        });
      }
    });
  }

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

    _updateCallback();

    try {
      await _loader?.length;
    } catch (_) {
      /* We log errors in the builder directly. */
    }
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

mixin TabMixin<T extends StatefulWidget> on PageMixin<T> {
  Set<String> get loadChannels => {'communication'};
  Stream<double?> load(RemoteSession session);

  @override
  Stream<double?> loadPage() async* {
    yield* await context.ar.runTask(
      context: context,
      channels: loadChannels,
      callback: (session) async* {
        yield* load(session);
      },
      debugLabel: 'Reload page $runtimeType',
      retry: true,
    );
  }
}
