import "package:antinote_app/frontend/app.dart";
import "package:flutter/material.dart";

class MaterialTheme {
  const MaterialTheme();

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff63568f),
      surfaceTint: Color(0xff63568f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe8deff),
      onPrimaryContainer: Color(0xff4b3e76),
      secondary: Color(0xff6c538b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffeedbff),
      onSecondaryContainer: Color(0xff543b72),
      tertiary: Color(0xff7d5261),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd9e4),
      onTertiaryContainer: Color(0xff633b4a),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffdf7ff),
      onSurface: Color(0xff1c1b20),
      onSurfaceVariant: Color(0xff48454e),
      outline: Color(0xff79757f),
      outlineVariant: Color(0xffcac4cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff312f35),
      inversePrimary: Color(0xffcdbdff),
      primaryFixed: Color(0xffe8deff),
      onPrimaryFixed: Color(0xff1f1048),
      primaryFixedDim: Color(0xffcdbdff),
      onPrimaryFixedVariant: Color(0xff4b3e76),
      secondaryFixed: Color(0xffeedbff),
      onSecondaryFixed: Color(0xff270d43),
      secondaryFixedDim: Color(0xffd8bafa),
      onSecondaryFixedVariant: Color(0xff543b72),
      tertiaryFixed: Color(0xffffd9e4),
      onTertiaryFixed: Color(0xff31111e),
      tertiaryFixedDim: Color(0xffeeb8ca),
      onTertiaryFixedVariant: Color(0xff633b4a),
      surfaceDim: Color(0xffddd8e0),
      surfaceBright: Color(0xfffdf7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2fa),
      surfaceContainer: Color(0xfff2ecf4),
      surfaceContainerHigh: Color(0xffece6ee),
      surfaceContainerHighest: Color(0xffe6e1e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3a2d64),
      surfaceTint: Color(0xff63568f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff72649f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff422a60),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff7c619b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff502b39),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8d6070),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf7ff),
      onSurface: Color(0xff121016),
      onSurfaceVariant: Color(0xff37353d),
      outline: Color(0xff54515a),
      outlineVariant: Color(0xff6f6b75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff312f35),
      inversePrimary: Color(0xffcdbdff),
      primaryFixed: Color(0xff72649f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff594c85),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff7c619b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff624981),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff8d6070),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff724958),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffcac5cd),
      surfaceBright: Color(0xfffdf7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2fa),
      surfaceContainer: Color(0xffece6ee),
      surfaceContainerHigh: Color(0xffe0dbe3),
      surfaceContainerHighest: Color(0xffd5d0d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff302359),
      surfaceTint: Color(0xff63568f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff4d4079),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff382055),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff563e74),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff44212f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff653d4c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf7ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2d2b33),
      outlineVariant: Color(0xff4b4851),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff312f35),
      inversePrimary: Color(0xffcdbdff),
      primaryFixed: Color(0xff4d4079),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff362960),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff563e74),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff3f275c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff653d4c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4c2735),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbcb7bf),
      surfaceBright: Color(0xfffdf7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4eff7),
      surfaceContainer: Color(0xffe6e1e9),
      surfaceContainerHigh: Color(0xffd8d3db),
      surfaceContainerHighest: Color(0xffcac5cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcdbdff),
      surfaceTint: Color(0xffcdbdff),
      onPrimary: Color(0xff34275e),
      primaryContainer: Color(0xff4b3e76),
      onPrimaryContainer: Color(0xffe8deff),
      secondary: Color(0xffd8bafa),
      onSecondary: Color(0xff3c245a),
      secondaryContainer: Color(0xff543b72),
      onSecondaryContainer: Color(0xffeedbff),
      tertiary: Color(0xffeeb8ca),
      onTertiary: Color(0xff492533),
      tertiaryContainer: Color(0xff633b4a),
      onTertiaryContainer: Color(0xffffd9e4),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141318),
      onSurface: Color(0xffe6e1e9),
      onSurfaceVariant: Color(0xffcac4cf),
      outline: Color(0xff938f99),
      outlineVariant: Color(0xff48454e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e9),
      inversePrimary: Color(0xff63568f),
      primaryFixed: Color(0xffe8deff),
      onPrimaryFixed: Color(0xff1f1048),
      primaryFixedDim: Color(0xffcdbdff),
      onPrimaryFixedVariant: Color(0xff4b3e76),
      secondaryFixed: Color(0xffeedbff),
      onSecondaryFixed: Color(0xff270d43),
      secondaryFixedDim: Color(0xffd8bafa),
      onSecondaryFixedVariant: Color(0xff543b72),
      tertiaryFixed: Color(0xffffd9e4),
      onTertiaryFixed: Color(0xff31111e),
      tertiaryFixedDim: Color(0xffeeb8ca),
      onTertiaryFixedVariant: Color(0xff633b4a),
      surfaceDim: Color(0xff141318),
      surfaceBright: Color(0xff3a383e),
      surfaceContainerLowest: Color(0xff0f0d13),
      surfaceContainerLow: Color(0xff1c1b20),
      surfaceContainer: Color(0xff201f24),
      surfaceContainerHigh: Color(0xff2b292f),
      surfaceContainerHighest: Color(0xff36343a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe2d7ff),
      surfaceTint: Color(0xffcdbdff),
      onPrimary: Color(0xff291c52),
      primaryContainer: Color(0xff9688c5),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffead4ff),
      onSecondary: Color(0xff31194e),
      secondaryContainer: Color(0xffa185c1),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd0df),
      onTertiary: Color(0xff3d1b28),
      tertiaryContainer: Color(0xffb48394),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe0dae5),
      outline: Color(0xffb5b0bb),
      outlineVariant: Color(0xff938e99),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e9),
      inversePrimary: Color(0xff4c3f77),
      primaryFixed: Color(0xffe8deff),
      onPrimaryFixed: Color(0xff14033d),
      primaryFixedDim: Color(0xffcdbdff),
      onPrimaryFixedVariant: Color(0xff3a2d64),
      secondaryFixed: Color(0xffeedbff),
      onSecondaryFixed: Color(0xff1c0139),
      secondaryFixedDim: Color(0xffd8bafa),
      onSecondaryFixedVariant: Color(0xff422a60),
      tertiaryFixed: Color(0xffffd9e4),
      onTertiaryFixed: Color(0xff240614),
      tertiaryFixedDim: Color(0xffeeb8ca),
      onTertiaryFixedVariant: Color(0xff502b39),
      surfaceDim: Color(0xff141318),
      surfaceBright: Color(0xff46434a),
      surfaceContainerLowest: Color(0xff08070c),
      surfaceContainerLow: Color(0xff1e1d22),
      surfaceContainer: Color(0xff29272d),
      surfaceContainerHigh: Color(0xff343238),
      surfaceContainerHighest: Color(0xff3f3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff4edff),
      surfaceTint: Color(0xffcdbdff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffc9b9fb),
      onPrimaryContainer: Color(0xff0e0034),
      secondary: Color(0xfff8ecff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffd4b6f6),
      onSecondaryContainer: Color(0xff14002d),
      tertiary: Color(0xffffebf0),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffeab4c6),
      onTertiaryContainer: Color(0xff1d020e),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff4eef9),
      outlineVariant: Color(0xffc6c0cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e9),
      inversePrimary: Color(0xff4c3f77),
      primaryFixed: Color(0xffe8deff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffcdbdff),
      onPrimaryFixedVariant: Color(0xff14033d),
      secondaryFixed: Color(0xffeedbff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffd8bafa),
      onSecondaryFixedVariant: Color(0xff1c0139),
      tertiaryFixed: Color(0xffffd9e4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffeeb8ca),
      onTertiaryFixedVariant: Color(0xff240614),
      surfaceDim: Color(0xff141318),
      surfaceBright: Color(0xff524f55),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f24),
      surfaceContainer: Color(0xff312f35),
      surfaceContainerHigh: Color(0xff3d3a41),
      surfaceContainerHighest: Color(0xff48464c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: const TextTheme().apply(
      fontFamily: App.fontFamily,
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
