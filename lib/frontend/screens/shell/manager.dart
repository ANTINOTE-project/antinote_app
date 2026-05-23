import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/models/communication_filter.dart";
import "package:flutter/material.dart";

typedef DateRange = DateTimeRange<DateTime>;

typedef SetScreenId = void Function(String? newScreenId);
typedef SetListenedStorage = void Function(Map<String, dynamic> newListenedStorage);

class ScreenManager extends InheritedModel<String> {
  final Map<String, dynamic> listenedStorage;
  final Map<String, dynamic> storage;
  final String? screenId;

  final SetListenedStorage _setListenedStorage;
  final SetScreenId _setScreenId;

  const ScreenManager({
    super.key,

    required this.listenedStorage,
    required this.storage,
    required this.screenId,

    required this._setListenedStorage,
    required this._setScreenId,

    required super.child,
  });

  // --- Public static methods --

  static ScreenManager of(BuildContext context) {
    final ScreenManager? result = context.dependOnInheritedWidgetOfExactType<ScreenManager>();
    assert(result != null, "No ScreenManager found in context");

    return result!;
  }

  static Period getOrPutAndListenPeriod(BuildContext context, PronoteSession session) {
    return _getOrPutAndListenValue<String, Period>(
      context: context,
      key: "period",
      defaultValue: () => session.instance.defaultPeriod(DateTime.now()),
      toRaw: (value) => value.visualId,
      toValue: (raw) => session.getCachedValue(.PERIOD, raw),
    );
  }

  static void updatePeriod(BuildContext context, Period value) {
    _updateValue(context: context, key: "period", value: value, toRaw: (value) => value.visualId);
  }

  static String getOrPutAndListenReportTarget(BuildContext context) {
    return _getOrPutAndListenRaw(context: context, key: "report_target", defaultValue: () => "self");
  }

  static void updateReportTarget(BuildContext context, String value) {
    _updateRaw(context: context, key: "report_target", value: value);
  }

  static CommunicationFilter getOrPutAndListenCommunicationFilter(BuildContext context) {
    return _getOrPutAndListenRaw(
      context: context,
      key: "communication_filter",
      defaultValue: () => CommunicationFilter.defaultFilter,
    );
  }

  static void updateCommunicationFilter(BuildContext context, CommunicationFilter value) {
    _updateRaw(context: context, key: "communication_filter", value: value);
  }

  static Map<String, dynamic>? queryLoadState(BuildContext context, String showId) {
    final result = context.dependOnInheritedWidgetOfExactType<ScreenManager>();
    assert(result != null, "No ScreenManager found in context");

    return result!.getLoadState(showId);
  }

  static void updateLoadState(BuildContext context, String showId, Map<String, dynamic> newLoadState) {
    final result = context.dependOnInheritedWidgetOfExactType<ScreenManager>();
    assert(result != null, "No ScreenManager found in context");

    result!.setLoadState(showId, newLoadState);
  }

  static Map<String, dynamic> getRaw(BuildContext context, Set<String> keys) {
    final result = context.dependOnInheritedWidgetOfExactType<ScreenManager>();
    assert(result != null, "No ScreenManager found in context");

    return result!.queryValues(keys);
  }

  // --- Public instance methods ---

  void updateCurrentScreenId() {
    final String? newScreenId = switch (storage.get<String>("main_category")) {
      "home" => "home",
      "timetable" => _buildTimetableScreenId(),
      "grades" => _buildGradesScreenId(),
      "communication" => "info_and_discussions",
      _ => throw UnimplementedError(),
    };

    if (newScreenId != screenId) {
      _setScreenId(newScreenId);
    }
  }

  T getOrPutAndListen<R, T>({
    required String key,
    required T Function() defaultValue,
    required R Function(T value) toRaw,
    required T Function(R raw) toValue,
  }) {
    if (listenedStorage.containsKey(key)) {
      return toValue(listenedStorage.get(key));
    }

    final newValue = defaultValue();

    _setListenedStorage(deepMergeMaps({key: toRaw(newValue)}, listenedStorage));

    return newValue;
  }

  void update<R, T>({required String key, required T value, required R Function(T value) toRaw}) {
    _setListenedStorage(deepMergeMaps({key: toRaw(value)}, listenedStorage));
  }

  Map<String, dynamic> queryValues(Set<String> keys) {
    return {for (final key in keys) key: listenedStorage.get(key)};
  }

  Map<String, dynamic>? getLoadState(String showId) {
    return storage.mGetM(showId);
  }

  void setLoadState(String showId, Map<String, dynamic> newLoadState) {
    storage[showId] = newLoadState;
  }

  // --- Overrides ---

  @override
  bool updateShouldNotify(ScreenManager old) {
    return old.screenId != screenId || old.listenedStorage != listenedStorage;
  }

  @override
  bool updateShouldNotifyDependent(covariant ScreenManager oldWidget, Set<String> dependencies) {
    for (final toCheck in dependencies) {
      if (oldWidget.listenedStorage[toCheck] != listenedStorage[toCheck]) {
        return true;
      }
    }

    return false;
  }

  // --- Private static helpers ---

  static void _updateRaw<T>({required BuildContext context, required String key, required T value}) {
    _updateValue<T, T>(context: context, key: key, value: value, toRaw: (value) => value);
  }

  static void _updateValue<R, T>({
    required BuildContext context,
    required String key,
    required T value,
    required R Function(T value) toRaw,
  }) {
    context
        .dependOnInheritedWidgetOfExactType<ScreenManager>(aspect: key)!
        .update(key: key, value: value, toRaw: toRaw);
  }

  static T _getOrPutAndListenValue<R, T>({
    required BuildContext context,
    required String key,
    required T Function() defaultValue,
    required R Function(T value) toRaw,
    required T Function(R raw) toValue,
  }) {
    return context
        .dependOnInheritedWidgetOfExactType<ScreenManager>(aspect: key)!
        .getOrPutAndListen<R, T>(key: key, defaultValue: defaultValue, toRaw: toRaw, toValue: toValue);
  }

  static T _getOrPutAndListenRaw<T>({
    required BuildContext context,
    required String key,
    required T Function() defaultValue,
  }) => _getOrPutAndListenValue<T, T>(
    context: context,
    key: key,
    defaultValue: defaultValue,
    toRaw: (value) => value,
    toValue: (raw) => raw,
  );

  // --- Private instance helpers ---

  String? _buildTimetableScreenId() {
    final range = storage.get<DateRange?>("timetable");
    if (range == null) return null;

    return "timetable-${range.start.millisecondsSinceEpoch}-${range.end.millisecondsSinceEpoch}";
  }

  String _buildGradesScreenId() {
    return switch (storage.get<String?>("grades_category")) {
      "exams" => "exams",
      "report" => "report",
      _ => "exams",
    };
  }
}
