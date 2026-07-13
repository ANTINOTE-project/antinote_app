import "package:antinote_app/backend/src/settings/category.dart";

class HomePageSettings extends SettingsCategory {
  @override
  int get latestVersion => 1;

  @override
  String get name => "home_page";

  @override
  List<dynamic> get registeredFields => [];

  @override
  Map<int, SettingsUpgradeTask> get upgradeTasks => const {};
}
