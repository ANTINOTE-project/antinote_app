part of '../widget.dart';

enum TimetableDayParameter<T>(@override final String code)
    implements WidgetParameter<T> {
  decayAfterClass<bool>('decay_after_class'),
  onlyOnBusinessDays<bool>('only_business_days'),
  defaultDelta<Duration>('default_delta');
}

enum TimetableDayArgument<T>() implements WidgetArgument<T> {
  day<Date>()
}

final class const TimetableDayWidget()
    extends
        WidgetDescriptor<
          DayBlocks,
          TimetableDayArgument,
          TimetableDayParameter
        > {
  @override
  String get id => 'timetable_day';

  @override
  get arguments => [
    WidgetArgumentEntry<Date, TimetableDayArgument, TimetableDayParameter>(
      id: .day,
      parameters: [
        WidgetParameterEntry(
          descriptor: const BooleanWidgetParameter(
            id: .decayAfterClass,
            defaultValue: true,
          ),
          displayData: (context) => .new(),
          shown: true,
        ),
        WidgetParameterEntry(
          descriptor: const BooleanWidgetParameter(
            id: .onlyOnBusinessDays,
            defaultValue: true,
          ),
          displayData: (context) => .new(),
          shown: true,
        ),
        WidgetParameterEntry(
          descriptor: const DurationWidgetParameter(id: .defaultDelta),
          displayData: (context) => .new(),
          shown: true,
        ),
      ],
      requiredUntilCompute: (session, cache, params) {
        final anchorDate = cache.anchorDate
            .add(params.get(TimetableDayParameter.defaultDelta))
            .toDay();

        final selectedDate =
            params.get(TimetableDayParameter.onlyOnBusinessDays)
            ? session.instance
                  .findBusinessDay(
                    anchorDate,
                    const .new(days: 1),
                    canBeDifferent: true,
                  )
                  .toDay()
            : anchorDate;

        if (params.get(TimetableDayParameter.decayAfterClass) &&
            selectedDate.isAtSameMomentAs(cache.anchorDate) &&
            session.instance.isBusinessDay(selectedDate) &&
            cache.anchorTime.toTime().isBefore(
              session.instance.endings.last.timing,
            ) &&
            !cache.hasDayBaseSchedules(selectedDate)) {
          return [
            TimetableHomePageRequest(
              dates: DateRange(start: selectedDate, end: selectedDate),
            ),
          ];
        }

        return [];
      },
      computeValue: (session, cache, params) {
        final anchorDate = cache.anchorDate
            .add(params.get(TimetableDayParameter.defaultDelta))
            .toDay();

        var selectedDate = params.get(TimetableDayParameter.onlyOnBusinessDays)
            ? session.instance
                  .findBusinessDay(
                    anchorDate,
                    const .new(days: 1),
                    canBeDifferent: true,
                  )
                  .toDay()
            : anchorDate;

        libLog.info('Selected dates are $anchorDate -> $selectedDate');

        if (params.get(TimetableDayParameter.decayAfterClass) &&
            selectedDate.isAtSameMomentAs(cache.anchorDate) &&
            session.instance.isBusinessDay(selectedDate) &&
            cache.anchorTime.toTime().isBefore(
              session.instance.endings.last.timing,
            )) {
          final currentState = cache
              .dayAppStates(selectedDate)
              .firstWhereOrNull(
                (element) => element.range.contains(cache.anchorTime),
              );

          if (currentState?.classRelation == .after) {
            selectedDate = session.instance
                .findBusinessDay(selectedDate, const .new(days: 1))
                .toDay();
          }
        }

        return selectedDate;
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
    WidgetArguments<WidgetArgument> args,
  ) {
    final day = args.get(TimetableDayArgument.day);
    if (!cache.hasDayBaseSchedules(day)) {
      return [
        TimetableHomePageRequest(
          dates: DateRange(start: day, end: day),
        ),
      ];
    }

    return [];
  }

  @override
  FutureOr<DayBlocks?> computeValue(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments args,
  ) {
    return cache.dayBlocks(args.get(TimetableDayArgument.day));
  }

  @override
  Widget buildSliver(
    BuildContext context,
    HomePageWidgetState state,
    DayBlocks value,
  ) => TimetableDayWidgetSliver(state: state, value: value);
}
