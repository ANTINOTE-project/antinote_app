import "package:antinote_app/frontend/screens/communication/screen.dart";
import "package:antinote_app/frontend/screens/grades/screen.dart";
import "package:antinote_app/frontend/screens/homeworks/screen.dart";
import "package:antinote_app/frontend/screens/timetable/screen.dart";
import "package:antinote_app/frontend/utils/src/context.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

enum TabCategory { home, timetable, grades, homeworks, communication }

typedef TabDestination = ({
  IconData icon,
  String label,
  Widget screen,
  TabCategory category,
  List<int> tabs,
});

List<TabDestination> buildTabs(BuildContext context) {
  return [
    (
      icon: HugeIconsSolid.home01,
      label: context.l10n.home,
      screen: const Placeholder(), // TODO
      category: .home,
      tabs: [],
    ),
    (
      icon: HugeIconsSolid.calendar01,
      label: context.l10n.timetable,
      screen: const TimetableScreen(),
      category: .timetable,
      tabs: [16, 88, 89],
    ),
    (
      icon: HugeIconsSolid.graduateMale,
      label: context.l10n.grades,
      screen: const GradesScreen(),
      category: .grades,
      tabs: [13, 41, 198],
    ),
    (
      icon: HugeIconsSolid.task01,
      label: context.l10n.homeworks,
      screen: const HomeworksScreen(),
      category: .homeworks,
      tabs: [88],
    ),
    (
      icon: HugeIconsSolid.inbox,
      label: context.l10n.communication,
      screen: const CommunicationScreen(),
      category: .communication,
      tabs: [8, 131],
    ),
  ];
}
