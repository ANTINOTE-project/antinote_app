part of '../block.dart';

final class const ClassEvent({
  required final Class value,
  @override required final DateTimeRange range,
}) extends Event {
  @override
  int get priority => !selfPresent ? 2 : (value.status == null ? 0 : 1);

  // TODO: Move this to an extension on class (or move it directly to antinote)
  // TODO: and replace duplicated code.
  bool get selfPresent =>
      !value.canceled &&
      !(value is Lesson && (value as Lesson).exemptedLabel != null);
}

List<ClassEvent> classEventsForDay(
  List<Class> classes,
  SpecificInstanceParameters params,
) {
  return classes.mapL(
    (e) => ClassEvent(
      value: e,
      range: .new(start: e.startDate, end: e.endDate),
    ),
  );
}
