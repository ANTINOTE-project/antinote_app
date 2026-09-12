part of '../block.dart';

final class PauseEvent extends Event {
  final String title;

  @override
  final DateTime startTime;
  @override
  final DateTime endTime;

  @override
  int get priority => 0;

  const new({
    required this.title,

    required this.startTime,
    required this.endTime,
  });
}

List<PauseEvent> pauseEventsForDay(
  List<Class> classes,
  SpecificInstanceParameters parameters,
) {
  if (classes.isEmpty) return [];

  final date = classes.first.startDate.toDay();
  final events = <PauseEvent>[];

  for (final classBreak in parameters.pauses) {
    final startTime = parameters.timeForSlot(
      parameters.endings[(classBreak.slot - 1) % parameters.slotsPerDay],
      date,
    );
    final endTime = parameters.timeForSlot(
      parameters.starts[classBreak.slot % parameters.slotsPerDay],
      date,
    );

    if (!parameters.isBusinessHalfDay(
      startTime,
      classBreak.slot % parameters.slotsPerDay,
    )) {
      continue;
    }
    if (!classes.last.endDate.isAfter(startTime)) continue;

    events.add(
      PauseEvent(
        title: classBreak.label,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }

  for (final clazz in classes) {
    if (clazz.canceled || (clazz is Lesson && clazz.exemptedLabel != null)) {
      continue;
    }

    final range = DateTimeRange(
      start: clazz.startDate.toTime(),
      end: clazz.endDate.toTime(),
    );

    events.removeWhere(
      (element) => range.rangeOverlaps(
        DateTimeRange(
          start: element.startTime.toTime(),
          end: element.endTime.toTime(),
        ),
      ),
    );

    if (events.isEmpty) break;
  }

  return events;
}
