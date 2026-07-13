part of "widget.dart";

enum MenuParameter<T> implements WidgetParameter<T> { dayDelta<Duration>() }

final class Menu extends WidgetDescriptor<MenuParameter> {
  @override
  String get id => "menu";

  @override
  List<WidgetArgumentEntry<dynamic, MenuParameter>> get parameters => [
    WidgetArgumentEntry(
      parameters: [
        WidgetParameterEntry(
          descriptor: const DurationWidgetParameter(id: "dayDelta"),
          displayName: (context) => context.l10n.menu,
          shown: true,
        ),
      ],
      computeValue: () {},
    ),
  ];

  @override
  Map<int, WidgetUpgradeTask> get upgradeTasks => {};

  @override
  int get version => 1;
}

// final menu = WidgetDescriptor<MenuParameters>(
//
// );
