import "package:antinote/antinote.dart";

part "class/block.dart";
part "pause/block.dart";

typedef DayBlocks = List<Block>;

sealed class Block {
  int get startSlot;
  DateTime get startTime;
  int get endSlot;
  DateTime get endTime;

  const Block();
}

List<Block> blocksForDay(
  List<Class> classes,
  SpecificInstanceParameters parameters,
) {
  return [
    ...classBlocksForDay(classes),
    ...pauseBlocksForDay(classes, parameters),
  ]..sort((a, b) => a.startTime.compareTo(b.startTime));
}
