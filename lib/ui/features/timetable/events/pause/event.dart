part of '../block.dart';

final class const PauseEvent({
  required final String title,

  @override required final DateTimeRange range,
}) extends Event {
  @override
  int get priority => 0;
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
        range: .new(start: startTime, end: endTime),
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
          start: element.range.start.toTime(),
          end: element.range.end.toTime(),
        ),
      ),
    );

    if (events.isEmpty) break;
  }

  return events;
}
