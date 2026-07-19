import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/home_page/schedule.dart";
import "package:antinote_app/backend/src/home_page/widget/parameters.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:flutter/widgets.dart";

part "menu.dart";

typedef WidgetUpgradeTask = FutureOr<void> Function(Map<String, dynamic> prev);

final class WidgetParameterEntryDisplayData({
  String? name,
  String? description,
});

sealed class WidgetDescriptor<E extends WidgetParameter> {
  abstract final String id;
  abstract final int version;
  abstract final Map<int, WidgetUpgradeTask> upgradeTasks;

  abstract final List<WidgetArgumentEntry<dynamic, E>> parameters;
}

final class WidgetParameterEntry {
  final WidgetParameterDescriptor descriptor;
  final WidgetParameterEntryDisplayData Function(BuildContext context)
  displayName;
  final bool shown;

  const new({
    required this.descriptor,
    required this.displayName,
    required this.shown,
  });
}

final class WidgetArgumentEntry<V, E extends WidgetParameter> {
  final List<WidgetParameterEntry> parameters;

  /// If return value is null, the whole widget won't be shown.
  ///
  /// [params] will contain as many entries as [parameters], values may be null
  /// when undefined.
  final FutureOr<V?> Function(
    HomePageContext context,
    Map<String, dynamic> params,
  )
  computeValue;

  const new({required this.parameters, required this.computeValue});
}
