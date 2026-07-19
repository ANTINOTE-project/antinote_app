import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/backend/src/state.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";

typedef _SchedulesEntry = ({
  List<Event> events,
  List<Block> blocks,
  List<AppStateEntry> appStates,
});

/// This context is valid from the moment the home page is initialized until the
/// next refresh, [buildContext] becomes unmounted.
class HomePageContext extends ChangeNotifier {
  final BuildContext buildContext;
  final Date baseDay;

  SpecificInstanceParameters? _parameters;
  FutureOr<SpecificInstanceParameters> getParameters() async {
    if (_parameters != null) return _parameters!;

    _parameters = await SessionManager.execute(
      context: buildContext,
      callback: (session) {
        return session.instance;
      },
      channels: const [],
    );

    return _parameters!;
  }

  final Map<Date, _SchedulesEntry> _daySchedules = {};
  FutureOr<List<Event>> dayEvents(Date day) async {
    return (await _schedulesForDay(day)).events;
  }

  FutureOr<List<AppStateEntry>> dayAppStates(Date day) async {
    return (await _schedulesForDay(day)).appStates;
  }

  FutureOr<List<Block>> dayBlocks(Date day) async {
    return (await _schedulesForDay(day)).blocks;
  }

  FutureOr<_SchedulesEntry> _schedulesForDay(Date day) async {
    if (_daySchedules.containsKey(day)) return _daySchedules[day]!;

    final _SchedulesEntry schedules = await SessionManager.execute(
      context: buildContext,
      callback: (session) async {
        final homePage = await session.access(
          HomePageAccessor(modules: [EDT.module(day)]),
        );

        final scheduleWidget = homePage.widgets.firstWhereOrNull(
          (element) => element.widgetId == .edt,
        ) as EDT?;
        final List<Class> classes =
            scheduleWidget?.timetable.classes
                .where(
                  (element) => element.startDate.toDay().isAtSameMomentAs(day),
                )
                .toList(growable: false) ??
            List<Class>.empty();

        final events = eventsForDay(classes, session.instance);
        final blocks = blocksForDay(events, session.instance);
        final appStates = AppStateScheduler.scheduleForDay(
          day,
          events: events,
          params: session.instance,
        );

        return (appStates: appStates, blocks: blocks, events: events);
      },
    );

    _daySchedules[day] = schedules;

    notifyListeners();

    return schedules;
  }

  new({required this.buildContext, required this.baseDay});
}
