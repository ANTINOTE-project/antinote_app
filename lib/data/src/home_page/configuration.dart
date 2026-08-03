import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/data/src/home_page/widget/configuration.dart';
import 'package:antinote_app/data/src/state.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

final class const HomePageConfiguration({
  required final String name,
  required final String uid,

  required final List<HomePageWidgetConfiguration> widgets,

  required final HomePageConfigurationCriterion? criterion,
  final bool exclusive = true,
}) {
  static const _uuidGenerator = UuidV4();

  new create({required String name})
    : this(
        name: name,
        uid: _uuidGenerator.generate(),
        widgets: [],
        criterion: null,
      );

  factory fromJson(Map<String, dynamic> json) => .new(
    name: json.get('name'),
    uid: json.get('id'),

    widgets: json.getLM('widgets').mapL((e) => .fromJson(e)),

    criterion: json.get('criterion') == null
        ? null
        : .fromJson(json.get('criterion')),
    exclusive: json.get<bool?>('exclusive') ?? true,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    // UUIDs shouldn't be stored as strings ideally, but since this is a very
    // low volume object, it's not that important.
    'id': uid,

    'widgets': widgets.mapL((e) => e.toJson()),

    'criterion': criterion?.toJson(),
    'exclusive': exclusive,
  };

  HomePageConfiguration copyWith({
    String? name,
    String? uid,
    List<HomePageWidgetConfiguration>? widgets,
    HomePageConfigurationCriterion? criterion,
  }) => HomePageConfiguration(
    name: name ?? this.name,
    uid: uid ?? this.uid,
    widgets: widgets ?? this.widgets,
    criterion: criterion ?? this.criterion,
  );
}

enum HomePageConfigurationCriterionType(final String id) {
  relative('rel'),
  operator('op'),
  not('not'),
  static('sta'),
  classRelative('cla')
}

