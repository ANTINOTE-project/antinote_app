part of "../block.dart";

final class PauseBlock extends Event {
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

List<PauseBlock> pauseBlocksForDay(
  List<Class> classes,
  SpecificInstanceParameters parameters,
) {
  if (classes.isEmpty) return [];

  final date = classes.first.startDate.toDay();
  final blocks = <PauseBlock>[];

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

    blocks.add(
      PauseBlock(
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

    blocks.removeWhere(
      (element) =>
          slot < element.startSlot && element.startSlot < slot + duration,
    );

    if (blocks.isEmpty) break;
  }

  return blocks;
}
