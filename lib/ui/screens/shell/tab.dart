import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

typedef RefreshIndicatorBuilder = Widget Function({
  required Widget child,
  bool pullable,
});

mixin PageMixin<T extends StatefulWidget> on State<T> {
  Future<void> loadPage();

  bool loaded = false;
  // TODO: Bring back stream loader when we figure out how to pass exceptions.
  Future<void>? _loader;

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

  Widget buildErrored(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    Object? error,
    StackTrace? stackTrace,
  ) => buildRefreshIndicator(
    child: Column(
      mainAxisAlignment: .center,
      children: [
        const Icon(HugeIconsSolid.bug02, size: 48),
        Padding(
          padding: const .symmetric(vertical: 4),
          child: Text(
            context.l10n.anErrorOccurred,
            style: TextTheme.of(context).titleMedium,
          ),
        ),
        if (kDebugMode)
          ButtonWidget(
            onPressed: () {
              libLog.fine('${error.runtimeType}', error, stackTrace);
            },
            label: 'Show error in console',
          ),
      ],
    ),
  );

  void _updateCallback() {
    libLog.info('Loading page $runtimeType...');

    _loader = loadPage();
    _loader!.whenComplete(() {
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
      await _loader!;
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
      await _loader;
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

    return FutureBuilder(
      future: _loader,
      builder: (context, snapshot) {
        late Widget child;

        if (snapshot.hasError) {
          child = buildErrored(
            context,
            buildRefreshIndicator,
            snapshot.error,
            snapshot.stackTrace,
          );
        } else if (snapshot.connectionState == .done ||
            (snapshot.connectionState == .active && snapshot.hasData) ||
            (loaded && snapshot.connectionState == .none)) {
          child = buildLoaded(
            context,
            buildRefreshIndicator,
            snapshot.connectionState == .active,
          );
        } else {
          child = buildLoading(context, buildRefreshIndicator, null);
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.fastOutSlowIn,
          child: child,
        );
      },
    );
  }
}

mixin TabMixin<T extends StatefulWidget> on PageMixin<T> {
  Set<String> get loadChannels => {'communication'};
  Future<void> load(RemoteSession session);

  @override
  Future<void> loadPage() async {
    await context.ar.runTask(
      context: context,
      channels: loadChannels,
      callback: load,
      debugLabel: 'Reload page $runtimeType',
      retry: true,
    );
  }
}
