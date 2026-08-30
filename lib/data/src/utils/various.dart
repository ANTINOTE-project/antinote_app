import 'package:intl/intl.dart';

export 'package:material_ui/material_ui.dart' show DateTimeRange;

const typePrefix = 'type.antinote.fr';

/// Credit: https://stackoverflow.com/a/68847631 (by Raul Mabe)
extension IterableExt<T> on Iterable<T> {
  Iterable<T> superJoin(T separator) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return [];

    final l = [iterator.current];
    while (iterator.moveNext()) {
      l
        ..add(separator)
        ..add(iterator.current);
    }
    return l;
  }
}

final icalDateFormat = DateFormat("yyyyMMdd'T'HHmmss");
final icalUtcDateFormat = DateFormat("yyyyMMdd'T'HHmmss'Z'");

/// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
///
/// Written by András Szepesházi on Stackoverflow
int numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat('D').format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
///
/// Written by András Szepesházi on Stackoverflow
int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat('D').format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = numOfWeeks(date.year - 1);
  } else if (woy > numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}
