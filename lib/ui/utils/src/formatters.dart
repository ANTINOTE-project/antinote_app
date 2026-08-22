import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

extension StringExt on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension AsRelativeDateString on DateTime {
  static final DateFormat _numericDateFormatter = DateFormat('dd MMM');
  static final DateFormat _shortTimeFormatter = DateFormat('HH:mm');
  static final DateFormat _longDateFormatter = DateFormat('dd/MM/yy');

  String asLongNumericDate() {
    return _longDateFormatter.format(this);
  }

  String asNumericDate() {
    return _numericDateFormatter.format(this);
  }

  String asNumericTime() {
    return _shortTimeFormatter.format(this);
  }

  String asRelativeDate(BuildContext context, [bool dayOnly = true]) {
    var dayTitle = context.l10n.shortDate(this);

    final today = DateTime.now().toUtc().toDay();
    final thisDay = toUtc().toDay();

    if (today == thisDay) {
      dayTitle = context.l10n.today;
    } else if (today.add(const Duration(days: 1)) == thisDay) {
      dayTitle = context.l10n.tomorrow;
    } else if (today.subtract(const Duration(days: 1)) == thisDay) {
      dayTitle = context.l10n.yesterday;
    }

    if (!dayOnly) {
      dayTitle += ' à ${_shortTimeFormatter.format(this)}';
    }

    return dayTitle;
  }

  String asRelativeWeekday(BuildContext context) {
    final today = DateTime.now().toUtc().toDay();
    final thisDay = toUtc().toDay();

    if (today == thisDay) {
      return context.l10n.today;
    } else if (today.add(const Duration(days: 1)) == thisDay) {
      return context.l10n.tomorrow;
    } else if (today.subtract(const Duration(days: 1)) == thisDay) {
      return context.l10n.yesterday;
    }

    final formatted = context.l10n.shortWeekday(this);
    return formatted.capitalize();
  }
}

abstract class Formatters {
  Formatters._();

  static String formatNumber(double? value, {int digits = 2}) {
    if (value == null || value.isNaN) return '—';
    return value.toStringAsFixed(digits);
  }

  static String formatDurationInMinutes(Duration d) {
    return '${d.inMinutes} min';
  }

  static String formatDuration(Duration d, {bool isCompact = false}) {
    if (d.inMinutes > 60) {
      if (isCompact) {
        return '${d.inHours}h${d.inMinutes % 60}';
      }

      return "${d.inHours}h${d.inMinutes % 60 == 0 ? '' : ' ${d.inMinutes % 60} min'}";
    }

    return '${d.inMinutes} min';
  }
}
