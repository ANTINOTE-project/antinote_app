import "dart:async";

import "package:antinote_app/main.dart";
import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

typedef SettingsUpgradeTask = FutureOr<void> Function(
  SharedPreferencesWithCache prefs,
);

enum _SettingsMode { none, registering, filling }

abstract class SettingsCategory extends ChangeNotifier {
  String get name;
  int get latestVersion;

  /// To upgrade to version `n` from version `n-1`, add the following :
  /// ```dart
  /// {
  ///   n: upgradeToN
  /// }
  /// ```
  Map<int, SettingsUpgradeTask> get upgradeTasks;

  late final SharedPreferencesWithCache _prefs;

  final Map<String, dynamic> _registered = {};
  Set<String> get fieldNames => _registered.keys.toSet();
  final Set<String> allFieldNames = {};
  _SettingsMode _mode = .none;

  /// Use this to get any keys you define in the category.
  ///
  /// Note : You can be sure the result will be non-nullable by providing a
  /// [writtenDefault]. Else, DO NOT do a null-check on the value received.
  T? get<T>(String key, {T? writtenDefault}) {
    if (_mode == .registering) {
      assert(!_registered.containsKey(key), "Registered same field twice.");
      _registered[key] = writtenDefault;

      return writtenDefault;
    }

    return _prefs.get(key) as T?;
  }

  Future<void> set(String key, dynamic value) async {
    await switch (value) {
      int _ => _prefs.setInt(key, value),
      double _ => _prefs.setDouble(key, value),
      bool _ => _prefs.setBool(key, value),
      String _ => _prefs.setString(key, value),
      List<String> _ => _prefs.setStringList(key, value),
      _ => throw UnimplementedError(),
    };

    if (_mode != .filling) notifyListeners();
  }

  bool has(String key) {
    if (_mode == .registering) {
      assert(!_registered.containsKey(key), "Registered same field twice.");
      _registered[key] = null;
      return false;
    }

    return _prefs.containsKey(key);
  }

  List<dynamic> get registeredFields;
  List<SettingsCategory> get registeredChildren => [];

  Completer<bool>? initializationState;
  Future<bool> initialize() async {
    if (initializationState != null) return initializationState!.future;

    initializationState = Completer();

    talker.info("Registering $name...");

    try {
      _mode = .registering;
      registeredFields;
      _mode = .none;
    } catch (e, st) {
      debugPrint(
        "Error while initializing $name settings (registering "
        "fields)",
      );
      debugPrintStack(stackTrace: st, label: e.toString());

      initializationState!.complete(false);
      return false;
    }

    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: .new(allowList: fieldNames),
      cache: .fromEntries(
        _registered.entries.where((element) => element.value != null),
      ),
    );

    allFieldNames.addAll(fieldNames);

    _mode = .filling;
    for (final MapEntry(key: fieldName, value: defaultValue)
        in _registered.entries) {
      if (defaultValue == null) continue;

      if (!_prefs.containsKey(fieldName)) {
        await set(fieldName, defaultValue);
      }
    }
    _mode = .none;

    if (_registered.containsKey(_versionFieldName)) {
      await _ensureLatest();
    }

    for (final child in registeredChildren) {
      if (!(await child.initialize())) continue;

      for (final fieldName in child.allFieldNames) {
        assert(
          !allFieldNames.contains(fieldName),
          "Registered same field twice "
          "(from a child settings category).",
        );
      }

      child.addListener(notifyListeners);
    }

    notifyListeners();

    initializationState!.complete(true);
    return true;
  }

  Future<void> _ensureLatest() async {
    while (version < latestVersion) {
      final newVersion = version + 1;

      try {
        upgradeTasks[newVersion]!(_prefs);
      } catch (e, st) {
        debugPrint(
          "Error while trying to update settings to version $newVersion in "
          "$name settings",
        );
        debugPrintStack(stackTrace: st, label: e.toString());

        if (!kDebugMode) {
          await clear();
          break;
        }
      }

      await _prefs.setInt(_versionFieldName, newVersion);
    }

    notifyListeners();
  }

  Future<void> clear() async {
    _prefs.clear();

    _mode = .filling;
    for (final MapEntry(key: fieldName, value: defaultValue)
        in _registered.entries) {
      if (defaultValue == null) continue;
      await set(fieldName, defaultValue);
    }
    _mode = .none;

    notifyListeners();
  }

  @override
  void dispose() {
    if (initializationState?.isCompleted ?? false) {
      for (final child in registeredChildren) {
        child.removeListener(notifyListeners);
        child.dispose();
      }
    }

    super.dispose();
  }

  String get _versionFieldName => "${name}_version";
  int get version => get(_versionFieldName, writtenDefault: latestVersion)!;
}
