import "package:antinote_app/frontend/app.dart";
import "package:flutter/material.dart";

class MaterialTheme {
  const MaterialTheme();

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF5B30D6),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE8DEFF),
      onPrimaryContainer: Color(0xFF1A0040),
      primaryFixed: Color(0xFFE8DEFF),
      primaryFixedDim: Color(0xFFBEA6FF),
      onPrimaryFixed: Color(0xFF1A0040),
      onPrimaryFixedVariant: Color(0xFF3D1F7A),
      inversePrimary: Color(0xFF7C4DFF),
      secondary: Color(0xFF7B4FD4),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFEEDBFF),
      onSecondaryContainer: Color(0xFF270D43),
      secondaryFixed: Color(0xFFEEDBFF),
      secondaryFixedDim: Color(0xFFD8BAFA),
      onSecondaryFixed: Color(0xFF1A0040),
      onSecondaryFixedVariant: Color(0xFF3C245A),
      tertiary: Color(0xFF9B3D88),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFD6F4),
      onTertiaryContainer: Color(0xFF38003A),
      tertiaryFixed: Color(0xFFF4D0EE),
      tertiaryFixedDim: Color(0xFFD896C8),
      onTertiaryFixed: Color(0xFF2D0A26),
      onTertiaryFixedVariant: Color(0xFF5C2A52),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: Color(0xFFFDF7FF),
      onSurface: Color(0xFF1C1730),
      onSurfaceVariant: Color(0xFF4A4560),
      outline: Color(0xFF7A7490),
      outlineVariant: Color(0xFFCAC4DC),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF312C45),
      onInverseSurface: Color(0xFFF3EEFF),
      surfaceTint: Color(0xFF5B30D6),
      surfaceDim: Color(0xFFDDD8E8),
      surfaceBright: Color(0xFFFDF7FF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF7F1FF),
      surfaceContainer: Color(0xFFF1EBFF),
      surfaceContainerHigh: Color(0xFFEBE5F9),
      surfaceContainerHighest: Color(0xFFE5DFF3),
    );
  }

  ThemeData light() => theme(lightScheme());

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF42189E),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF6B3EE8),
      onPrimaryContainer: Color(0xFFFFFFFF),
      primaryFixed: Color(0xFFE8DEFF),
      primaryFixedDim: Color(0xFFBEA6FF),
      onPrimaryFixed: Color(0xFF1A0040),
      onPrimaryFixedVariant: Color(0xFF2E1068),
      inversePrimary: Color(0xFF9E7FFF),
      secondary: Color(0xFF5A319C),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF8B5EE0),
      onSecondaryContainer: Color(0xFFFFFFFF),
      secondaryFixed: Color(0xFFEEDBFF),
      secondaryFixedDim: Color(0xFFD8BAFA),
      onSecondaryFixed: Color(0xFF1A0040),
      onSecondaryFixedVariant: Color(0xFF2C1250),
      tertiary: Color(0xFF782065),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFAC4E98),
      onTertiaryContainer: Color(0xFFFFFFFF),
      tertiaryFixed: Color(0xFFF4D0EE),
      tertiaryFixedDim: Color(0xFFD896C8),
      onTertiaryFixed: Color(0xFF2D0A26),
      onTertiaryFixedVariant: Color(0xFF491A40),
      error: Color(0xFF8C0009),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFCF2C27),
      onErrorContainer: Color(0xFFFFFFFF),
      surface: Color(0xFFFDF7FF),
      onSurface: Color(0xFF111025),
      onSurfaceVariant: Color(0xFF39344F),
      outline: Color(0xFF56516C),
      outlineVariant: Color(0xFF716C87),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF312C45),
      onInverseSurface: Color(0xFFF3EEFF),
      surfaceTint: Color(0xFF5B30D6),
      surfaceDim: Color(0xFFCBC5DC),
      surfaceBright: Color(0xFFFDF7FF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF7F1FF),
      surfaceContainer: Color(0xFFEBE5F9),
      surfaceContainerHigh: Color(0xFFDFD9EE),
      surfaceContainerHighest: Color(0xFFD4CEE2),
    );
  }

  ThemeData lightMediumContrast() => theme(lightMediumContrastScheme());

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF310D8C),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF4D22B0),
      onPrimaryContainer: Color(0xFFFFFFFF),
      primaryFixed: Color(0xFFE8DEFF),
      primaryFixedDim: Color(0xFFBEA6FF),
      onPrimaryFixed: Color(0xFF000000),
      onPrimaryFixedVariant: Color(0xFF200555),
      inversePrimary: Color(0xFFD4C1FF),
      secondary: Color(0xFF48208A),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF5E35A6),
      onSecondaryContainer: Color(0xFFFFFFFF),
      secondaryFixed: Color(0xFFEEDBFF),
      secondaryFixedDim: Color(0xFFD8BAFA),
      onSecondaryFixed: Color(0xFF000000),
      onSecondaryFixedVariant: Color(0xFF1D053E),
      tertiary: Color(0xFF641054),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF84306F),
      onTertiaryContainer: Color(0xFFFFFFFF),
      tertiaryFixed: Color(0xFFF4D0EE),
      tertiaryFixedDim: Color(0xFFD896C8),
      onTertiaryFixed: Color(0xFF000000),
      onTertiaryFixedVariant: Color(0xFF380A30),
      error: Color(0xFF6E0003),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFF98000A),
      onErrorContainer: Color(0xFFFFFFFF),
      surface: Color(0xFFFDF7FF),
      onSurface: Color(0xFF000000),
      onSurfaceVariant: Color(0xFF000000),
      outline: Color(0xFF2A2540),
      outlineVariant: Color(0xFF48435E),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF312C45),
      onInverseSurface: Color(0xFFFFFFFF),
      surfaceTint: Color(0xFF5B30D6),
      surfaceDim: Color(0xFFBAB4CB),
      surfaceBright: Color(0xFFFDF7FF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF4EEFF),
      surfaceContainer: Color(0xFFE5DFF3),
      surfaceContainerHigh: Color(0xFFD7D1E6),
      surfaceContainerHighest: Color(0xFFC9C3D8),
    );
  }

  ThemeData lightHighContrast() => theme(lightHighContrastScheme());

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7C4DFF),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF8A5EF0),
      onPrimaryContainer: Color(0xFF1A0040),
      primaryFixed: Color(0xFFE8DEFF),
      primaryFixedDim: Color(0xFFBEA6FF),
      onPrimaryFixed: Color(0xFF1A0040),
      onPrimaryFixedVariant: Color(0xFF3D1F7A),
      inversePrimary: Color(0xFF5A2FCC),
      secondary: Color(0xFFBB86FC),
      onSecondary: Color(0xFF1A0040),
      secondaryContainer: Color(0xFF2E1A4F),
      onSecondaryContainer: Color(0xFFDFBEFF),
      secondaryFixed: Color(0xFFEEDBFF),
      secondaryFixedDim: Color(0xFFD8BAFA),
      onSecondaryFixed: Color(0xFF1A0040),
      onSecondaryFixedVariant: Color(0xFF3C245A),
      tertiary: Color(0xFFD896C8),
      onTertiary: Color(0xFF2D0A26),
      tertiaryContainer: Color(0xFF3D1A38),
      onTertiaryContainer: Color(0xFFF4D0EE),
      tertiaryFixed: Color(0xFFF4D0EE),
      tertiaryFixedDim: Color(0xFFD896C8),
      onTertiaryFixed: Color(0xFF2D0A26),
      onTertiaryFixedVariant: Color(0xFF5C2A52),
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF3B0000),
      errorContainer: Color(0xFF6B1A1A),
      onErrorContainer: Color(0xFFFFB4AB),
      surface: Color(0xFF0E0A1A),
      onSurface: Color(0xFFEDE8FF),
      onSurfaceVariant: Color(0xFFABA3D1),
      outline: Color(0xFF5E5585),
      outlineVariant: Color(0xFF2E2850),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFEDE8FF),
      onInverseSurface: Color(0xFF1F1932),
      surfaceTint: Color(0xFF7C4DFF),
      surfaceDim: Color(0xFF0B0815),
      surfaceBright: Color(0xFF2E2A40),
      surfaceContainerLowest: Color(0xFF090613),
      surfaceContainerLow: Color(0xFF130F22),
      surfaceContainer: Color(0xFF181328),
      surfaceContainerHigh: Color(0xFF1F1932),
      surfaceContainerHighest: Color(0xFF27203C),
    );
  }

  ThemeData dark() => theme(darkScheme());

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFCBB6FF),
      onPrimary: Color(0xFF1F0060),
      primaryContainer: Color(0xFF9370F5),
      onPrimaryContainer: Color(0xFF000000),
      primaryFixed: Color(0xFFE8DEFF),
      primaryFixedDim: Color(0xFFBEA6FF),
      onPrimaryFixed: Color(0xFF0D0030),
      onPrimaryFixedVariant: Color(0xFF2D1060),
      inversePrimary: Color(0xFF4520B8),
      secondary: Color(0xFFE0CCFF),
      onSecondary: Color(0xFF1A0040),
      secondaryContainer: Color(0xFFA070D8),
      onSecondaryContainer: Color(0xFF000000),
      secondaryFixed: Color(0xFFEEDBFF),
      secondaryFixedDim: Color(0xFFD8BAFA),
      onSecondaryFixed: Color(0xFF0D0030),
      onSecondaryFixedVariant: Color(0xFF2C1250),
      tertiary: Color(0xFFEBCCE0),
      onTertiary: Color(0xFF1E0018),
      tertiaryContainer: Color(0xFFBD7AAD),
      onTertiaryContainer: Color(0xFF000000),
      tertiaryFixed: Color(0xFFF4D0EE),
      tertiaryFixedDim: Color(0xFFD896C8),
      onTertiaryFixed: Color(0xFF180012),
      onTertiaryFixedVariant: Color(0xFF481840),
      error: Color(0xFFFFD2CC),
      onError: Color(0xFF540003),
      errorContainer: Color(0xFFFF5449),
      onErrorContainer: Color(0xFF000000),
      surface: Color(0xFF0E0A1A),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFDFD8F8),
      outline: Color(0xFFB4ADCE),
      outlineVariant: Color(0xFF928BAC),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFEDE8FF),
      onInverseSurface: Color(0xFF1F1932),
      surfaceTint: Color(0xFF7C4DFF),
      surfaceDim: Color(0xFF0E0A1A),
      surfaceBright: Color(0xFF3A354E),
      surfaceContainerLowest: Color(0xFF07040F),
      surfaceContainerLow: Color(0xFF1B1729),
      surfaceContainer: Color(0xFF22203A),
      surfaceContainerHigh: Color(0xFF2D2844),
      surfaceContainerHighest: Color(0xFF38334F),
    );
  }

  ThemeData darkMediumContrast() => theme(darkMediumContrastScheme());

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF2ECFF),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFFCBB6FF),
      onPrimaryContainer: Color(0xFF0A0028),
      primaryFixed: Color(0xFFE8DEFF),
      primaryFixedDim: Color(0xFFBEA6FF),
      onPrimaryFixed: Color(0xFF000000),
      onPrimaryFixedVariant: Color(0xFF150048),
      inversePrimary: Color(0xFF3310A0),
      secondary: Color(0xFFF5EEFF),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFD5B8F8),
      onSecondaryContainer: Color(0xFF0A0028),
      secondaryFixed: Color(0xFFEEDBFF),
      secondaryFixedDim: Color(0xFFD8BAFA),
      onSecondaryFixed: Color(0xFF000000),
      onSecondaryFixedVariant: Color(0xFF140030),
      tertiary: Color(0xFFFFEEF8),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFFE8C0DA),
      onTertiaryContainer: Color(0xFF140010),
      tertiaryFixed: Color(0xFFF4D0EE),
      tertiaryFixedDim: Color(0xFFD896C8),
      onTertiaryFixed: Color(0xFF000000),
      onTertiaryFixedVariant: Color(0xFF280820),
      error: Color(0xFFFFECE9),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFFFFAEA4),
      onErrorContainer: Color(0xFF220001),
      surface: Color(0xFF0E0A1A),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFFFFFFF),
      outline: Color(0xFFF0EAF8),
      outlineVariant: Color(0xFFC4BDDA),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFEDE8FF),
      onInverseSurface: Color(0xFF000000),
      surfaceTint: Color(0xFF7C4DFF),
      surfaceDim: Color(0xFF0E0A1A),
      surfaceBright: Color(0xFF46415C),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF201D31),
      surfaceContainer: Color(0xFF312C45),
      surfaceContainerHigh: Color(0xFF3D3750),
      surfaceContainerHighest: Color(0xFF48435C),
    );
  }

  ThemeData darkHighContrast() => theme(darkHighContrastScheme());

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
