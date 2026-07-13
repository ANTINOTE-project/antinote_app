part of "../block.dart";

final class ClassEvent extends Event {
  final Class value;

  @override
  final int startSlot;
  @override
  final DateTime startTime;
  @override
  final int endSlot;
  @override
  final DateTime endTime;

  @override
  int get priority =>
      (value.canceled ||
          (value is Lesson && (value as Lesson).exemptedLabel != null))
      ? 2
      : (value.status == null ? 0 : 1);

  const ClassEvent({
    required this.value,
    required this.startSlot,
    required this.startTime,
    required this.endSlot,
    required this.endTime,
  });
}

List<ClassEvent> classBlocksForDay(
  List<Class> classes,
  SpecificInstanceParameters params,
) {
  return classes.mapL(
    (e) => ClassEvent(
      value: e,
      startSlot: e.blockSlot % params.slotsPerDay,
      startTime: e.startDate,
      endSlot: (e.blockSlot + e.blockLength) % params.slotsPerDay,
      endTime: e.endDate,
    ),
  );
}
