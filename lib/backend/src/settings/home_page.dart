import 'dart:async';
import 'dart:convert';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/backend/src/home_page/configuration.dart';
import 'package:antinote_app/backend/src/home_page/widget/configuration.dart';
import 'package:antinote_app/backend/src/settings/category.dart';
import 'package:antinote_app/l10n/app_localizations.dart';

class HomePageSettings extends SettingsCategory {
  @override
  String get name => 'home_page';

  @override
  int get latestVersion => 1;

  @override
  Map<int, SettingsUpgradeTask> get upgradeTasks => const {};

  @override
  List<dynamic> get registeredFields => [
    // This is linked to [getBaseConfiguration]/[setBaseConfiguration] but we
    // don't call the method as it has extra logic that makes its default value
    // invalid (we do not have localization data).
    get<String>('base_config'),
    // Same deal.
    get<String>('conditional_configs'),
  ];

  FutureOr<HomePageConfiguration> getBaseConfiguration(
    AppLocalizations l10n,
  ) async {
    final existing = get<String>('base_config');
    if (existing != null) return .fromJson(jsonDecode(existing));

    final created = HomePageConfiguration.create(name: l10n.defaultConfig);
    for (final descriptor in defaultDescriptors) {
      created.widgets.add(.new(descriptor: descriptor, rawParameters: {}));
    }

    await set('base_config', jsonEncode(created.toJson()));

    return created;
  }

  Future<void> setBaseConfiguration(HomePageConfiguration newValue) =>
      set('base_config', jsonEncode(newValue.toJson()));

  FutureOr<List<HomePageConfiguration>> getConditionalConfigurations(
    AppLocalizations l10n,
  ) async {
    final existing = get<List<String>>('conditional_configs');
    if (existing != null) return existing.mapL((e) => .fromJson(jsonDecode(e)));

    final created = createDefaultConfigurations(l10n);

    await set(
      'conditional_configs',
      created.mapL<String>((e) => jsonEncode(e.toJson())),
    );

    return created;
  }

  Future<void> setConditionalConfigurations(
    List<HomePageConfiguration> newValues,
  ) =>
      set('conditional_configs', newValues.mapL((e) => jsonEncode(e.toJson())));
}
