import "package:antinote/antinote.dart";

final class ClassBlock {
  final List<List<Class>> configurations;
  final int startSlot;
  final int endSlot;

  const ClassBlock({
    required this.configurations,
    required this.startSlot,
    required this.endSlot,
  });

  static const _priorityCount = 3;
  static int _classDisplayReversePriority(Class clazz) =>
      clazz.canceled ? 2 : (clazz.status == null ? 1 : 0);

  factory ClassBlock.createConfigurations({
    required List<Class> classes,
    required int startSlot,
    required int endSlot,
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
      endSlot: endSlot,
    );
  }
}

List<ClassBlock> constructClassBlocksForDay(List<Class> classes) {
  classes.sort((a, b) => a.blockSlot.compareTo(b.blockSlot));

  List<ClassBlock> blocks = [];

  int? blockStart;
  int? blockEnd;
  List<Class> curClasses = [];

  for (final clazz in classes) {
    if (blockStart == null) {
      blockStart = clazz.blockSlot;
      blockEnd = clazz.blockSlot + clazz.blockLength;

      curClasses.add(clazz);

      continue;
    }

    if (clazz.blockSlot < blockEnd!) {
      curClasses.add(clazz);
      blockEnd = clazz.blockSlot + clazz.blockLength;
    } else {
      blocks.add(
        ClassBlock.createConfigurations(
          classes: curClasses,
          startSlot: blockStart,
          endSlot: blockEnd,
        ),
      );

      blockStart = clazz.blockSlot;
      blockEnd = clazz.blockSlot + clazz.blockLength;

      curClasses.clear();
      curClasses.add(clazz);
    }
  }

  if (curClasses.isNotEmpty) {
    blocks.add(
      ClassBlock.createConfigurations(
        classes: curClasses,
        startSlot: blockStart!,
        endSlot: blockEnd!,
      ),
    );
  }

  return blocks;
}