sealed class const HomePageConfigurationCriterion() {
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache);
  FutureOr<bool> meetsRequirement(HomePageCache cache);

  Map<String, dynamic> toJson() => {'id': id.id, ..._jsonProperties()};

  factory fromJson(Map<String, dynamic> raw) {
    return switch (HomePageConfigurationCriterionType.values.firstWhere(
      (element) => element.id == raw.get('id'),
    )) {
      .relative => RelativeHomePageConfigurationCriterion.fromJson(raw),
      .operator => OperatorHomePageConfigurationCriterion.fromJson(raw),
      .not => NotOperatorHomePageConfigurationCriterion.fromJson(raw),
      .static => StaticHomePageConfigurationCriterion.fromJson(raw),
      .classRelative => ClassRelativeHomePageConfigurationCriterion.fromJson(
        raw,
      ),
    };
  }

  Map<String, dynamic> _jsonProperties();

  HomePageConfigurationCriterionType get id;
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
  HomePageConfigurationCriterionType get id => .relative;

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
    startMargin: Duration(milliseconds: raw.get('start_pos')),
    startAnchor: raw.get('start_anc'),
    state: .values.byName(raw.get('state')),
    endMargin: Duration(milliseconds: raw.get('end_pos')),
    endAnchor: raw.get('end_anc'),
  );

  @override
  Map<String, dynamic> _jsonProperties() => {
    'start_pos': startMargin.inMilliseconds,
    'start_anc': startAnchor,
    'state': state.name,
    'end_pos': endMargin.inMilliseconds,
    'end_anc': endAnchor,
  };

  @override
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache) {
    if (cache.hasDayBaseSchedules(cache.anchorDate)) return [];

    return [.schedules(cache.anchorDate)];
  }

  @override
  FutureOr<bool> meetsRequirement(HomePageCache cache) async {
    final appStates = cache.dayAppStates(cache.anchorDate);

    for (final appState in appStates) {
      if (appState.state != state) continue;

      final newRange = DateTimeRange(
        start: (startAnchor ? appState.range.end : appState.range.start)
            .subtract(startMargin),
        end: (startAnchor ? appState.range.end : appState.range.start).add(
          endMargin,
        ),
      );

      if (newRange.contains(cache.anchorTime)) {
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
  HomePageConfigurationCriterionType get id => .operator;

  const new({required this.a, required this.operation, required this.b});

  factory fromJson(Map<String, dynamic> raw) =>
      OperatorHomePageConfigurationCriterion(
        a: HomePageConfigurationCriterion.fromJson(raw.get('a')),
        operation: .values.byName(raw.get('op')),
        b: HomePageConfigurationCriterion.fromJson(raw.get('b')),
      );

  @override
  Map<String, dynamic> _jsonProperties() => {
    'a': a.toJson(),
    'op': operation.name,
    'b': b.toJson(),
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
  HomePageConfigurationCriterionType get id => .not;

  const new({required this.criterion});

  factory fromJson(Map<String, dynamic> raw) =>
      NotOperatorHomePageConfigurationCriterion(
        criterion: HomePageConfigurationCriterion.fromJson(raw.get('crit')),
      );

  @override
  Map<String, dynamic> _jsonProperties() => {'crit': criterion.toJson()};

  @override
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache) =>
      criterion.requestsUntilRequirements(cache);

  @override
  FutureOr<bool> meetsRequirement(HomePageCache cache) async =>
      !(await criterion.meetsRequirement(cache));
}

final class const StaticHomePageConfigurationCriterion({
  required final TimeRelation relation,
  required final DateTime start,
  required final DateTime end,
  required final AppState? mask,
}) extends HomePageConfigurationCriterion {
  this : assert(relation != .none, 'Relation cannot be none');

  @override
  HomePageConfigurationCriterionType get id => .static;

  factory fromJson(Map<String, dynamic> raw) =>
      StaticHomePageConfigurationCriterion(
        relation: .values.byName(raw.get('rel')),
        start: DateTime.fromMillisecondsSinceEpoch(
          raw.get('start'),
          isUtc: true,
        ),
        end: DateTime.fromMillisecondsSinceEpoch(raw.get('end'), isUtc: true),
        mask: raw.get<String?>('mask') == null
            ? null
            : .values.byName(raw.get<String>('mask')),
      );

  @override
  Map<String, dynamic> _jsonProperties() => {
    'start': start.millisecondsSinceEpoch,
    'end': end.millisecondsSinceEpoch,
    'rel': relation.name,
    'mask': mask?.name,
  };

  @override
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache) {
    if (cache.hasDayBaseSchedules(cache.anchorDate)) return [];

    return [.schedules(cache.anchorDate)];
  }

  @override
  FutureOr<bool> meetsRequirement(HomePageCache cache) {
    final states = cache.dayAppStates(cache.anchorDate);

    final curState = states.firstWhereOrNull(
      (element) => element.range.contains(cache.anchorTime),
    );
    if (mask != null && curState?.state != mask) return false;

    final localStart = start.copyWith(
      year: cache.anchorDate.year,
      month: cache.anchorDate.month,
      day: cache.anchorDate.day,
    );
    final localEnd = end.copyWith(
      year: cache.anchorDate.year,
      month: cache.anchorDate.month,
      day: cache.anchorDate.day,
    );

    return switch (relation) {
      TimeRelation.before => cache.anchorTime.isBefore(localStart),
      TimeRelation.after => cache.anchorTime.isAfter(localEnd),
      TimeRelation.during => true,
      TimeRelation.none => throw UnimplementedError(),
    };
  }
}

final class const ClassRelativeHomePageConfigurationCriterion({
  required final TimeRelation relation,
}) extends HomePageConfigurationCriterion {
  @override
  HomePageConfigurationCriterionType get id => .classRelative;

  factory fromJson(Map<String, dynamic> json) =>
      .new(relation: .values.byName(json.get('rel')));

  @override
  Map<String, dynamic> _jsonProperties() => {'rel': relation.name};

  @override
  List<HomePageRequest> requestsUntilRequirements(HomePageCache cache) {
    if (cache.hasDayBaseSchedules(cache.anchorDate)) return const [];

    return [.schedules(cache.anchorDate)];
  }

  @override
  FutureOr<bool> meetsRequirement(HomePageCache cache) {
    final states = cache.dayAppStates(cache.anchorDate);

    final curState = states.firstWhereOrNull(
      (element) => element.range.contains(cache.anchorTime),
    );
    if (curState == null) return false;

    return curState.classRelation == relation;
  }
}
