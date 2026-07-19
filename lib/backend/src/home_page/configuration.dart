import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/home_page/schedule.dart";
import "package:antinote_app/backend/src/state.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:flutter/material.dart";
import "package:uuid/v4.dart";

final class HomePageConfiguration {
  final String name;
  final String uid;

  final HomePageConfigurationCriterion criterion;

  final List<String> priorityWidgetIds;

  const new({
    required this.name,
    required this.uid,
    required this.priorityWidgetIds,
    required this.criterion,
  });

  static const _uuidGenerator = UuidV4();

  new create({required this.name})
    : uid = _uuidGenerator.generate(),
      priorityWidgetIds = [],
      criterion = const RelativeHomePageConfigurationCriterion(
        margin: .zero,
        state: .defaultState,
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": uid,
    "priority": priorityWidgetIds,
    "criterion": criterion.toJson(),
  };
}

sealed class HomePageConfigurationCriterion {
  FutureOr<bool> meetsRequirement(HomePageContext context);

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

  const new();
}

final class RelativeHomePageConfigurationCriterion
    extends HomePageConfigurationCriterion {
  final Duration startPosition;

  /// [false] is the start of the state. [true] is the end.
  final bool startAnchor;

  final AppState state;

  final Duration endPosition;

  /// [false] is the start of the state. [true] is the end.
  final bool endAnchor;

  @override
  String get id => "relative";

  const new startSame({required Duration margin, required this.state})
    : startPosition = margin,
      endPosition = margin,
      startAnchor = false,
      endAnchor = false;

  const new endSame({required Duration margin, required this.state})
    : startPosition = margin,
      endPosition = margin,
      startAnchor = true,
      endAnchor = true;

  const new custom({
    required this.startPosition,
    required this.startAnchor,
    required this.state,
    required this.endPosition,
    required this.endAnchor,
  });

  const new({required Duration margin, required this.state})
    : startPosition = margin,
      endPosition = margin,
      startAnchor = false,
      endAnchor = true;

  factory fromJson(Map<String, dynamic> raw) => .custom(
    startPosition: raw.get("start_pos"),
    startAnchor: raw.get("start_anc"),
    state: AppState.values.byName(raw.get("state")),
    endPosition: raw.get("end_pos"),
    endAnchor: raw.get("end_anc"),
  );

  @override
  Map<String, dynamic> _jsonProperties() => {
    "start_pos": startPosition,
    "start_anc": startAnchor,
    "state": state.name,
    "end_pos": endPosition,
    "end_anc": endAnchor,
  };

  @override
  FutureOr<bool> meetsRequirement(HomePageContext context) async {
    final time = DateTime.now().copyWith(isUtc: true);
    final day = time.toDay();
    final appStates = await context.dayAppStates(day);

    for (final appState in appStates) {
      if (appState.state != state) continue;

      final newRange = DateTimeRange(
        start: (startAnchor ? appState.range.end : appState.range.start)
            .subtract(startPosition),
        end: (startAnchor ? appState.range.end : appState.range.start).add(
          endPosition,
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
  FutureOr<bool> meetsRequirement(
    HomePageContext context,
  ) async => switch (operation) {
    .and =>
      await a.meetsRequirement(context) && await b.meetsRequirement(context),
    .or =>
      await a.meetsRequirement(context) || await b.meetsRequirement(context),
    .xor =>
      await a.meetsRequirement(context) ^ await b.meetsRequirement(context),
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
  FutureOr<bool> meetsRequirement(HomePageContext context) async =>
      !(await criterion.meetsRequirement(context));
}
