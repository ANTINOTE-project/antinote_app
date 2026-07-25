abstract class WidgetParameter<T>({required final String code}) extends Enum;

final class const WidgetParameters<T extends WidgetParameter>({
  required final Map<T, dynamic> _params,
}) {
  P get<P>(WidgetParameter<P> key) => _params[key] as P;
}

sealed class WidgetParameterDescriptor<T extends WidgetParameter, R, P> {
  final T id;
  final P? defaultValue;

  P read(R raw);
  R write(P parsed);

  const WidgetParameterDescriptor({required this.id, this.defaultValue});
}

final class IntWidgetParameter<T extends WidgetParameter>
    extends WidgetParameterDescriptor<T, int, int> {
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

final class BooleanWidgetParameter<T extends WidgetParameter>
    extends WidgetParameterDescriptor<T, bool, bool> {
  const new({required super.id, super.defaultValue});

  @override
  bool read(bool raw) => raw;
  @override
  bool write(bool parsed) => parsed;
}

final class DateTimeWidgetParameter<T extends WidgetParameter>
    extends WidgetParameterDescriptor<T, int, DateTime> {
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

final class DurationWidgetParameter<T extends WidgetParameter>
    extends WidgetParameterDescriptor<T, int, Duration> {
  const new({required super.id, super.defaultValue});

  @override
  Duration read(int raw) => Duration(milliseconds: raw);

  @override
  int write(Duration parsed) => parsed.inMilliseconds;
}
