import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:flutter/material.dart";

class Utils {
  Utils._();

  static String formatNumber(double? value, {int digits = 2}) {
    if (value == null || value.isNaN) return "—";

    return value.toStringAsFixed(digits);
  }

  static ColorScheme harmonizeWithAccent(ColorScheme base, int designColor) {
    return ColorScheme.fromSeed(seedColor: Color(designColor));
  }

  static String getExamComment(BuildContext context, Exam exam) {
    final isNotEmpty = exam.comment?.trim().isNotEmpty ?? false;
    return isNotEmpty
        ? exam.comment!.trim()
        : context.l10n.gradeOf(exam.service.name);
  }

  static String formatDuration(Duration d) {
    return "${d.inHours > 0 ? "${d.inHours}h " : ""}${d.inMinutes % 60} min";
  }

  static String formatDurationCompact(Duration d) {
    if (d.inMinutes > 60) {
      return "${d.inHours > 0 ? "${d.inHours}h" : ""}${d.inMinutes % 60}";
    }

    return "${d.inMinutes % 60} min";
  }

  static ColorScheme buildColorScheme(BuildContext context, int? color) {
    if (color == null) return context.c;

    return ColorScheme.fromSeed(
      seedColor: Color(color),
      brightness: context.c.brightness,
    );
  }
}

class ReversedCurve extends Curve {
  const ReversedCurve(this.curve);

  final Curve curve;

  @override
  double transformInternal(double t) => 1.0 - curve.transform(t);
}

/// Both dates are inclusive.
typedef DateRange = DateTimeRange<DateTime>;

extension AsDateRange on DateTime {
  DateRange asDateRange() => DateRange(start: this, end: this);
}

extension DateRangeUtils on DateRange {
  String pprint(BuildContext context) => start == end
      ? start.asRelativeDate(context)
      : "${start.asRelativeDate(context)} — ${end.asRelativeDate(context)}";
}

extension DateTimeInDateRange on DateRange {
  List<DateTime> listDays() {
    List<DateTime> days = [];
    for (
      DateTime date = start.copyWith();
      !date.isAfter(end);
      date = date.add(const Duration(days: 1))
    ) {
      days.add(date);
    }

    return days;
  }

  bool contains(DateTime day) {
    return !day.isBefore(start) && !day.isAfter(end);
  }

  bool containsRange(DateRange range) {
    return contains(range.start) && contains(range.end);
  }
}

typedef Arrangement<T> = Map<DateTime, T>;

final class WeekMappedViewConfiguration {
  final int columnCount;

  /// Inclusive
  final double minWidth;

  /// Exclusive
  final double maxWidth;
  final bool snapToWeeks;

  const WeekMappedViewConfiguration({
    required this.columnCount,
    required this.minWidth,
    required this.maxWidth,
    required this.snapToWeeks,
  });

  static const dayConfig = WeekMappedViewConfiguration(
    columnCount: 1,
    minWidth: 0,
    maxWidth: 600,
    snapToWeeks: false,
  );

  static const threeDaysConfig = WeekMappedViewConfiguration(
    columnCount: 3,
    minWidth: 600,
    maxWidth: 840,
    snapToWeeks: false,
  );

  static const weekConfig = WeekMappedViewConfiguration(
    columnCount: 7,
    minWidth: 840,
    maxWidth: double.infinity,
    snapToWeeks: true,
  );

  // Source: https://m3.material.io/foundations/layout/applying-layout/window-size-classes#9e94b1fb-e842-423f-9713-099b40f13922
  static const List<WeekMappedViewConfiguration> defaultConfigs = [
    dayConfig,
    threeDaysConfig,
    weekConfig,
  ];

