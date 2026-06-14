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
  static const _isDynamicKey = "is_dynamic";
  static const defaultSeed = Color(0xff904a40);

  Color _seedColor = defaultSeed;
  Color get seedColor => _seedColor;

  bool _isDynamic = false;
  bool get isDynamic => _isDynamic;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  ColorScheme _scheme(Brightness brightness, double contrastLevel) {
    return ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
    );
  }

  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: "SNPro",
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }

  ColorScheme get light => _scheme(.light, 0);
  ColorScheme get lightMediumContrast => _scheme(.light, .5);
  ColorScheme get lightHighContrast => _scheme(.light, 1);
  ColorScheme get dark => _scheme(.dark, 0);
  ColorScheme get darkMediumContrast => _scheme(.dark, .5);
  ColorScheme get darkHighContrast => _scheme(.dark, 1);

  Future<void> setSeedColor(Color color) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setInt(_seedKey, color.toARGB32());
    _seedColor = color;

    notifyListeners();
  }

  Future<void> setIsDynamic(bool value) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(_isDynamicKey, value);
    _isDynamic = value;

    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = SharedPreferencesAsync();
    final seed = await prefs.getInt(_seedKey);
    final dynamic = await prefs.getBool(_isDynamicKey);

    if (seed != null) {
      _seedColor = Color(seed);
    }

    if (dynamic != null) {
      _isDynamic = dynamic;
    }

    notifyListeners();
  }
}
