import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:material_ui/material_ui.dart';

/// Both dates are inclusive.
typedef DateRange = DateTimeRange<Date>;

extension DateRangeUtils on DateRange {
  String pprint(BuildContext context) {
    return start == end
        ? start.asRelativeDate(context)
        : '${start.asRelativeDate(context)} — ${end.asRelativeDate(context)}';
  }
}

extension DaysInDateRange on DateRange {
  List<Date> listDays() {
    List<Date> days = [];

    for (
      Date date = start.toDay(true);
      !date.isAfter(end);
      date = date.add(const Duration(days: 1)).toDay()
    ) {
      days.add(date);
    }

    return days;
  }
}

extension DateTimeInDateTimeRange<T extends DateTime> on DateTimeRange<T> {
  bool contains(T time) {
    return !time.isBefore(start) && !time.isAfter(end);
  }

  bool containsRange(DateTimeRange<T> range) {
    return contains(range.start) && contains(range.end);
  }
}