  List<DateRange> daysToRangeList(
    List<DateTime> days,
    SpecificInstanceParameters parameters,
  ) {
    // We need to align the groups by week in this case.
    if (snapToWeeks) {
      final Map<int, DateRange> ranges = {};
      for (final day in days) {
        final weekNumber = parameters.getWeekNumberForDate(day);
        if (ranges.containsKey(weekNumber)) {
          ranges[weekNumber] = DateRange(
            start: ranges[weekNumber]!.start,
            end: day,
          );
        } else {
          ranges[weekNumber] = DateRange(start: day, end: day);
        }
      }

      return (ranges.entries.toList(growable: false)
            ..sort((a, b) => a.key.compareTo(b.key)))
          .map((e) => e.value)
          .toList(growable: false);
    }

    final List<DateRange> ranges = [];
    for (int i = 0; i < days.length; i += columnCount) {
      final start = days[i];
      final end = days.elementAtOrNull(i + columnCount - 1) ?? days.last;
      ranges.add(DateRange(start: start, end: end));
    }

    return ranges;
  }
}

extension PickViewConfiguration on Iterable<WeekMappedViewConfiguration> {
  WeekMappedViewConfiguration pickConfig(BuildContext context) {
    final width = MediaQuery.widthOf(context);
    return firstWhere(
      (element) => element.minWidth <= width && element.maxWidth > width,
      orElse: () =>
          singleOrNull ??
          firstWhere(
            (element) => element.minWidth <= width,
            orElse: () => first,
          ),
    );
  }
}

extension AccountStorageExtension on BuildContext {
  AccountStorage get as => AccountStorage.of(this);
}

extension ColorsExtension on BuildContext {
  ColorScheme get c => ColorScheme.of(this);
}

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension SessionManagerExtension on BuildContext {
  SessionManager get sm => SessionManager.of(this);
}

const fakeGrade = Grade.defaultUnknownGrade;

const fakeServices = [
  Service(
    id: "1",
    name: "Mathématiques",
    type: null,
    order: null,
    selfAverage: null,
    theoreticalMaxGrade: null,
    defaultTheoreticalMaxGrade: null,
    classAverage: null,
    minGrade: null,
    maxGrade: null,
    color: null,
    inGroups: null,
  ),
  Service(
    id: "2",
    name: "Français",
    type: null,
    order: null,
    selfAverage: null,
    theoreticalMaxGrade: null,
    defaultTheoreticalMaxGrade: null,
    classAverage: null,
    minGrade: null,
    maxGrade: null,
    color: null,
    inGroups: null,
  ),
  Service(
    id: "3",
    name: "Histoire",
    type: null,
    order: null,
    selfAverage: null,
    theoreticalMaxGrade: null,
    defaultTheoreticalMaxGrade: null,
    classAverage: null,
    minGrade: null,
    maxGrade: null,
    color: null,
    inGroups: null,
  ),
  Service(
    id: "4",
    name: "Anglais",
    type: null,
    order: null,
    selfAverage: null,
    theoreticalMaxGrade: null,
    defaultTheoreticalMaxGrade: null,
    classAverage: null,
    minGrade: null,
    maxGrade: null,
    color: null,
    inGroups: null,
  ),
  Service(
    id: "5",
    name: "Physique",
    type: null,
    order: null,
    selfAverage: null,
    theoreticalMaxGrade: null,
    defaultTheoreticalMaxGrade: null,
    classAverage: null,
    minGrade: null,
    maxGrade: null,
    color: null,
    inGroups: null,
  ),
];

const fakePeriod = Period(
  id: null,
  name: "",
  type: null,
  notationPeriodType: null,
  startDate: null,
  endDate: null,
);

final fakeExams = List.filled(
  20,
  Exam(
    id: "",
    type: 0,
    selfGrade: fakeGrade,
    theoreticalMaxGrade: fakeGrade,
    defaultMaxGrade: fakeGrade,
    date: DateTime.now(),
    service: fakeServices.first,
    period: fakePeriod,
    themes: [],
    classAverage: null,
    isInGroups: null,
    maxGrade: null,
    minGrade: null,
    comment: null,
    coefficient: null,
    isOptional: null,
    isBonus: null,
    isCountedAs20TheoreticalMaxGrade: null,
  ),
);

final fakeServiceGradeList = {
  for (final service in fakeServices) service: fakeExams.take(3).toList(),
};
