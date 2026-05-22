class Utils {
  Utils._();

  static T guard<T>(T? value) {
    if (value == null) throw Exception("Unexpected null");
    return value;
  }

  static Future<void> futureNoop() async {}
  static void noop() {}
}
