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
          displayName: (context) => .new(name: context.l10n.menu),
          shown: true,
        ),
        WidgetParameterEntry(
          descriptor: const BooleanWidgetParameter(id: "nextDayAfterMeal"),
          displayName: (context) => .new(/* TODO: Add values */),
          shown: true,
        ),
      ],
      computeValue: (context, params) {
        final today = DateTime.now().toDay(true);

        context.dayBlocks(today);

        return today;
      },
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
