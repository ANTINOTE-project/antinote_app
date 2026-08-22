import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:material_ui/material_ui.dart';

class ShellController extends InheritedWidget {
  final void Function(TabCategory category) goToTab;

  const ShellController({
    super.key,
    required this.goToTab,
    required super.child,
  });

  static ShellController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<ShellController>();
    assert(result != null, 'No ShellController found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Stream<ServerSignature>? signatureStream;
  ServerSignature? defaultSignature;

  late List<TabDestination> _tabs;
  int currentPage = 0;

  void loadNotificationStream() {
    context.ar.runTask(
      context: context,
      channels: const {},

      callback: (session) {
        if (!mounted) return;

        setState(() {
          // TODO: Do checks for which tabs are available.
          signatureStream = session.stack.serverSignatureStream;
          defaultSignature = session.stack.serverSignature;
        });
      },
      debugLabel: 'Subscribe to server signature stream',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (signatureStream == null) {
      _tabs = buildTabs(context);

      // manager!.subscribeSession(callback: loadNotificationStream);
      loadNotificationStream();
    } else {
      // manager = SessionManager.of(context);
    }
  }

  @override
  void dispose() {
    // manager?.unsubscribeSession(callback: loadNotificationStream);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return StreamBuilder(
      initialData: defaultSignature,
      stream: signatureStream,

      builder: (context, snapshot) {
        final notifications =
            snapshot.data?.tabNotificationCounts ?? <int, int>{};

        return ShellController(
          goToTab: (category) => setState(() {
            currentPage = _tabs.indexWhere((t) => t.category == category);
          }),

          child: Scaffold(
            extendBody: true,

            body: Row(
              children: [
                if (screenSize.width > screenSize.height)
                  SafeArea(
                    right: false,
                    left: false,
                    top: false,

                    child: Padding(
                      padding: const .only(right: 6),

                      child: NavigationRail(
                        destinations: _tabs.mapL((e) {
                          final notificationCount = e.tabs
                              .map((e) => notifications[e] ?? 0)
                              .fold(
                                0,
                                (previousValue, element) =>
                                    previousValue + element,
                              );

                          return NavigationRailDestination(
                            label: Text(e.label),

                            icon: Badge.count(
                              count: notificationCount,
                              isLabelVisible: notificationCount > 0,
                              child: Icon(e.icon),
                            ),

                            selectedIcon: Badge.count(
                              count: notificationCount,
                              isLabelVisible: notificationCount > 0,
                              child: Icon(e.icon, fill: 1),
                            ),
                          );
                        }),

                        selectedIndex: currentPage,
                        onDestinationSelected: (value) => setState(() {
                          currentPage = value;
                        }),

                        labelType: .all,
                        scrollable: true,
                      ),
                    ),
                  ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.fastOutSlowIn,

                    child: _tabs[currentPage].screen,
                  ),
                ),
              ],
            ),

            bottomNavigationBar: screenSize.width > screenSize.height
                ? null
                : NavigationBar(
                    destinations: _tabs
                        .map((e) {
                          final notificationCount = e.tabs
                              .map((e) => notifications[e] ?? 0)
                              .fold(
                                0,
                                (previousValue, element) =>
                                    previousValue + element,
                              );

                          return _buildDestination(e, notificationCount);
                        })
                        .toList(growable: false),

                    onDestinationSelected: (value) => setState(() {
                      currentPage = value;
                    }),

                    selectedIndex: currentPage,
                    height: 70,
                  ),
          ),
        );
      },
    );
  }

  NavigationDestination _buildDestination(
    TabDestination e,
    int notificationCount,
  ) {
    return NavigationDestination(
      icon: Badge.count(
        count: notificationCount,
        isLabelVisible: notificationCount > 0,
        child: Icon(e.icon),
      ),

      label: e.label,

      selectedIcon: Badge.count(
        count: notificationCount,
        isLabelVisible: notificationCount > 0,
        child: Icon(e.icon, fill: 1),
      ),
    );
  }
}
