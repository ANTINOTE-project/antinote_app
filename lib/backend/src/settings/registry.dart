import 'package:antinote_app/backend/src/settings/category.dart';
import 'package:antinote_app/backend/src/settings/home_page.dart';
import 'package:antinote_app/backend/src/settings/networking.dart';
import 'package:antinote_app/backend/src/settings/theme.dart';
import 'package:flutter/material.dart';

class SettingsScope extends InheritedWidget {
  const SettingsScope({
    super.key,
    required this.registry,
    required super.child,
  });

  final SettingsRegistry registry;

  static SettingsScope of(BuildContext context) {
    final SettingsScope? result = context
        .dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(result != null, 'No SettingsScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SettingsScope old) => old.registry != registry;
}

/// Base settings category where all other settings categories should register.
class SettingsRegistry extends SettingsCategory {
  @override
  String get name => 'base';

  @override
  int get latestVersion => 1;
  @override
  Map<int, SettingsUpgradeTask> get upgradeTasks => {};

  @override
  List<dynamic> get registeredFields => [version];
  @override
  List<SettingsCategory> get registeredChildren => [
    theme,
    networking,
    homePage,
  ];

  final theme = ThemeSettings();
  final networking = NetworkingSettings();
  final homePage = HomePageSettings();
}
