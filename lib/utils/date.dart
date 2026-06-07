import "package:antinote_app/backend/src/helpers/various.dart";
import "package:flutter/material.dart";

/// Both dates are inclusive.
typedef DateRange = DateTimeRange<DateTime>;

extension DateRangeUtils on DateRange {
  String pprint(BuildContext context) {
    return start == end
        ? start.asRelativeDate(context)
        : "${start.asRelativeDate(context)} — ${end.asRelativeDate(context)}";
  }
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
