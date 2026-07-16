import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:flutter/material.dart";

enum AppState(final int priority) {
  /// Any kind of break during classday (excluding pauses).
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
    DateTime? classEnd;
    for (final event in events) {
      if (event is! ClassEvent) continue;
      if (!event.selfPresent) continue;

      if (classEnd == null || classEnd.isBefore(event.endTime)) {
        classEnd = event.endTime;
      }
    }

    final nextDay = day.add(const Duration(days: 1));

    final ends = [
      (time: day, event: null, start: true),
      for (final event in events) ...[
        (time: event.startTime, event: event, start: true),
        (time: event.endTime, event: event, start: false),
      ],
      (time: nextDay, event: null, start: false),
    ]..sort((a, b) => a.time.compareTo(b.time));

    final List<AppStateEntry> entries = [];

    final Set<Event?> activeEvents = {};

    DateTime lastTime = day.copyWith();
    AppState lastState = .defaultState;

    bool startedClass = false;

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

      AppState? newState;

      if (activeEvents.isEmpty) {
        newState = startedClass ? .classBreak : .defaultState;
      } else {
        final duringActiveTime =
            startedClass && classEnd != null && !curTime.isAfter(classEnd);

        for (final event in activeEvents) {
          final AppState eventState = switch (event) {
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
        startedClass = true;
      }

      if (newState != lastState) {
        if (curTime.isAfter(lastTime)) {
          entries.add((
            range: DateTimeRange(start: lastTime, end: curTime),
            state: lastState,
          ));
        }
        lastTime = curTime;
        lastState = newState!;
      }
    }

    if (!lastTime.isAtSameMomentAs(nextDay)) {
      entries.add((
        range: DateTimeRange(start: lastTime, end: nextDay),
        state: .defaultState,
      ));
    }

    print("Class ends: $classEnd, $lastTime");
    for (final entry in entries) {
      print(
        "- ${entry.range.start.hour.toString().padLeft(2, "0")}:${entry.range.start.minute.toString().padLeft(2, "0")} to ${entry.range.end.hour.toString().padLeft(2, "0")}:${entry.range.end.minute.toString().padLeft(2, "0")} : ${entry.state}",
      );
    }
    print(entries);

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
      "Found two same app states in a row, those should be squashed into one entry",
    );

    return entries;
  }
}
