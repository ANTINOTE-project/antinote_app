import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/utils/various.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';

enum AppState(final int priority) {
  /// Any kind of break during classday (excluding pauses).
  classBreak(1),

  /// Time between classes.
  transfer(2),

  /// A break during which lunch can be eaten.
  lunch(4),

  /// During pauses.
  pause(3),

  /// During classes.
  clazz(5),

  /// Default state, before and after classes.
  defaultState(0)
}

enum TimeRelation { before, during, after, none }

final class const AppStateEntry({
  required final DateTimeRange range,
  required final AppState state,
  required final TimeRelation classRelation,
});
typedef _Marker = ({DateTime time, Event? event, bool isTransfer, bool start});

class AppStateScheduler {
  static List<AppStateEntry> scheduleForDay(
    Date day, {
    required List<Event> events,
    required SpecificInstanceParameters params,
  }) {
    DateTime? classEnd;
    for (final event in events) {
      if (event is! ClassEvent) continue;
      if (!event.selfPresent) continue;

      if (classEnd == null || classEnd.isBefore(event.endTime)) {
        classEnd = event.endTime;
      }
    }

    final nextDay = day.add(const Duration(days: 1));

    final ends = <_Marker>[
      (time: day, event: null, isTransfer: false, start: true),
      for (final event in events) ...[
        (time: event.startTime, event: event, isTransfer: false, start: true),
        (time: event.endTime, event: event, isTransfer: false, start: false),
      ],

      for (final transferEntry in params.transferTimes) ...[
        (
          time: transferEntry.start.withDate(day),
          event: null,
          isTransfer: true,
          start: true,
        ),
        (
          time: transferEntry.end.withDate(day),
          event: null,
          isTransfer: true,
          start: false,
        ),
      ],
      (time: nextDay, event: null, isTransfer: false, start: false),
    ]..sort((a, b) => a.time.compareTo(b.time));

    final List<AppStateEntry> entries = [];

    final Set<_Marker> activeEvents = {};

    DateTime lastTime = day.copyWith();
    AppState lastState = .defaultState;

    TimeRelation classRelation = classEnd == null ? .none : .before;

    int i = 0;
    while (i < ends.length) {
      final curTime = ends[i].time;

      if (classRelation == .during && !curTime.isBefore(classEnd!)) {
        classRelation = .after;
      }

      while (i < ends.length && ends[i].time == curTime) {
        final endpoint = ends[i];
        if (endpoint.start) {
          activeEvents.add(endpoint);
        } else {
          activeEvents.removeWhere(
            (element) =>
                endpoint.event == element.event ||
                (endpoint.isTransfer && element.isTransfer),
          );
        }
        i++;
      }

      AppState? newState;

      if (activeEvents.isEmpty) {
        newState = classRelation == .during ? .classBreak : .defaultState;
      } else {
        final duringActiveTime =
            classRelation == .during &&
            classEnd != null &&
            !curTime.isAfter(classEnd);

        for (final event in activeEvents) {
          final AppState eventState = switch (event.event) {
            _ when event.isTransfer => switch (lastState) {
              .classBreak => .classBreak,
              .defaultState => .defaultState,
              _ => .transfer,
            },

            ClassEvent(selfPresent: final selfPresent) when selfPresent =>
              .clazz,
            ClassEvent() ||
            null => duringActiveTime ? .classBreak : .defaultState,
            MealEvent() => .lunch,
            PauseEvent() => duringActiveTime ? .pause : .defaultState,
          };

          if (newState == null || eventState.priority > newState.priority) {
            newState = eventState;
          }
        }
      }

      if (newState == .clazz) {
        classRelation = .during;
      }

      if (lastState == .transfer) {
        lastState = switch (newState) {
          .classBreak => .classBreak,
          .lunch => .lunch,
          .defaultState => .defaultState,

          _ => .transfer,
        };
      }

      if (newState != lastState) {
        if (curTime.isAfter(lastTime)) {
          entries.add(
            .new(
              range: DateTimeRange(start: lastTime, end: curTime),
              state: lastState,
              classRelation: classRelation,
            ),
          );
        }
        lastTime = curTime;
        lastState = newState!;
      }
    }

    if (entries.lastOrNull?.state == .defaultState) {
      lastTime = entries.removeLast().range.start;
    }

    if (!lastTime.isAtSameMomentAs(nextDay)) {
      entries.add(
        .new(
          range: DateTimeRange(start: lastTime, end: nextDay),
          state: .defaultState,
          classRelation: classRelation,
        ),
      );
    }

    assert(
      () {
        AppState? lastState;
        for (final entry in entries) {
          if (lastState == entry.state) {
            return false;
          }

          lastState = entry.state;
        }

        return true;
      }(),
      'Found two same app states in a row, those should be squashed into one entry',
    );

    return entries;
  }
}
