part of 'widget.dart';

enum MenuParameter<T>(@override final String code)
    implements WidgetParameter<T> {
  decayAfterMeal<bool>('decay_after_meal');
}

enum MenuArgument<T>() implements WidgetArgument<T> {
  day<Date>();
}

final class const MenuWidget()
    extends WidgetDescriptor<Menu, MenuArgument, MenuParameter> {
  @override
  String get id => 'menu';

  @override
  get arguments => [
    WidgetArgumentEntry(
      id: .day,

      parameters: [
        WidgetParameterEntry(
          descriptor: const BooleanWidgetParameter(
            id: MenuParameter.decayAfterMeal,
          ),
          displayData: (context) => .new(/* TODO: Add values */),
          shown: true,
        ),
      ],
      requiredUntilCompute: (session, cache, params) => [],
      computeValue: (session, cache, params) {
        final baseTime = DateTime.now().copyWith(isUtc: true);
        Date base = baseTime.toDay();

        if (params.get(MenuParameter.decayAfterMeal)) {
          final mealEnd = session.instance.timeForSlot(
            session.instance.endings[session.instance.lunchEndSlot],
            base,
          );

          if (!mealEnd.isAfter(baseTime)) base.add(const .new(days: 1));
        }

        while (true) {
          if (!session.instance.lastDate.isAfter(base)) {
            return null;
          }

          final businessDay = session.instance.isBusinessDay(base);
          final lunchDay = session.instance.lunchDays.contains(base.weekday);

          if (businessDay && lunchDay) {
            break;
          }

          base = base.add(const .new(days: 1)).toDay();
        }

        return base;
      },
    ),
  ];

  @override
  Map<int, WidgetUpgradeTask> get upgradeTasks => {};

  @override
  int get version => 1;

  @override
  List<HomePageRequest> requiredUntilCompute(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments<MenuArgument<dynamic>> args,
  ) {
    final day = args.get(MenuArgument.day);
    if (cache.hasMenuForDay(day)) return [];

    return [.menu(day)];
  }

  @override
  FutureOr<Menu?> computeValue(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments<MenuArgument<dynamic>> args,
  ) {
    return cache.dayMenu(args.get(MenuArgument.day));
  }

  @override
  Widget buildSliver(BuildContext context, Menu value) =>
      MenuWidgetSliver(value: value);
}
