abstract class Formatters {
  Formatters._();

  static String formatNumber(double? value, {int digits = 2}) {
    if (value == null || value.isNaN) return "—";
    return value.toStringAsFixed(digits);
  }

  static String formatDurationInMinutes(Duration d) {
    return "${d.inMinutes} min";
  }

  static String formatDuration(Duration d, {bool isCompact = false}) {
    if (d.inMinutes > 60) {
      if (isCompact) {
        return "${d.inHours > 0 ? "${d.inHours}h" : ""}${d.inMinutes % 60}";
      }

      return "${d.inHours > 0 ? "${d.inHours}h " : ""}${d.inMinutes % 60} min";
    }

    return "${d.inMinutes} min";
  }
}
