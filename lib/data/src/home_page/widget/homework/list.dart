part of '../widget.dart';

enum HomeworkListParameter<T>(@override final String code)
    implements WidgetParameter<T> {
  homeworkCount<int>('homework_count'),
  forceShowCurrentHomeworks<bool>('force_show_current_homeworks'),
  expandInitiallyShownHomeworkDescription<bool>(
    'expand_initially_shown_homework_description',
  ),
  showAllHomeworks<bool>('show_all_homeworks')
}

enum HomeworkListArgument<T>() implements WidgetArgument<T> {
  homeworkCount<int>(),
  expandHomeworks<bool>()
}

final class const HomeworkListWidget()
    extends
        WidgetDescriptor<
          Map<Date, List<Homework>>,
          HomeworkListArgument,
          HomeworkListParameter
        > {
  @override
  String get id => 'homework_list';

  @override
  get arguments => [
    WidgetArgumentEntry(
      id: .homeworkCount,
      parameters: [
        WidgetParameterEntry(
          descriptor: const IntWidgetParameter(
            id: .homeworkCount,
            defaultValue: 4,
          ),
          displayData: (context) => .new(),
          shown: true,
        ),
        WidgetParameterEntry(
          descriptor: const BooleanWidgetParameter(id: .showAllHomeworks),
          displayData: (context) => .new(),
          shown: true,
        ),
        WidgetParameterEntry(
          descriptor: const BooleanWidgetParameter(
            id: .forceShowCurrentHomeworks,
          ),
          displayData: (context) => .new(),
          shown: true,
        ),
      ],
      requiredUntilCompute: (session, cache, params) {
        if (params.get(HomeworkListParameter.showAllHomeworks)) {
          return [];
        }

        final today = cache.anchorDate;

        for (int i = 0; i < 7; i++) {
          final day = today.add(Duration(days: i)).toDay();

          if (!cache.hasHomeworksForDay(day)) {
            return [
              HomeworkHomePageRequest(
                dates: DateRange(start: day, end: day),
              ),
            ];
          }
        }

        return [];
      },
      computeValue: (session, cache, params) {
        if (params.get(HomeworkListParameter.showAllHomeworks)) {
          return -1;
        }

        if (params.get(HomeworkListParameter.forceShowCurrentHomeworks)) {
          final todayHomeworks = cache.dayHomeworks(cache.anchorDate);
          if (todayHomeworks.isNotEmpty) {
            return max(
              todayHomeworks.length,
              params.get(HomeworkListParameter.homeworkCount),
            );
          }

          final nextDayHomeworks = cache.dayHomeworks(
            session.instance
                .findBusinessDay(
                  cache.anchorDate,
                  const Duration(days: 1),
                  canBeDifferent: true,
                )
                .toDay(),
          );
          if (nextDayHomeworks.isNotEmpty) {
            return max(
              nextDayHomeworks.length,
              params.get(HomeworkListParameter.homeworkCount),
            );
          }
        }

        return params.get(HomeworkListParameter.homeworkCount);
      },
    ),

    WidgetArgumentEntry(
      id: .expandHomeworks,
      parameters: [
        WidgetParameterEntry(
          descriptor: const BooleanWidgetParameter(
            id: .expandInitiallyShownHomeworkDescription,
            defaultValue: true,
          ),
          displayData: (context) => .new(),
          shown: true,
        ),
      ],
      requiredUntilCompute: (session, cache, params) => [],
      computeValue: (session, cache, params) {
        return params.get(
          HomeworkListParameter.expandInitiallyShownHomeworkDescription,
        );
      },
    ),
  ];

  @override
  List<HomePageRequest> requiredUntilCompute(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments<WidgetArgument<dynamic>> args,
  ) {
    final today = cache.anchorDate;

    for (int i = 0; i < 7; i++) {
      final day = today.add(Duration(days: i)).toDay();

      if (!cache.hasHomeworksForDay(day)) {
        return [
          HomeworkHomePageRequest(
            dates: DateRange(start: day, end: day),
          ),
        ];
      }
    }

    return [];
  }

  @override
  Map<int, WidgetUpgradeTask> get upgradeTasks => {};

  @override
  int get version => 1;

  @override
  Widget buildSliver(
    BuildContext context,
    HomePageWidgetState<
      dynamic,
      WidgetArgument<dynamic>,
      WidgetParameter<dynamic>
    >
    state,
    Map<Date, List<Homework>> value,
  ) => HomeworkWidgetSliver(state: state, value: value);

  @override
  FutureOr<Map<Date, List<Homework>>?> computeValue(
    RemoteSession session,
    HomePageCache cache,
    WidgetArguments<WidgetArgument<dynamic>> args,
  ) {
    return {
      for (int i = 0; i < 7; i++)
        cache.anchorDate.add(Duration(days: i)).toDay(): cache.dayHomeworks(
          cache.anchorDate.add(Duration(days: i)).toDay(),
        ),
    };
  }
}
