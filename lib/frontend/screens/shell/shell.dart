import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/shell/screens/communication.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades.dart";
import "package:antinote_app/frontend/screens/shell/screens/home.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable.dart";
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
      icon: HugeIconsSolid.inbox,
      label: context.l10n.communication,
      screen: const CommunicationScreen(),
      category: "communication",
      associatedTabIds: [8, 131],
    ),
  ];

  Stream<NotificationPreviewState>? notificationStream;

  int currentPage = 0;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    notificationStream = await SessionManager.runSubscribe(
      context: context,
      callback: (session) {
        return session.notifications;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: notificationStream,

      builder: (context, snapshot) {
        final notifications = snapshot.data?.notifications ?? [];

        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: currentPage,
            children: _screens.mapL((e) => e.screen),
          ),

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),

                child: NavigationBar(
                  destinations: _screens
                      .map((e) => _buildDestination(e, notifications))
                      .toList(growable: false),
                  onDestinationSelected: (value) => setState(() {
                    currentPage = value;
                  }),
                  selectedIndex: currentPage,
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
