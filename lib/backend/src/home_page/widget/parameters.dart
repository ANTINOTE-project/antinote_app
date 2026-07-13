abstract class WidgetParameter<T> extends Enum {}

sealed class WidgetParameterDescriptor<R, P> {
  final String id;
  final P? defaultValue;

  P read(R raw);
  R write(P parsed);

  const WidgetParameterDescriptor({required this.id, this.defaultValue});
}

final class IntWidgetParameter extends WidgetParameterDescriptor<int, int> {
  const new({
    required super.id,
    super.defaultValue,
    this.minimum,
    this.maximum,
  });

  final int? minimum;
  final int? maximum;

  @override
  int read(int raw) => raw.clamp(minimum ?? raw, maximum ?? raw);
  @override
  int write(int parsed) => parsed;
}

final class BooleanWidgetParameter
    extends WidgetParameterDescriptor<bool, bool> {
  const new({required super.id, super.defaultValue});

  @override
  bool read(bool raw) => raw;
  @override
  bool write(bool parsed) => parsed;
}

final class DateTimeWidgetParameter
    extends WidgetParameterDescriptor<int, DateTime> {
  const DateTimeWidgetParameter.dateTime({
    required super.id,
    super.defaultValue,
  }) : dateOnly = false;

  const DateTimeWidgetParameter.date({required super.id, super.defaultValue})
    : dateOnly = true;

  final bool dateOnly;

  @override
  DateTime read(int raw) =>
      DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);

  @override
  int write(DateTime parsed) => parsed.millisecondsSinceEpoch;
}

final class DurationWidgetParameter
    extends WidgetParameterDescriptor<int, Duration> {
  const new({required super.id, super.defaultValue});

  @override
  Duration read(int raw) => Duration(milliseconds: raw);

  @override
  int write(Duration parsed) => parsed.inMilliseconds;
}
