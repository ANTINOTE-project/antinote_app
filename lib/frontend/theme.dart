import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ThemeScope extends InheritedWidget {
  final ThemeNotifier notifier;

  const ThemeScope({super.key, required this.notifier, required super.child});

  static ThemeNotifier of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(result != null, "No ThemeScope found in context");
    return result!.notifier;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) => false;
}

class ThemeNotifier extends ChangeNotifier {
  static const _seedKey = "seed_color";
  static const defaultSeed = Color(0xff904a40);

  Color _seedColor = defaultSeed;
  Color get seedColor => _seedColor;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  ColorScheme _scheme(Brightness brightness) {
    return ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness);
  }

  ThemeData _theme(Brightness brightness) {
    final colorScheme = _scheme(brightness);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: "SNPro",
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }

  ThemeData get light => _theme(.light);
  ThemeData get dark => _theme(.dark);

  Future<void> setSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_seedKey, color.toARGB32());
    _seedColor = color;

    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final seed = prefs.getInt(_seedKey);

    if (seed != null) {
      _seedColor = Color(seed);
    }

    notifyListeners();
  }
}
