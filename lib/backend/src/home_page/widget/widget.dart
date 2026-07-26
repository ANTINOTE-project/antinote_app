import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/home_page/loader.dart";
import "package:antinote_app/backend/src/home_page/widget/parameters.dart";
import "package:flutter/widgets.dart";

part "menu.dart";

typedef WidgetUpgradeTask = FutureOr<void> Function(Map<String, dynamic> prev);

final class WidgetParameterEntryDisplayData({
  String? name,
  String? description,
});

@immutable
sealed class const WidgetDescriptor<
  V,
  A extends WidgetArgument,
  P extends WidgetParameter
>() {
  abstract final String id;
  abstract final int version;
  abstract final Map<int, WidgetUpgradeTask> upgradeTasks;

  abstract final List<WidgetArgumentEntry<dynamic, A, P>> arguments;

  /// [computeValue] won't be called until this is empty.
  List<HomePageRequest> requiredUntilCompute(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments<A> args,
  );

  /// If return value is null, the whole widget won't be shown.
  ///
  /// [args] will contain as many entries as [arguments], values may be null
  /// when undefined.
  FutureOr<V?> computeValue(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments<A> args,
  );

  /// This should only be redirecting to a widget in the front end, no fancy
  /// widget manipulation in the back end.
  Widget build(BuildContext context, V value);
}

final class WidgetParameterEntry<E extends WidgetParameter> {
  final WidgetParameterDescriptor<E, dynamic, dynamic> descriptor;
  final WidgetParameterEntryDisplayData Function(BuildContext context)
  displayData;
  final bool shown;

  const new({
    required this.descriptor,
    required this.displayData,
    required this.shown,
  });
}

abstract class WidgetArgument<T>() extends Enum;

final class const WidgetArguments<T extends WidgetArgument>({
  required final Map<T, dynamic> _args,
}) {
  P get<P>(WidgetArgument<P> key) => _args[key] as P;
}

final class const WidgetArgumentEntry<
  V,
  A extends WidgetArgument,
  P extends WidgetParameter
>({
  required final A id,

  required final List<WidgetParameterEntry<P>> parameters,

  /// [computeValue] won't be called until this is empty.
  required final List<HomePageRequest> Function(
    RemoteSession session,
    HomePageCache cache,
  )
  requiredUntilCompute,

  /// If return value is null, the whole widget won't be shown.
  ///
  /// [params] will contain as many entries as [parameters], values may be null
  /// when undefined.
  required final FutureOr<V?> Function(
    RemoteSession session,
    HomePageCache cache,
    WidgetParameters<P> params,
  )
  computeValue,
});
