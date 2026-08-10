import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/home_page/configuration.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/data/src/home_page/widget/parameters.dart';
import 'package:antinote_app/data/src/home_page/widget/widget.dart';
import 'package:antinote_app/ui/l10n/app_localizations.dart';

const descriptors = <WidgetDescriptor>[
  MenuWidget(),
  HomeworkListWidget(),
  TimetableDayWidget(),
];

const defaultDescriptors = <WidgetDescriptor>[
  TimetableDayWidget(),
  HomeworkListWidget(),
  MenuWidget(),
];

List<HomePageConfiguration> createDefaultConfigurations(
  AppLocalizations l10n,
) => [
  .create(name: l10n.breakConfig).copyWith(
    criterion: const RelativeHomePageConfigurationCriterion(
      margin: .new(minutes: 5),
      state: .pause,
    ),
    widgets: [
      // TimetableNextBlockWidget(),
      .new(descriptor: const MenuWidget(), rawParameters: {}),
      // GradesWidget(),
      // CommunicationsWidget(),
    ],
  ),
  .create(name: l10n.transferConfig).copyWith(
    criterion: const RelativeHomePageConfigurationCriterion(
      margin: .new(minutes: 5),
      state: .transfer,
    ),
    widgets: [
      // NextBlockWidget(),
      // CommunicationsWidget(),
    ],
  ),
  // TODO: Find a way to have it with a 5 minutes margin before the end of
  // TODO: classes.
  .create(name: l10n.afterClassConfig).copyWith(
    criterion: OperatorHomePageConfigurationCriterion(
      a: const ClassRelativeHomePageConfigurationCriterion(relation: .after),
      operation: .or,
      b: StaticHomePageConfigurationCriterion(
        relation: .before,
        start: DateTime.utc(1970, 1, 1, 4),
        end: DateTime.utc(1970, 1, 1, 4),
        mask: .defaultState,
      ),
    ),
    widgets: [
      .new(descriptor: const HomeworkListWidget(), rawParameters: {}),
      .new(descriptor: const TimetableDayWidget(), rawParameters: {}),
      // GradesWidget(),
    ],
  ),
  // TODO: Same.
  .create(name: l10n.beforeClassConfig).copyWith(
    criterion: OperatorHomePageConfigurationCriterion(
      a: const ClassRelativeHomePageConfigurationCriterion(relation: .before),
      operation: .and,
      b: NotOperatorHomePageConfigurationCriterion(
        criterion: StaticHomePageConfigurationCriterion(
          relation: .before,
          start: DateTime.utc(1970, 1, 1, 4),
          end: DateTime.utc(1970, 1, 1, 4),
          mask: .defaultState,
        ),
      ),
    ),
    widgets: [
      // TimetableUpdatesWidget(),
      .new(descriptor: const TimetableDayWidget(), rawParameters: {}),
      // CommunicationsWidget(),
    ],
  ),
  .create(name: l10n.lunchConfig).copyWith(
    criterion: const RelativeHomePageConfigurationCriterion.custom(
      startMargin: .new(minutes: 5),
      startAnchor: false,
      state: .lunch,
      endMargin: .new(minutes: -10),
      endAnchor: true,
    ),
    widgets: [
      .new(descriptor: const MenuWidget(), rawParameters: {}),
      .new(descriptor: const TimetableDayWidget(), rawParameters: {}),
    ],
  ),
  .create(name: l10n.pauseConfig).copyWith(
    criterion: const RelativeHomePageConfigurationCriterion(
      margin: .new(minutes: 5),
      state: .pause,
    ),
    widgets: [
      .new(descriptor: const HomeworkListWidget(), rawParameters: {}),
      // SchoolLifeWidget(),
      // TODO: Add parameter to hide menu widget when after lunch.
      .new(descriptor: const MenuWidget(), rawParameters: {}),
    ],
  ),
  .create(name: l10n.classConfig).copyWith(
    criterion: const RelativeHomePageConfigurationCriterion(
      margin: .zero,
      state: .clazz,
    ),
    widgets: [
      // FilteredHomeworkWidget(),
      // FilteredTimetableWidget(),
      // FilteredGradesWidget()
    ],
  ),
];

final class HomePageWidgetConfiguration<
  V,
  A extends WidgetArgument,
  P extends WidgetParameter
>({
  required final WidgetDescriptor<V, A, P> descriptor,
  required final Map<P, dynamic> rawParameters,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final descriptor = descriptors.firstWhere(
      (e) => e.id == json.get('id'),
    ) as WidgetDescriptor<V, A, P>;
    final params = json.getM('params');

    return .new(
      descriptor: descriptor,
      rawParameters: {
        for (final argument in descriptor.arguments)
          for (final parameter in argument.parameters)
            parameter.descriptor.id: params.has(parameter.descriptor.id.code)
                ? parameter.descriptor.read(
                    params.get(parameter.descriptor.id.code),
                  )
                : parameter.descriptor.defaultValue,
      },
    );
  }

  Map<String, dynamic> toJson() => {
    'id': descriptor.id,
    'params': {
      for (final argument in descriptor.arguments)
        for (final parameter in argument.parameters)
          parameter.descriptor.id.code: parameter.descriptor.write(
            rawParameters[parameter.descriptor.id] ??
                parameter.descriptor.defaultValue,
          ),
    },
  };

  HomePageWidgetState<V, A, P> createState(int index) =>
      HomePageWidgetState<V, A, P>(
        configuration: this,
        rawArguments: <A, dynamic>{},
        index: index,
      );
}
