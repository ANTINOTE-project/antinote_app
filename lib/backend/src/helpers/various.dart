// Credit: https://stackoverflow.com/a/68847631 (by Raul Mabe)
import "package:antinote/antinote.dart";
import "package:intl/intl.dart";

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

extension AsRelativeDateString on DateTime {
  static final DateFormat _shortDateFormatter = DateFormat("EEE, MMM dd");
  static final DateFormat _numericDateFormatter = DateFormat("dd MMM");
  static final DateFormat _shortTimeFormatter = DateFormat("HH:mm");
  static final DateFormat _longDateFormatter = DateFormat("dd/MM/yy");

  String asLongNumericDate() {
    return _longDateFormatter.format(this);
  }

  String asNumericDate() {
    return _numericDateFormatter.format(this);
  }

  String asRelativeDate([bool dayOnly = true]) {
    var dayTitle = _shortDateFormatter.format(this);
    if (DateTime.now().toUtc().toDay() == this) {
      dayTitle = "Aujourd'hui";
    } else if (DateTime.now().add(const Duration(days: 1)).toUtc().toDay() == this) {
      dayTitle = "Demain";
    } else if (DateTime.now().subtract(const Duration(days: 1)).toUtc().toDay() == this) {
      dayTitle = "Hier";
    }

    if (!dayOnly) {
      dayTitle += " à ${_shortTimeFormatter.format(this)}";
    }

    return dayTitle;
  }

  static final DateFormat _shortWeekdayFormatter = DateFormat("EEE");

  String asShortWeekday([bool dayOnly = true]) {
    return _shortWeekdayFormatter.format(this);
  }
}

final icalDateFormat = DateFormat("yyyyMMdd'T'HHmmss");
final icalUtcDateFormat = DateFormat("yyyyMMdd'T'HHmmss'Z'");

/// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
///
/// Written by András Szepesházi on Stackoverflow
int numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
///
/// Written by András Szepesházi on Stackoverflow
int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = numOfWeeks(date.year - 1);
  } else if (woy > numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}
