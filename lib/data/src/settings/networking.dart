import 'dart:convert';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/settings/category.dart';

class NetworkingSettings extends SettingsCategory {
  @override
  String get name => 'networking';

  @override
  int get latestVersion => 1;

  @override
  Map<int, SettingsUpgradeTask> get upgradeTasks => {};

  @override
  List<dynamic> get registeredFields => [version, sessionOptions];

  SessionOptions get sessionOptions {
    if (has('session_options')) {
      return SessionOptions.fromBuffer(
        base64Decode(get<String>('session_options')!),
      )..freeze();
    }

    return SessionOptions.getDefault();
  }

  Future<void> setSessionOptions(SessionOptions value) =>
      set('session_options', base64Encode(value.writeToBuffer()));
}
