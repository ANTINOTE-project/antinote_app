import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/home/screen.dart";
import "package:antinote_app/frontend/screens/home/widgets.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:antinote_app/frontend/screens/timetable/screen.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:flutter/material.dart";

class TimetableWidget extends StatelessWidget {
  final EDT data;

  const TimetableWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      label: context.l10n.timetable,
      onShowMorePressed: () {
        context.sc.goToTab(.timetable);
      },
      content: TimetableDisplay(
        configurations: const [.dayConfig],
        scrollable: false,
        updateBlocks: (session, days, businessDays) async {
          // TODO: Add here current data to not fetch currently selected day.
          final newData = await HomeDisplayDataAccessor.of(context).data
              .updateWidget<EDT>(session, {
                "EDT": {
                  "date": {"_T": 7, "V": days.start.asRemoteDate()},
                },
              }, data.widgetId);

          assert(newData != null, "Timetable widget disappeared!");

          final intermediate = <DateTime, List<Class>>{};

          for (final clazz in newData!.timetable.classes) {
            intermediate.update(
              clazz.startDate.toDay(),
              (value) => value..add(clazz),
              ifAbsent: () => [clazz],
            );
          }

          return intermediate.map(
            (key, value) =>
                MapEntry(key, blocksForDay(value, session.instance)),
          );
        },
      ),
    );
  }
}
