part of "../block.dart";

final class ClassBlock extends Block {
  final List<List<Class>> configurations;
  @override
  final int startSlot;
  @override
  final DateTime startTime;
  @override
  final int endSlot;
  @override
  final DateTime endTime;

  const ClassBlock({
    required this.configurations,
    required this.startSlot,
    required this.startTime,
    required this.endSlot,
    required this.endTime,
  });

  static const _priorityCount = 3;
  static int _classDisplayReversePriority(Class clazz) =>
      clazz.canceled ? 2 : (clazz.status == null ? 1 : 0);

  factory ClassBlock.createConfigurations({
    required List<Class> classes,
    required int startSlot,
    required DateTime startTime,
    required int endSlot,
    required DateTime endTime,
  }) {
    final remaining = <int, List<Class>>{
      for (int i = 0; i < _priorityCount; i++) i: [],
    };

    for (final remainingClass in classes) {
      remaining[_classDisplayReversePriority(remainingClass)]!.add(
        remainingClass,
      );
    }

    for (final key in remaining.keys) {
      remaining[key]?.sort((a, b) => a.blockSlot.compareTo(b.blockSlot));
    }

    final configs = <List<Class>>[];
    final curConfig = <Class>[];

    while (remaining.values.any((element) => element.isNotEmpty)) {
      for (int i = 0; i < _priorityCount; i++) {
        final curCandidates = <Class>[];

        for (final candidate in remaining[i]!) {
          if (curConfig.any(
            (element) =>
                (element.blockSlot <= candidate.blockSlot &&
                    candidate.blockSlot <
                        element.blockSlot + element.blockLength) ||
                (candidate.blockSlot <= element.blockSlot &&
                    element.blockSlot <
                        candidate.blockSlot + candidate.blockLength),
          )) {
            continue;
          }

          curCandidates.add(candidate);
        }

        curConfig.addAll(curCandidates);
        remaining[i]!.removeWhere((element) => curCandidates.contains(element));
      }

      configs.add(curConfig.toList(growable: false));
      curConfig.clear();
    }

    return ClassBlock(
      configurations: configs,
      startSlot: startSlot,
      startTime: startTime,
      endSlot: endSlot,
      endTime: endTime,
    );
  }
}

List<ClassBlock> classBlocksForDay(List<Class> classes) {
  classes.sort((a, b) => a.blockSlot.compareTo(b.blockSlot));

  List<ClassBlock> blocks = [];

  int? blockStart;
  DateTime? blockStartTime;
  int? blockEnd;
  DateTime? blockEndTime;
  List<Class> curClasses = [];

  for (final clazz in classes) {
    if (blockStart == null) {
      blockStart = clazz.blockSlot;
      blockStartTime = clazz.startDate;
      blockEnd = clazz.blockSlot + clazz.blockLength;
      blockEndTime = clazz.endDate;

      curClasses.add(clazz);

      continue;
    }

    if (clazz.blockSlot < blockEnd!) {
      curClasses.add(clazz);
      if (clazz.blockSlot + clazz.blockLength > blockEnd) {
        blockEnd = clazz.blockSlot + clazz.blockLength;
        blockEndTime = clazz.endDate;
      }
    } else {
      blocks.add(
        ClassBlock.createConfigurations(
          classes: curClasses,
          startSlot: blockStart,
          startTime: blockStartTime!,
          endSlot: blockEnd,
          endTime: blockEndTime!,
        ),
      );

      blockStart = clazz.blockSlot;
      blockStartTime = clazz.startDate;
      blockEnd = clazz.blockSlot + clazz.blockLength;
      blockEndTime = clazz.endDate;

      curClasses.clear();
      curClasses.add(clazz);
    }
  }

  if (curClasses.isNotEmpty) {
    blocks.add(
      ClassBlock.createConfigurations(
        classes: curClasses,
        startSlot: blockStart!,
        startTime: blockStartTime!,
        endSlot: blockEnd!,
        endTime: blockEndTime!,
      ),
    );
  }

  return blocks;
}
