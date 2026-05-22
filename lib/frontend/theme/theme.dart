import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/theme/app.dart";
import "package:flutter/material.dart";

ThemeData buildTheme() => ThemeData(
  fontFamily: App.fontFamily,
  useMaterial3: true,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    primary: AppTheme.primary,
    onPrimary: AppTheme.onPrimary,
    primaryContainer: AppTheme.primaryContainer,
    onPrimaryContainer: AppTheme.onPrimaryContainer,

    secondary: AppTheme.secondary,
    onSecondary: AppTheme.onSecondary,
    secondaryContainer: AppTheme.secondaryContainer,
    onSecondaryContainer: AppTheme.onSecondaryContainer,

    surface: AppTheme.surface,
    onSurface: AppTheme.onSurface,
    surfaceContainerLow: AppTheme.surfaceContainerLow,
    surfaceContainer: AppTheme.surfaceContainer,
    surfaceContainerHigh: AppTheme.surfaceContainerHigh,
    onSurfaceVariant: AppTheme.onSurfaceVariant,

    error: AppTheme.error,
    onError: AppTheme.onError,
    errorContainer: AppTheme.errorContainer,
    onErrorContainer: AppTheme.onErrorContainer,

    outline: AppTheme.outline,
    outlineVariant: AppTheme.outlineVariant,

    shadow: AppTheme.shadow,
    scrim: AppTheme.scrim,

    inverseSurface: AppTheme.inverseSurface,
    onInverseSurface: AppTheme.onInverseSurface,
    inversePrimary: AppTheme.inversePrimary,
  ),

  iconTheme: const IconThemeData(color: AppTheme.onSurface),

  textTheme: Typography.material2021().white.apply(
    bodyColor: AppTheme.onSurface,
    displayColor: AppTheme.onSurface,
  ),
);
