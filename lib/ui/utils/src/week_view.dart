import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/src/date.dart';
import 'package:flutter/material.dart';

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
