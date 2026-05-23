import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/extensions/screen_manager.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/shell/screens/communication.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final _screens = [
    (
      icon: HugeIconsSolid.home01,
      label: context.l10n.home,
      tooltip: null,
      screen: const TimetableScreen(),
      category: "home",
      associatedTabIds: [],
    ),
    (
      icon: HugeIconsSolid.calendar01,
      label: context.l10n.timetable,
      tooltip: null,
      screen: const TimetableScreen(),
      category: "timetable",
      associatedTabIds: [16, 88, 89],
    ),
    (
      icon: HugeIconsSolid.school,
      label: context.l10n.grades,
      tooltip: null,
      screen: const GradesScreen(),
      category: "grades",
      associatedTabIds: [13, 41, 198],
    ),
    (
      icon: HugeIconsSolid.inbox,
      label: context.l10n.communication,
      tooltip: null,
      screen: const CommunicationScreen(),
      category: "communication",
      associatedTabIds: [8, 131],
    ),
  ];

  Stream<NotificationPreviewState>? notificationStream;

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

  int curPage = 0;

  void onDestinationSelected(int destinationIndex) {
    context.sm.storage["main_category"] = _screens[destinationIndex].category;
    context.sm.updateCurrentScreenId();

    setState(() {
      curPage = destinationIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: notificationStream,

      builder: (context, snapshot) {
        final notifications = snapshot.data?.notifications ?? [];

        return Scaffold(
          bottomNavigationBar: NavigationBar(
            destinations: _screens
                .map((e) {
                  final notificationCount = notifications
                      .where((element) => e.associatedTabIds.contains(element.tab))
                      .fold(0, (previousValue, element) => previousValue + element.count);

                  return NavigationDestination(
                    icon: Badge.count(
                      count: notificationCount,
                      isLabelVisible: notificationCount > 0,
                      child: Icon(e.icon),
                    ),
                    label: e.label,
                    tooltip: e.tooltip,
                    selectedIcon: Badge.count(
                      count: notificationCount,
                      isLabelVisible: notificationCount > 0,
                      child: Icon(e.icon, fill: 1),
                    ),
                  );
                })
                .toList(growable: false),
            selectedIndex: curPage,
            onDestinationSelected: onDestinationSelected,
          ),
        );
      },
    );
  }
}
