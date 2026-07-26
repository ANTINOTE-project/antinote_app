import "package:antinote_app/backend/src/home_page/configuration.dart";
import "package:antinote_app/backend/src/settings/category.dart";

class HomePageSettings extends SettingsCategory {
  @override
  String get name => "home_page";

  @override
  int get latestVersion => 1;

  @override
  Map<int, SettingsUpgradeTask> get upgradeTasks => const {};

  @override
  List<dynamic> get registeredFields => [];

  HomePageConfiguration get baseConfiguration => get("base");
}
