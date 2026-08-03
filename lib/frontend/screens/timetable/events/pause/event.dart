part of '../block.dart';

final class PauseEvent extends Event {
  final String title;

  @override
  final int startSlot;
  @override
  final DateTime startTime;
  @override
  final int endSlot;
  @override
  final DateTime endTime;

  @override
  int get priority => 0;

  const new({
    required this.title,

    required this.startSlot,
    required this.startTime,
    required this.endSlot,
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
        startSlot: classBreak.slot % parameters.slotsPerDay,
        startTime: startTime,
        endSlot: (classBreak.slot + 1) % parameters.slotsPerDay,
        endTime: endTime,
      ),
    );
  }

  for (final clazz in classes) {
    if (clazz.canceled || (clazz is Lesson && clazz.exemptedLabel != null)) {
      continue;
    }

    final slot = clazz.blockSlot % parameters.slotsPerDay;
    final duration = clazz.blockLength;

    events.removeWhere(
      (element) =>
          slot < element.startSlot && element.startSlot < slot + duration,
    );

    if (events.isEmpty) break;
  }

  return events;
}
