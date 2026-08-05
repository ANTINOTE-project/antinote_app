import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/data/src/home_page/widget/parameters.dart';
import 'package:antinote_app/ui/screens/home/widgets/menu.dart';
import 'package:antinote_app/ui/screens/home/widgets/timetable/day.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

part 'menu.dart';
part 'timetable/day.dart';

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

  WidgetArguments<A> createArguments(Map<dynamic, dynamic> args) =>
      WidgetArguments<A>(args: args.cast<A, dynamic>());

  /// [computeValue] won't be called until this is empty.
  List<HomePageRequest> requiredUntilCompute(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments args,
  );

  /// If return value is null, the whole widget won't be shown.
  ///
  /// [args] will contain as many entries as [arguments], values may be null
  /// when undefined.
  FutureOr<V?> computeValue(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments args,
  );

  /// This should only be redirecting to a widget in the front end, no fancy
  /// widget manipulation in the back end.
  Widget buildSliver(
    BuildContext context,
    HomePageWidgetState<V, A, P> state,
    V value,
  );
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

abstract class WidgetArgument<T>() implements Enum;

final class const WidgetArguments<T extends WidgetArgument>({
  required final Map<T, dynamic> _args,
}) {
  P get<P>(WidgetArgument<P> key) => _args[key] as P;
  void set<P>(WidgetArgument<P> key, P value) => _args[key as T] = value;
  bool has(T key) => _args.containsKey(key);

  WidgetArguments<T> mergeWith(WidgetArguments<WidgetArgument> arguments) =>
      WidgetArguments<T>(args: {..._args, ...(arguments._args as dynamic)});
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
    WidgetParameters<WidgetParameter> params,
  )
  requiredUntilCompute,

  /// If return value is null, the whole widget won't be shown.
  ///
  /// [params] will contain as many entries as [parameters], values may be null
  /// when undefined.
  required final FutureOr<V?> Function(
    RemoteSession session,
    HomePageCache cache,
    WidgetParameters<WidgetParameter> params,
  )
  computeValue,
}) {
  WidgetParameters<P> createParameters(Map<dynamic, dynamic> params) =>
      WidgetParameters<P>(params: params.cast<P, dynamic>());
}
