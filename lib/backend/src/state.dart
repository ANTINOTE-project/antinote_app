import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:flutter/material.dart";

enum AppState(final int priority) {
  /// During transfer or longer breaks (excluding pauses).
  classBreak(1),

  /// A break during which lunch can be eaten.
  lunch(3),

  /// During pauses.
  pause(2),

  /// During classes.
  clazz(4),

  /// Default state, before and after classes.
  defaultState(0)
}

typedef AppStateEntry = ({DateTimeRange range, AppState state});

class AppStateScheduler {
  static List<AppStateEntry> scheduleForDay(
    Date day, {
    required List<Event> events,
    required SpecificInstanceParameters params,
  }) {
    DateTime? firstEventStart;
    DateTime? lastEventEnd;

    for (final event in events) {
      if (firstEventStart == null ||
          event.startTime.isBefore(firstEventStart)) {
        firstEventStart = event.startTime;
      }
      if (lastEventEnd == null || event.endTime.isAfter(lastEventEnd)) {
        lastEventEnd = event.endTime;
      }
    }

    final ends = [
      for (final event in events) ...[
        (time: event.startTime, event: event, start: true),
        (time: event.endTime, event: event, start: false),
      ],
    ]..sort((a, b) => a.time.compareTo(b.time));

    final List<AppStateEntry> entries = [];

    final Set<Event> activeEvents = {};

    DateTime lastTime = day.copyWith();
    AppState lastState = .defaultState;

    int i = 0;
    while (i < ends.length) {
      final curTime = ends[i].time;

      while (i < ends.length && ends[i].time == curTime) {
        final endpoint = ends[i];
        if (endpoint.start) {
          activeEvents.add(endpoint.event);
        } else {
          activeEvents.remove(endpoint.event);
        }
        i++;
      }

      AppState newState = .defaultState;

      if (activeEvents.isEmpty) {
        if (firstEventStart != null &&
            !curTime.isBefore(firstEventStart) &&
            lastEventEnd != null &&
            curTime.isBefore(lastEventEnd)) {
          newState = .classBreak;
        }
      } else {
        for (final event in activeEvents) {
          final AppState eventState = switch (event) {
            ClassEvent(selfPresent: final selfPresent) when selfPresent =>
              .clazz,
            ClassEvent() => .classBreak,
            MealEvent() => .lunch,
            PauseEvent() => .pause,
          };

          if (eventState.priority > newState.priority) {
            newState = eventState;
          }
        }
      }

      if (newState != lastState) {
        if (curTime.isAfter(lastTime)) {
          entries.add((
            range: DateTimeRange(start: lastTime, end: curTime),
            state: lastState,
          ));
        }
        lastTime = curTime;
        lastState = newState;
      }
    }

    entries.add((
      range: DateTimeRange(start: lastTime, end: day.add(Duration(days: 1))),
      state: lastState,
    ));

    return entries;
  }
}
