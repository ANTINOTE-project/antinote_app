import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with PageMixin<HomeScreen>, TabMixin<HomeScreen> {
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

        child: Padding(
          padding: const .all(12),

          child: CustomScrollView(
            slivers: [
              for (final widget in homePageManager.loadedWidgets)
                SliverSafeArea(
                  sliver: ValueListenableBuilder(
                    valueListenable: widget,
                    builder: (context, value, child) {
                      return widget.descriptor.buildSliver(
                        context,
                        widget,
                        value,
                      );
                    },
                  ),
                ),

              SliverToBoxAdapter(
                child: ButtonWidget(
                  onPressed: () async {
                    await context.push(Routes.settings);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> load(RemoteSession session) async {
    homePageManager = HomePageManager();
    await homePageManager.initialize(context, session);

    libLog.info(
      'Loaded home page with ${homePageManager.loadedWidgets.length} widget(s)',
    );
  }
}

class const HomeWidget({
  super.key,

  required final IconData icon,
  required final Widget title,

  final VoidCallback? onShowMore,

  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        ItemWidget(
          borderRadius: .vertical(
            top: ListWidget.radius,
            bottom: onShowMore == null
                ? ListWidget.radius
                : ListWidget.defaultRadius,
          ),
          title: Row(spacing: 8, children: [Icon(icon), title]),
          subtitle: child,
        ),
        if (onShowMore != null)
          ItemWidget(
            borderRadius: const .vertical(
              top: ListWidget.defaultRadius,
              bottom: ListWidget.radius,
            ),
            title: Text(context.l10n.homeShowMore),
            trailing: const Icon(HugeIconsSolid.arrowRight01),
            onPressed: onShowMore,
          ),
      ],
    );
  }
}
