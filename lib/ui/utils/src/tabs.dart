import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/communication/screen.dart';
import 'package:antinote_app/ui/screens/grades/screen.dart';
import 'package:antinote_app/ui/screens/home/screen.dart';
import 'package:antinote_app/ui/screens/homeworks/screen.dart';
import 'package:antinote_app/ui/screens/timetable/screen.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hugeicons_pro/hugeicons.dart';

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
      screen: const HomeScreen(),
      category: .home,
      tabs: [],
    ),
    (
      icon: HugeIconsSolid.calendar01,
      label: context.l10n.timetable,
      screen: const TimetableScreen(),
      category: .timetable,
      tabs: [TimetableAccessor.pageId],
    ),
    (
      icon: HugeIconsSolid.graduateMale,
      label: context.l10n.grades,
      screen: const GradesScreen(),
      category: .grades,
      tabs: [
        LatestGradesPageAccessor.pageId,
        ReportSection.clazz.pageId,
        ReportSection.student.pageId,
      ],
    ),
    (
      icon: HugeIconsSolid.task01,
      label: context.l10n.homeworks,
      screen: const HomeworksScreen(),
      category: .homeworks,
      tabs: [NotebookSection.homework.pageId, NotebookSection.resources.pageId],
    ),
    (
      icon: HugeIconsSolid.inbox,
      label: context.l10n.communication,
      screen: const CommunicationScreen(),
      category: .communication,
      tabs: [NewsPageAccessor.pageId, DiscussionPageAccessor.pageId],
    ),
  ];
}
