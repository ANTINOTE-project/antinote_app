import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/communication/screen.dart';
import 'package:antinote_app/ui/screens/grades/screen.dart';
import 'package:antinote_app/ui/screens/home/screen.dart';
import 'package:antinote_app/ui/screens/homeworks/screen.dart';
import 'package:antinote_app/ui/screens/timetable/screen.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

enum TabCategory { home, timetable, grades, homeworks, communication }

typedef TabDestination = ({
  IconData icon,
  String label,
  Widget Function(Key? key) screen,
  TabCategory category,
  List<int> tabs,
});

List<TabDestination> buildTabs(BuildContext context) {
  return [
    (
      icon: HugeIconsSolid.home01,
      label: context.l10n.home,
      screen: (key) => HomeScreen(key: key),
      category: .home,
      tabs: [],
    ),
    (
      icon: HugeIconsSolid.calendar01,
      label: context.l10n.timetable,
      screen: (key) => TimetableScreen(key: key),
      category: .timetable,
      tabs: [TimetableAccessor.pageId],
    ),
    (
      icon: HugeIconsSolid.graduateMale,
      label: context.l10n.grades,
      screen: (key) => GradesScreen(key: key),
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
      screen: (key) => HomeworksScreen(key: key),
      category: .homeworks,
      tabs: [NotebookSection.homework.pageId, NotebookSection.resources.pageId],
    ),
    (
      icon: HugeIconsSolid.inbox,
      label: context.l10n.communication,
      screen: (key) => CommunicationScreen(key: key),
      category: .communication,
      tabs: [NewsPageAccessor.pageId, DiscussionPageAccessor.pageId],
    ),
  ];
}
