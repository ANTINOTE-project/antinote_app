import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/home_page/loader.dart";
import "package:antinote_app/backend/src/state.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:flutter/material.dart";
import "package:uuid/v4.dart";

final class const HomePageConfiguration({
  required final String name,
  required final String uid,

  required final HomePageConfigurationCriterion criterion,

  required final List<String> priorityWidgetIds,
}) {
  static const _uuidGenerator = UuidV4();

  new create({required String name})
    : this(
        name: name,
        uid: _uuidGenerator.generate(),
        priorityWidgetIds: const [],
        criterion: const RelativeHomePageConfigurationCriterion(
          margin: .zero,
          state: .defaultState,
        ),
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    // UUIDs shouldn't be stored as strings ideally, but since this is a very
    // low volume object, it's not that important.
    "id": uid,
    "priority": priorityWidgetIds,
    "criterion": criterion.toJson(),
  };
}

sealed class const HomePageConfigurationCriterion() {
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache);
  FutureOr<bool> meetsRequirement(HomePageCache cache);

  Map<String, dynamic> toJson() => {"id": id, ..._jsonProperties()};

  factory fromJson(Map<String, dynamic> raw) {
    return switch (raw.get("id")) {
      "relative" => RelativeHomePageConfigurationCriterion.fromJson(raw),
      "op" => OperatorHomePageConfigurationCriterion.fromJson(raw),
      "not" => NotOperatorHomePageConfigurationCriterion.fromJson(raw),
      _ => throw UnimplementedError(),
    };
  }

  Map<String, dynamic> _jsonProperties();

  String get id;
}

final class RelativeHomePageConfigurationCriterion
    extends HomePageConfigurationCriterion {
  final Duration startMargin;

  /// [false] is the start of the state. [true] is the end.
  final bool startAnchor;

  final AppState state;

  final Duration endMargin;

  /// [false] is the start of the state. [true] is the end.
  final bool endAnchor;

  @override
  String get id => "relative";

  const new startSame({required Duration margin, required this.state})
    : startMargin = margin,
      endMargin = margin,
      startAnchor = false,
      endAnchor = false;

  const new endSame({required Duration margin, required this.state})
    : startMargin = margin,
      endMargin = margin,
      startAnchor = true,
      endAnchor = true;

  const new custom({
    required this.startMargin,
    required this.startAnchor,
    required this.state,
    required this.endMargin,
    required this.endAnchor,
  });

  const new({required Duration margin, required this.state})
    : startMargin = margin,
      endMargin = margin,
      startAnchor = false,
      endAnchor = true;

  factory fromJson(Map<String, dynamic> raw) => .custom(
    startMargin: raw.get("start_pos"),
    startAnchor: raw.get("start_anc"),
    state: AppState.values.byName(raw.get("state")),
    endMargin: raw.get("end_pos"),
    endAnchor: raw.get("end_anc"),
  );

  @override
  Map<String, dynamic> _jsonProperties() => {
    "start_pos": startMargin,
    "start_anc": startAnchor,
    "state": state.name,
    "end_pos": endMargin,
    "end_anc": endAnchor,
  };

  @override
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache) {
    final today = DateTime.now().toDay(true);

    if (cache.hasDayBaseSchedules(today)) return [];

    return [HomePageRequest.schedules(today)];
  }

  @override
  FutureOr<bool> meetsRequirement(HomePageCache cache) async {
    final time = DateTime.now().copyWith(isUtc: true);
    final day = time.toDay();
    final appStates = cache.dayAppStates(day);

    for (final appState in appStates) {
      if (appState.state != state) continue;

      final newRange = DateTimeRange(
        start: (startAnchor ? appState.range.end : appState.range.start)
            .subtract(startMargin),
        end: (startAnchor ? appState.range.end : appState.range.start).add(
          endMargin,
        ),
      );

      if (newRange.contains(time)) {
        return true;
      }
    }

    return false;
  }
}

enum HomePageConfigurationCriterionOperation { and, or, xor }

final class OperatorHomePageConfigurationCriterion
    extends HomePageConfigurationCriterion {
  final HomePageConfigurationCriterion a;
  final HomePageConfigurationCriterionOperation operation;
  final HomePageConfigurationCriterion b;

  @override
  String get id => "op";

  const new({required this.a, required this.operation, required this.b});

  factory fromJson(Map<String, dynamic> raw) =>
      OperatorHomePageConfigurationCriterion(
        a: HomePageConfigurationCriterion.fromJson(raw.get("a")),
        operation: .values.byName(raw.get("op")),
        b: HomePageConfigurationCriterion.fromJson(raw.get("b")),
      );

  @override
  Map<String, dynamic> _jsonProperties() => {
    "a": a.toJson(),
    "op": operation.name,
    "b": b.toJson(),
  };

  @override
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache) =>
      a.requestsUntilRequirements(cache) + b.requestsUntilRequirements(cache);

  @override
  FutureOr<bool> meetsRequirement(
    HomePageCache cache,
  ) async => switch (operation) {
    .and => await a.meetsRequirement(cache) && await b.meetsRequirement(cache),
    .or => await a.meetsRequirement(cache) || await b.meetsRequirement(cache),
    .xor => await a.meetsRequirement(cache) ^ await b.meetsRequirement(cache),
  };
}

final class NotOperatorHomePageConfigurationCriterion
    extends HomePageConfigurationCriterion {
  final HomePageConfigurationCriterion criterion;

  @override
  String get id => "not";

  const new({required this.criterion});

  factory fromJson(Map<String, dynamic> raw) =>
      NotOperatorHomePageConfigurationCriterion(
        criterion: HomePageConfigurationCriterion.fromJson(raw.get("crit")),
      );

  @override
  Map<String, dynamic> _jsonProperties() => {"crit": criterion.toJson()};

  @override
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache) =>
      criterion.requestsUntilRequirements(cache);

  @override
  FutureOr<bool> meetsRequirement(HomePageCache cache) async =>
      !(await criterion.meetsRequirement(cache));
}
