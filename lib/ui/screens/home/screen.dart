import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/ui/screens/settings/screen.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.homeHiName('example'),
          style: const TextStyle(fontWeight: .bold),
        ),

        actionsPadding: const .only(right: 8),
        actions: [
          IconButton(
            icon: const Icon(HugeIconsSolid.settings02),
            tooltip: '${context.l10n.goToAppSettings}…',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SettingsScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),

      body: buildRefreshIndicator(
        child: HomePageScope(
          manager: homePageManager,

          child: Padding(
            padding: const .symmetric(horizontal: 12),

            child: CustomScrollView(
              slivers: [
                for (final widget in homePageManager.loadedWidgets)
                  SliverSafeArea(
                    top: false,
                    bottom: false,
                    minimum: const .symmetric(vertical: 12),
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

                const SliverSafeArea(
                  sliver: SliverPadding(padding: .only(top: 32)),
                ),
              ],
            ),
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
