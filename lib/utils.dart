import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:flutter/material.dart";

import "frontend/extensions/l10n.dart";
import "frontend/screens/shell/screens/timetable/body.dart";

class Utils {
  Utils._();

  static String formatNumber(double? value) {
    if (value == null || value.isNaN) return "—";

    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  static (
    Color color,
    Color backgroundColor,
    Color borderColor,
    Color titleColor,
    Color subtitleColor,
  )
  adaptColorPair(int? colorValue, ColorScheme scheme) {
    if (colorValue == null) {
      return (
        scheme.onSurface,
        scheme.surfaceContainerHigh,
        scheme.outlineVariant,
        scheme.onSurface,
        scheme.onSurfaceVariant,
      );
    }

    final hsl = HSLColor.fromColor(Color(colorValue));
    final isLight = scheme.brightness == Brightness.light;

    final base = hsl
        .withLightness(isLight ? 0.40 : 0.70)
        .withSaturation(hsl.saturation.clamp(0.4, 1.0))
        .toColor();

    final background = hsl
        .withLightness(isLight ? 0.92 : 0.15)
        .withSaturation(hsl.saturation.clamp(0.15, 0.4))
        .toColor();

    final border = hsl
        .withLightness(isLight ? 0.55 : 0.35)
        .withSaturation(hsl.saturation.clamp(0.2, 0.5))
        .toColor();

    final title = hsl
        .withLightness(isLight ? 0.45 : 0.9)
        .withSaturation(hsl.saturation.clamp(0.6, 1.0))
        .toColor();

    final subtitle = hsl
        .withLightness(isLight ? 0.60 : 0.58)
        .withSaturation(hsl.saturation.clamp(0.15, 0.35))
        .toColor();

    return (base, background, border, title, subtitle);
  }

  static String getExamComment(BuildContext context, Exam exam) {
    final isNotEmpty = exam.comment?.trim().isNotEmpty ?? false;
    return isNotEmpty ? exam.comment!.trim() : context.l10n.gradeOf(exam.service.name);
  }

  static String _formatAttendants(List teachers, List personal) => [
    teachers.map((e) => e.name).join(", "),
    if (personal.isNotEmpty) '(+ ${personal.map((e) => e.name).join(', ')})',
  ].join(" ");

  static int? _resolveAccentColor(int? subjectBg, int? classBg) => subjectBg ?? (classBg);

  static ClassInfo getInfoForClass(BuildContext context, Class clazz) => switch (clazz) {
    Lesson(
      subject: final subject,
      status: final status,
      canceled: final canceled,
      exemptedLabel: final exempted,
      teachers: final teachers,
      personals: final personal,
      groups: final groups,
      classrooms: final classrooms,
      notebookEntryPreview: final preview,
      backgroundColor: final bg,
    ) =>
      (
        baseTitle: subject?.name ?? context.l10n.noSubject,
        status: status?.toUpperCase() ?? (canceled ? context.l10n.cancelled : exempted),
        attendants: _formatAttendants(teachers, personal),
        groups: groups.isEmpty ? null : groups.map((e) => e.label).join(", "),
        location: classrooms.map((e) => e.label).join(", "),
        start: clazz.startDate,
        end: clazz.endDate,
        accentColor: _resolveAccentColor(subject?.backgroundColor, bg),
        cancelled: canceled || exempted != null,
        isExam: preview?.isTest ?? false,
      ),

    Activity(
      title: final title,
      attendants: final attendants,
      startDate: final startDate,
      endDate: final endDate,
    ) =>
      (
        baseTitle: title,
        status: null,
        attendants: attendants.join(", "),
        groups: null,
        location: null,
        start: startDate,
        end: endDate,
        accentColor: _resolveAccentColor(null, clazz.backgroundColor),
        cancelled: false,
        isExam: false,
      ),

    Detention(
      title: final title,
      teachers: final teachers,
      personals: final personal,
      classrooms: final classrooms,
      startDate: final startDate,
      endDate: final endDate,
    ) =>
      (
        baseTitle: title ?? context.l10n.detention,
        status: null,
        attendants: _formatAttendants(teachers, personal),
        groups: null,
        location: classrooms.map((e) => e.label).join(", "),
        start: startDate,
        end: endDate,
        accentColor: _resolveAccentColor(null, clazz.backgroundColor),
        cancelled: false,
        isExam: false,
      ),
  };

  static String formatDuration(Duration d) {
    return "${d.inHours > 0 ? "${d.inHours}h " : ""}${d.inMinutes % 60} min";
  }

  static String formatDurationCompact(Duration d) {
    if (d.inMinutes > 60) {
      return "${d.inHours > 0 ? "${d.inHours}h" : ""}${d.inMinutes % 60}";
    }

    return "${d.inMinutes % 60} min";
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

  List<DateRange> daysToRangeList(List<DateTime> days, SpecificInstanceParameters parameters) {
    // We need to align the groups by week in this case.
    if (snapToWeeks) {
      final Map<int, DateRange> ranges = {};
      for (final day in days) {
        final weekNumber = parameters.getWeekNumberForDate(day);
        if (ranges.containsKey(weekNumber)) {
          ranges[weekNumber] = DateRange(start: ranges[weekNumber]!.start, end: day);
        } else {
          ranges[weekNumber] = DateRange(start: day, end: day);
        }
      }

      return (ranges.entries.toList(
        growable: false,
      )..sort((a, b) => a.key.compareTo(b.key))).map((e) => e.value).toList(growable: false);
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
          singleOrNull ?? firstWhere((element) => element.minWidth <= width, orElse: () => first),
    );
  }
}
