import "package:antinote/antinote.dart";

final class ClassBlock {
  final List<Class> classes;
  final int startSlot;
  final int endSlot;

  const ClassBlock({
    required this.classes,
    required this.startSlot,
    required this.endSlot,
  });
}

List<ClassBlock> constructClassBlocksForDay(
  List<Class> classes,
  SpecificInstanceParameters parameters,
) {
  classes.sort((a, b) => a.blockSlot.compareTo(b.blockSlot));

  final remainingClasses = classes.toList();
  List<ClassBlock> blocks = [];

  int? blockStart;
  int? blockEnd;
  List<Class> curClasses = [];

  for (final clazz in remainingClasses) {
    if (blockStart == null) {
      blockStart = clazz.blockSlot;
      blockEnd = clazz.blockSlot + clazz.blockLength;
    }

    curClasses.add(clazz);

    if (clazz.blockSlot < blockStart + blockEnd!) {
      blockEnd = clazz.blockSlot + clazz.blockLength;
    } else {
      blocks.add(
        ClassBlock(classes: classes, startSlot: blockStart, endSlot: blockEnd),
      );
      curClasses = [];
    }
  }

  return blocks;
}
