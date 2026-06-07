import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";

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
    assert(result != null, "No ShellController found in context");

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
  Stream<NotificationPreviewState>? notificationStream;
  NotificationPreviewState? defaultNotifications;

  SessionManager? manager;

  late List<TabDestination> _tabs;
  int currentPage = 0;

  void loadNotificationStream() {
    SessionManager.execute(
      context: context,
      channels: const [],

      callback: (session) {
        if (!mounted) return;

        setState(() {
          notificationStream = session.notifications;
          defaultNotifications = session.currentNotificationState;
        });
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (manager == null) {
      manager = SessionManager.of(context);
      _tabs = buildTabs(context);

      manager!.subscribeSession(callback: loadNotificationStream);
      loadNotificationStream();
    } else {
      manager = SessionManager.of(context);
    }
  }

  @override
  void dispose() {
    manager?.unsubscribeSession(callback: loadNotificationStream);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return StreamBuilder(
      initialData: defaultNotifications,
      stream: notificationStream,

      builder: (context, snapshot) {
        final notifications = snapshot.data?.notifications ?? [];

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

                    child: Padding(
                      padding: const .only(right: 6),

                      child: ClipRRect(
                        borderRadius: const .only(
                          topRight: .circular(24),
                          bottomRight: .circular(24),
                        ),

                        child: NavigationRail(
                          backgroundColor: context.c.surfaceContainerHigh,

                          destinations: _tabs.mapL((e) {
                            final notificationCount = notifications
                                .where(
                                  (element) => e.tabs.contains(element.tab),
                                )
                                .fold(
                                  0,
                                  (previousValue, element) =>
                                      previousValue + element.count,
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
                  ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),

                    switchInCurve: Curves.fastOutSlowIn,
                    switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),

                    child: _tabs[currentPage].screen,
                  ),
                ),
              ],
            ),

            bottomNavigationBar: screenSize.width > screenSize.height
                ? null
                : Container(
                    margin: const .symmetric(horizontal: 6),
                    padding: const .symmetric(horizontal: 6),

                    clipBehavior: .antiAlias,

                    decoration: BoxDecoration(
                      color: context.c.surfaceContainer,
                      borderRadius: const .only(
                        topLeft: .circular(24),
                        topRight: .circular(24),
                      ),
                    ),

                    child: SafeArea(
                      left: false,
                      right: false,

                      child: NavigationBar(
                        destinations: _tabs
                            .map((e) => _buildDestination(e, notifications))
                            .toList(growable: false),

                        onDestinationSelected: (value) => setState(() {
                          currentPage = value;
                        }),

                        selectedIndex: currentPage,
                        height: 70,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  NavigationDestination _buildDestination(
    TabDestination e,
    List<NotificationPreview> notifications,
  ) {
    final notificationCount = notifications
        .where((element) => e.tabs.contains(element.tab))
        .fold(0, (prev, element) => prev + element.count);

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
