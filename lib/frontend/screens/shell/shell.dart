import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/shell/screens/communication/index.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades/index.dart";
import "package:antinote_app/frontend/screens/shell/screens/home.dart";
import "package:antinote_app/frontend/screens/shell/screens/homeworks/index.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/screen.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

typedef ScreenDestination = ({
  IconData icon,
  String label,
  Widget screen,
  String category,
  List<int> associatedTabIds,
});

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final List<ScreenDestination> _screens = [
    (
      icon: HugeIconsSolid.home01,
      label: context.l10n.home,
      screen: const HomeScreen(),
      category: "home",
      associatedTabIds: [],
    ),
    (
      icon: HugeIconsSolid.calendar01,
      label: context.l10n.timetable,
      screen: const TimetableScreen(),
      category: "timetable",
      associatedTabIds: [16, 88, 89],
    ),
    (
      icon: HugeIconsSolid.graduateMale,
      label: context.l10n.grades,
      screen: const GradesScreen(),
      category: "grades",
      associatedTabIds: [13, 41, 198],
    ),
    (
      icon: HugeIconsSolid.task01,
      label: context.l10n.homeworks,
      screen: const HomeworksScreen(),
      category: "homeworks",
      associatedTabIds: [88],
    ),
    (
      icon: HugeIconsSolid.inbox,
      label: context.l10n.communication,
      screen: const CommunicationScreen(),
      category: "communication",
      associatedTabIds: [8, 131],
    ),
  ];

  Stream<NotificationPreviewState>? notificationStream;
  NotificationPreviewState? defaultNotifications;

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

  SessionManager? manager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (manager == null) {
      manager = SessionManager.of(context);

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

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return StreamBuilder(
      initialData: defaultNotifications,
      stream: notificationStream,

      builder: (context, snapshot) {
        final notifications = snapshot.data?.notifications ?? [];

        return Scaffold(
          extendBody: true,

          body: Row(
            children: [
              if (screenSize.width > screenSize.height)
                SafeArea(
                  right: false,
                  left: false,

                  child: Padding(
                    padding: const .symmetric(horizontal: 8),

                    child: ClipRRect(
                      borderRadius: const .only(
                        topRight: .circular(24),
                        bottomRight: .circular(24),
                      ),

                      child: NavigationRail(
                        backgroundColor: context.c.surfaceContainerHigh,
                        destinations: _screens.mapL((e) {
                          final notificationCount = notifications
                              .where(
                                (element) =>
                                    e.associatedTabIds.contains(element.tab),
                              )
                              .fold(
                                0,
                                (previousValue, element) =>
                                    previousValue + element.count,
                              );

                          return NavigationRailDestination(
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
                            label: Text(e.label),
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
                  child: _screens[currentPage].screen,
                ),
              ),
            ],
          ),

          bottomNavigationBar: screenSize.width > screenSize.height
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),

                    child: ClipRRect(
                      borderRadius: const .only(
                        topLeft: .circular(24),
                        topRight: .circular(24),
                      ),

                      child: NavigationBar(
                        destinations: _screens
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
    ScreenDestination e,
    List<NotificationPreview> notifications,
  ) {
    final notificationCount = notifications
        .where((element) => e.associatedTabIds.contains(element.tab))
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
