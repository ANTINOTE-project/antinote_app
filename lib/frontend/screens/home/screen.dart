import 'package:antinote/antinote.dart';
import 'package:antinote_app/backend/src/home_page/manager.dart';
import 'package:antinote_app/frontend/screens/shell/tab.dart';
import 'package:flutter/material.dart';

class HomePageScope extends InheritedWidget {
  const HomePageScope({super.key, required this.manager, required super.child});

  final HomePageManager manager;

  static HomePageScope of(BuildContext context) {
    final HomePageScope? result = context
        .dependOnInheritedWidgetOfExactType<HomePageScope>();
    assert(result != null, 'No HomePageScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(HomePageScope old) {
    return old.manager != manager;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TabMixin<HomeScreen> {
  late HomePageManager homePageManager;

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    assert(!partial, 'This loaded page does not support partial loading yet.');

    return buildRefreshIndicator(
      child: HomePageScope(
        manager: homePageManager,
        child: CustomScrollView(
          slivers: [
            for (final widget in homePageManager.loadedWidgets)
              ValueListenableBuilder(
                valueListenable: widget,
                builder: (context, value, child) {
                  return widget.descriptor.buildSliver(context, value);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Stream<double?> load(RemoteSession session) async* {
    homePageManager = HomePageManager();
    await homePageManager.initialize(context, session);
  }
}
