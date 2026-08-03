import 'package:antinote_app/data/src/settings/category.dart';
import 'package:antinote_app/ui/screens/settings/screen.dart';
import 'package:flutter/material.dart';

class ThemeSettings extends SettingsCategory {
  @override
  String get name => 'theme';

  @override
  int get latestVersion => 1;

  @override
  Map<int, SettingsUpgradeTask> get upgradeTasks => {};

  @override
  List<dynamic> get registeredFields => [
    seedColor,
    isDynamic,
    showProfilePicture,
  ];

  Color get seedColor =>
      Color(get('seed_color') ?? AppColor.coral.color.toARGB32());
  Future<void> setSeedColor(Color value) => set('seed_color', value.toARGB32());

  bool get isDynamic => get('is_dynamic') ?? false;
  Future<void> setIsDynamic(bool value) => set('is_dynamic', value);

  bool get showProfilePicture => get('show_profile_picture') ?? true;
  Future<void> setShowProfilePicture(bool value) =>
      set('show_profile_picture', value);

  ColorScheme _scheme(Brightness brightness, double contrastLevel) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
      dynamicSchemeVariant: .vibrant,
    );
  }

  ThemeData create(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'SNPro',
      typography: Typography.material2021(colorScheme: colorScheme),
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
}
