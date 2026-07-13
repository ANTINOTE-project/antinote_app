part of "../block.dart";

class MealEvent extends Event {
  @override
  final DateTime startTime;
  @override
  final int startSlot;
  @override
  final DateTime endTime;
  @override
  final int endSlot;

  @override
  int get priority => 3;

  const new({
    required this.startTime,
    required this.startSlot,
    required this.endTime,
    required this.endSlot,
  });
}

List<MealEvent> mealBlocksForDay(
  List<Class> classes,
  SpecificInstanceParameters parameters,
) {
  if (classes.isEmpty) return [];

  final day = classes.first.startDate.toDay();

  if (!parameters.lunchActivation ||
      !parameters.lunchDays.contains(day.weekday - 1)) {
    return [];
  }

  final mealTimeSlots = List<int>.generate(
    parameters.lunchEndSlot - parameters.lunchStartSlot,
    (index) => parameters.lunchStartSlot + index,
  );

  for (final clazz in classes) {
    if (clazz.canceled || (clazz is Lesson && clazz.exemptedLabel != null)) {
      continue;
    }

    for (
      int slot = clazz.blockSlot % parameters.slotsPerDay;
      slot < (clazz.blockSlot + clazz.blockLength) % parameters.slotsPerDay;
      slot++
    ) {
      mealTimeSlots.remove(slot);
      if (mealTimeSlots.isEmpty) return const [];
    }
  }

  final blocks = <MealEvent>[];

  var blockStart = mealTimeSlots.removeAt(0);
  var blockEnd = blockStart;
  while (mealTimeSlots.isNotEmpty) {
    var curSlot = mealTimeSlots.removeAt(0);

    if (blockEnd + 1 < curSlot) {
      final startTime = parameters.timeForSlot(
        parameters.starts[blockStart],
        day,
      );
      final endTime = parameters.timeForSlot(parameters.endings[blockEnd], day);

      if (!startTime.isAtSameMomentAs(endTime)) {
        blocks.add(
          MealEvent(
            startTime: startTime,
            startSlot: blockStart,
            endTime: endTime,
            endSlot: blockEnd,
          ),
        );
      }

      blockStart = curSlot;
      blockEnd = curSlot;
    } else {
      blockEnd = curSlot;
    }
  }

  final startTime = parameters.timeForSlot(parameters.starts[blockStart], day);
  final endTime = parameters.timeForSlot(parameters.endings[blockEnd], day);

  if (!startTime.isAtSameMomentAs(endTime)) {
    blocks.add(
      MealEvent(
        startTime: startTime,
        startSlot: blockStart,
        endTime: endTime,
        endSlot: blockEnd + 1,
      ),
    );
  }

  return blocks;
}
