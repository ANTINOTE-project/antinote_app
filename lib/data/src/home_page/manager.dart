import 'dart:async';
import 'dart:math';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/home_page/configuration.dart';
import 'package:antinote_app/data/src/home_page/widget/configuration.dart';
import 'package:antinote_app/data/src/home_page/widget/parameters.dart';
import 'package:antinote_app/data/src/home_page/widget/widget.dart';
import 'package:antinote_app/data/src/state.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef HomePageModuleRequestCallback = void Function(
  HomePage page,
  RemoteSession session,
  HomePageCache cache,
);

final class HomePageModuleRequest._merge({
  /// The module to add to the home page request that will be processed in
  /// [callback].
  required final HomePageModule module,

  /// Applies the data to the [cache].
  required final HomePageModuleRequestCallback applyCallback,

  /// The value attached to the request, we use it to know whether to use
  /// modules or direct request to fetch the data.
  required final num value,
}) {
  new({
    required HomePageModule module,
    required HomePageModuleRequestCallback applyCallback,
    required num value,
  }) : this._merge(module: module, applyCallback: applyCallback, value: value);

  HomePageModuleRequest merge(HomePageModuleRequest other) {
    assert(this == other);

    return ._merge(
      module: module,
      applyCallback: applyCallback,
      value: value + other.value,
    );
  }

  bool mergeable(HomePageModuleRequest other, RemoteSession session) =>
      identical(this, other) ||
      (module.widget == other.module.widget &&
          mapEquals(module.data(session), other.module.data(session)));
}

sealed class const HomePageRequest() {
  bool checkIfAvailable(RemoteSession session);

  /// Used to write obvious data to cache, which does not need network requests.
  void preApply(RemoteSession session, HomePageCache cache) {}

  /// Return all the home page modules required to get all the data this request
  /// wants. We do a calculation using the values inputted to determine which
  /// is more efficient between [modules] and [requestDirectly]. The values
  /// should sum up to 1.
  List<HomePageModuleRequest>? listModules(RemoteSession session);

  /// Directly navigate to the relevant page and try to get the requested data
  /// directly from there.
  FutureOr<void> requestDirectly(RemoteSession session, HomePageCache cache);

  HomePageRequest? merge(RemoteSession session, HomePageRequest other);
}

mixin DatesHomePageRequestMixin<T> on HomePageRequest {
  abstract final DateRange dates;

  bool checkDay(Date day, RemoteSession session);
  HomePageModuleRequest createModule(Date day, num value);

  @override
  void preApply(RemoteSession session, HomePageCache cache) {
    apply(
      [],
      dates.listDays().whereNot((day) => checkDay(day, session)).toSet(),
      session,
      cache,
    );
  }

  @override
  List<HomePageModuleRequest>? listModules(RemoteSession session) {
    final days = dates.listDays().where((day) => checkDay(day, session));
    return [for (final day in days) createModule(day, 1 / days.length)];
  }

  DateRange? mergeDays(RemoteSession session, DatesHomePageRequestMixin other) {
    final newStart = DateTime.fromMillisecondsSinceEpoch(
      min(
        other.dates.start.millisecondsSinceEpoch,
        dates.start.millisecondsSinceEpoch,
      ),
      isUtc: true,
    ).toDay();
    final newEnd = DateTime.fromMillisecondsSinceEpoch(
      max(
        other.dates.end.millisecondsSinceEpoch,
        dates.end.millisecondsSinceEpoch,
      ),
      isUtc: true,
    ).toDay();

    final newDays = DateRange(start: newStart, end: newEnd);
    final newDaysCount = newDays
        .listDays()
        .where((day) => checkDay(day, session))
        .length;

    final oldDaysCount = dates
        .listDays()
        .where((day) => checkDay(day, session))
        .length;

    // If we didn't request more days than we requested in the final response,
    // we consider this inefficient.
    if ((newDaysCount << 1) < oldDaysCount) return null;

    return newDays;
  }

  void apply(
    List<T> elements,
    Set<Date> minimumDates,
    RemoteSession session,
    HomePageCache cache,
  );
}

final class const TimetableHomePageRequest({
  @override required final DateRange dates,
}) extends HomePageRequest with DatesHomePageRequestMixin<Class> {
  static const _applicableWorkspaces = <WorkspaceType>[
    .parent,
    .eleve,
    .accompagnant,
    .mobileParent,
    .mobileEleve,
    .mobileAccompagnant,
    .mobileProfesseur,
  ];

  @override
  bool checkIfAvailable(RemoteSession session) =>
      _applicableWorkspaces.contains(session.instance.workspace.type) ||
      session.user.hasAccessToTab(TimetableAccessor.pageId);

  @override
  bool checkDay(Date day, RemoteSession session) =>
      session.instance.isBusinessDay(day);

  @override
  HomePageModuleRequest createModule(Date day, num value) =>
      HomePageModuleRequest(
        module: EDT.module(day),
        applyCallback: (page, session, cache) => apply(
          page.widgets.whereType<EDT>().singleOrNull?.timetable.classes ?? [],
          {day},
          session,
          cache,
        ),
        value: value,
      );

  @override
  FutureOr<bool> requestDirectly(
    RemoteSession session,
    HomePageCache cache,
  ) async {
    final timetable = await session.access(
      TimetableAccessor.forRange(
        resource: session.userResource,
        from: dates.start,
        to: dates.end,
      ),
    );

    return apply(timetable.classes, dates.listDays().toSet(), session, cache);
  }

  @override
  bool apply(
    List<Class> classes,
    Set<Date> minimumDates,
    RemoteSession session,
    HomePageCache cache,
  ) {
    final scheduleDays = minimumDates.union({
      for (final clazz in classes) clazz.startDate.toDay(),
    });

    for (final day in scheduleDays) {
      final relevant = classes
          .where((clazz) => clazz.startDate.toDay().isAtSameMomentAs(day))
          .toList(growable: false);

      final events = eventsForDay(relevant, session.instance);
      cache._daySchedules[day.toDay()] = (
        events: events,
        appStates: AppStateScheduler.scheduleForDay(
          day.toDay(),
          events: events,
          params: session.instance,
        ),
        blocks: blocksForDay(events, session.instance),
      );
    }

    return true;
  }

  @override
  HomePageRequest? merge(RemoteSession session, HomePageRequest other) {
    if (other is! TimetableHomePageRequest) return null;

    final newRange = mergeDays(session, other);
    if (newRange == null) return null;

    return TimetableHomePageRequest(dates: newRange);
  }
}

final class const MenuHomePageRequest({
  @override required final DateRange dates,
}) extends HomePageRequest with DatesHomePageRequestMixin<Menu> {
  @override
  bool checkIfAvailable(RemoteSession session) =>
      session.user.hasAccessToTab(MenuPageAccessor.pageId) &&
      session.instance.lunchDays.isNotEmpty &&
      session.instance.lunchActivation;

  @override
  bool checkDay(Date day, RemoteSession session) =>
      session.instance.lunchDays.contains(day.weekday - 1);
  @override
  HomePageModuleRequest createModule(
    Date day,
    num value,
  ) => HomePageModuleRequest(
    module: MenuDeLaCantine.module(day),
    applyCallback: (page, session, cache) => apply(
      [?page.widgets.whereType<MenuDeLaCantine>().singleOrNull?.currentMenu],
      {day},
      session,
      cache,
    ),
    value: value,
  );

  @override
  List<HomePageModuleRequest>? listModules(RemoteSession session) {
    if (session.instance.workspace.type.categories.contains(
      WorkspaceCategory.mobile,
    )) {
      return null;
    }

    return super.listModules(session);
  }

  @override
  FutureOr<void> requestDirectly(
    RemoteSession session,
    HomePageCache cache,
  ) async {
    final daysPerWeek = <int, List<Date>>{};
    for (final day in dates.listDays().where((day) => checkDay(day, session))) {
      final weekNumber = session.instance.getWeekNumberForDate(day);
      if (!daysPerWeek.containsKey(weekNumber)) {
        daysPerWeek[weekNumber] = [day];
      } else {
        daysPerWeek[weekNumber]!.add(day);
      }
    }

    for (final MapEntry(key: weekNumber, value: days) in daysPerWeek.entries) {
      if (days.length > 1) {
        apply(
          (await session.access(
            MenuPageAccessor(
              date: session.instance.getDateForWeekNumber(weekNumber),
            ),
          )).menus,
          session.instance.getDaysForWeekNumber(weekNumber).toSet(),
          session,
          cache,
        );
      } else {
        apply(
          (await session.access(MenuPageAccessor(date: days.single))).menus,
          {days.single},
          session,
          cache,
        );
      }
    }
  }

  @override
  void apply(
    List<Menu> menus,
    Set<Date> minimumDates,
    RemoteSession session,
    HomePageCache cache,
  ) {
    final menuDays = minimumDates.union({
      for (final menu in menus) menu.time.toDay(),
    });

    for (final day in menuDays) {
      final menu = menus.firstWhereOrNull(
        (menu) => menu.time.toDay().isAtSameMomentAs(day),
      );

      cache._dayMenus[day] = menu;
    }
  }

  @override
  HomePageRequest? merge(RemoteSession session, HomePageRequest other) {
    if (other is! MenuHomePageRequest) return null;

    final newRange = mergeDays(session, other);
    if (newRange == null) return null;

    return MenuHomePageRequest(dates: newRange);
  }
}

final class const HomeworkHomePageRequest({
  @override required final DateRange dates,
}) extends HomePageRequest with DatesHomePageRequestMixin<Homework> {
  @override
  bool checkIfAvailable(RemoteSession session) =>
      session.user.hasAccessToTab(NotebookSection.homework.pageId);

  @override
  bool checkDay(Date day, RemoteSession session) => true;

  @override
  HomePageModuleRequest createModule(Date day, num value) =>
      HomePageModuleRequest(
        module: TravailAFaire.module(),
        applyCallback: (page, session, cache) => apply(
          page.widgets.whereType<TravailAFaire>().singleOrNull?.homeworks ?? [],
          {day},
          session,
          cache,
        ),
        value: value,
      );

  @override
  List<HomePageModuleRequest>? listModules(RemoteSession session) {
    final today = DateTime.now().toDay(true);

    if (dates.start.isBefore(today) ||
        dates.end.isAfter(today.add(const Duration(days: 6)))) {
      // The widget only returns the homeworks for the next 7 days, we can't use
      // home page modules if we try to get homeworks outside that range.
      return null;
    }

    return super.listModules(session);
  }

  @override
  FutureOr<void> requestDirectly(
    RemoteSession session,
    HomePageCache cache,
  ) async {
    final weeks = <int>{
      for (final day in dates.listDays())
        session.instance.getWeekNumberForDate(day),
    };

    final result = await session.access(
      NotebookPageAccessor(section: .homework, weeks: weeks),
    );
    final homeworks = result.homeworkSet?.homeworks;

    if (homeworks == null) return;

    apply(
      homeworks,
      {
        for (final week in weeks)
          ...session.instance.getDaysForWeekNumber(week),
      },
      session,
      cache,
    );
  }

  @override
  void apply(
    List<Homework> homeworks,
    Set<Date> minimumDates,
    RemoteSession session,
    HomePageCache cache,
  ) {
    final homeworkDays = minimumDates.union({
      for (final homework in homeworks) homework.deadlineDate,
    });

    for (final day in homeworkDays) {
      cache._dayHomeworks[day] = homeworks
          .where((homework) => homework.deadlineDate.isAtSameMomentAs(day))
          .toList(growable: false);
    }
  }

  @override
  HomePageRequest? merge(RemoteSession session, HomePageRequest other) {
    if (other is! HomeworkHomePageRequest) return null;

    final newRange = mergeDays(session, other);
    if (newRange == null) return null;

    return HomeworkHomePageRequest(dates: newRange);
  }
}

typedef _SchedulesEntry = ({
  List<Event> events,
  List<Block> blocks,
  List<AppStateEntry> appStates,
});

final class HomePageCache {
  final int sessionId;

  late final DateTime anchorTime;

  new({required this.sessionId, DateTime? anchorTime})
    : anchorTime = anchorTime ?? DateTime.now().copyWith(isUtc: true);

  new recycle({required this.sessionId, required HomePageCache existing})
    : anchorTime = existing.anchorTime;

  Date get anchorDate => anchorTime.toDay();

  final Map<Date, _SchedulesEntry> _daySchedules = {};
  final Map<Date, Menu?> _dayMenus = {};
  final Map<Date, List<Homework>> _dayHomeworks = {};

  /// Ensures at least events for the day and the app states are loaded.
  bool hasDayBaseSchedules(Date day) => _daySchedules.containsKey(day);
  List<Event> dayEvents(Date day) => _daySchedules[day]!.events;
  List<AppStateEntry> dayAppStates(Date day) => _daySchedules[day]!.appStates;
  List<Block> dayBlocks(Date day) => _daySchedules[day]!.blocks;

  /// Ensures the menu for a day is loaded.
  bool hasMenuForDay(Date day) => _dayMenus.containsKey(day);
  Menu dayMenu(Date day) => _dayMenus[day] ?? Menu(time: day, meals: []);

  bool hasHomeworksForDay(Date day) => _dayHomeworks.containsKey(day);
  List<Homework> dayHomeworks(Date day) => _dayHomeworks[day]!;

  /// We expect the most important requests to be put at the start.
  Future<void> runBestRequest(
    RemoteSession session,
    List<HomePageRequest> requests,
  ) async {
    if (requests.isEmpty) return;

    final shortRequests = <HomePageRequest>[];
    final shortModules = <HomePageModuleRequest>[];

    requestLoop:
    for (final request in requests) {
      if (!request.checkIfAvailable(session)) continue;

      final modules = request.listModules(session);

      moduleLoop:
      for (final module in modules ?? []) {
        for (int i = 0; i < shortModules.length; i++) {
          if (!shortModules[i].mergeable(module, session)) continue;

          shortModules[i] = shortModules[i].merge(module);
          continue moduleLoop;
        }
        shortModules.add(module);
      }

      for (int i = 0; i < shortRequests.length; i++) {
        final merged = shortRequests[i].merge(session, request);
        if (merged == null) continue;

        shortRequests[i] = merged;
        continue requestLoop;
      }
      shortRequests.add(request);
    }

    shortModules.sort((a, b) => b.value.compareTo(a.value));

    for (final request in shortRequests) {
      request.preApply(session, this);
    }

    final bestHomePage = <HomePageModuleRequest>[];
    final appliedWidgetTypes = <HomePageWidgetType>{};
    num totalHomePageValue = 0;
    for (final module in shortModules) {
      if (appliedWidgetTypes.add(module.module.widget)) {
        bestHomePage.add(module);
        totalHomePageValue += module.value;
      }
    }

    if (totalHomePageValue >= 1) {
      final result = await session.access(
        HomePageAccessor(
          modules: bestHomePage.map((e) => e.module).toList(growable: false),
        ),
      );
      for (final module in bestHomePage) {
        module.applyCallback(result, session, this);
      }
    } else {
      await shortRequests.first.requestDirectly(session, this);
    }
  }

  void applyCache(HomePageCache other) {
    _daySchedules.addAll(other._daySchedules);
    _dayMenus.addAll(other._dayMenus);
    _dayHomeworks.addAll(other._dayHomeworks);
  }
}

final class HomePageWidgetState<
  V,
  A extends WidgetArgument,
  P extends WidgetParameter
>({
  required final HomePageWidgetConfiguration<V, A, P> configuration,
  required final Map<A, dynamic> rawArguments,
  required final int index,
}) extends ValueNotifier<V?> {
  this : super(null);

  bool get loaded => value != null;

  WidgetDescriptor<V, A, P> get descriptor => configuration.descriptor;

  /// The parameters contain the raw settings as saved on disk that are used
  /// customise the behavior of the widget as per user preferences.
  WidgetParameters<P> get parameters =>
      descriptor.arguments.firstOrNull?.createParameters(
        configuration.rawParameters,
      ) ??
      .new(params: configuration.rawParameters);

  /// This contains the arguments as loaded by the initialisation of the home
  /// page.
  WidgetArguments<A> get baseArguments =>
      descriptor.createArguments(rawArguments);

  /// This contains the arguments that are changed after initialisation so that
  /// when reloading a widget, those arguments will be taken into account.
  final WidgetArguments<A> overrideArguments = WidgetArguments(
    args: <A, dynamic>{},
  );

  /// This contains the base arguments with the ones edited for reload, if there
  /// are any.
  WidgetArguments<A> get reloadArguments =>
      baseArguments.mergeWith(overrideArguments);
}

/// This manager is "short-lived". A new one should be created on each reload.
/// It may be kept from the start of the reload until the start of the next
/// reload and be used to update widgets that support update operations.
final class HomePageManager() {
  bool initialized = false;

  late HomePageCache _cache;

  late final List<HomePageWidgetState> loadedWidgets;

  /// If a loaded home page widget is returned it is [identical] as the one
  /// provided. If [null] is returned, this means the widget got destroyed.
  ///
  /// When [force] is [false], the widget will update only if the session is
  /// different. Else, the widget will always update.
  Future<HomePageWidgetState?> reloadWidget(
    RemoteSession session,
    HomePageWidgetState widget, {
    required bool force,
  }) async {
    assert(loadedWidgets.contains(widget));

    if (!force && _cache.sessionId != session.stack.sessionId) {
      return widget;
    }

    final tempCache = HomePageCache.recycle(
      sessionId: session.stack.sessionId,
      existing: _cache,
    );

    final loaded = (await _loadWidgetConfigurations(
      session: session,
      widgets: [widget],
      cache: tempCache,
    )).singleOrNull;

    _cache.applyCache(tempCache);

    if (loaded == null) return null;

    widget.value = loaded.value;

    return widget;
  }

  Future<void> initialize(BuildContext context, RemoteSession session) async {
    if (initialized) return;
    initialized = true;

    assert(
      context.mounted,
      'Initializing home page with an unmounted context.',
    );

    final l10n = context.l10n;
    final settings = context.s;

    _cache = HomePageCache(
      sessionId: session.stack.sessionId,
      anchorTime: session.stack.demo ? session.instance.demoDateTime : null,
    );

    final config =
        (await _findConfiguration(
          session,
          (await settings.homePage.getConditionalConfigurations(l10n)).toList(),
        )) ??
        await settings.homePage.getBaseConfiguration(l10n);

    final loadedWidgetConfigurations = config.widgets.toList();
    if (!config.exclusive) {
      final baseWidgets = (await settings.homePage.getBaseConfiguration(l10n))
          .widgets
          .toList();
      for (final widget in loadedWidgetConfigurations) {
        final duplicate = baseWidgets.firstWhereOrNull(
          (element) => element.descriptor.id == widget.descriptor.id,
        );
        if (duplicate != null) {
          baseWidgets.remove(duplicate);
        }
      }

      loadedWidgetConfigurations.addAll(baseWidgets);
    }

    final entries = loadedWidgetConfigurations
        .mapIndexed((i, e) => e.createState(i))
        .toList();

    loadedWidgets = await _loadWidgetConfigurations(
      session: session,
      widgets: entries,
      cache: _cache,
    );
  }

  Future<HomePageConfiguration?> _findConfiguration(
    RemoteSession session,
    List<HomePageConfiguration> candidates,
  ) async {
    while (candidates.isNotEmpty) {
      final requests = <HomePageRequest>[];

      final newCandidates = <HomePageConfiguration>[];

      for (final candidate in candidates) {
        if (candidate.criterion == null) {
          newCandidates.add(candidate);
          break;
        }

        final curRequests = candidate.criterion!.requestsUntilRequirements(
          _cache,
        );

        if (curRequests.isEmpty) {
          if (await candidate.criterion!.meetsRequirement(_cache)) {
            return candidate;
          } else {
            continue;
          }
        } else {
          requests.addAll(curRequests);
          newCandidates.add(candidate);
        }
      }

      candidates.clear();
      candidates.addAll(newCandidates);

      await _cache.runBestRequest(session, requests);
    }

    return null;
  }

  Future<List<HomePageWidgetState>> _loadWidgetConfigurations({
    required RemoteSession session,
    required List<HomePageWidgetState> widgets,
    required HomePageCache cache,
  }) async {
    final Map<int, HomePageWidgetState> loaded = {};

    final List<HomePageWidgetState> entries = widgets;
    while (entries.isNotEmpty) {
      final requests = <HomePageRequest>[];
      final newEntries = <HomePageWidgetState>[];

      entryLoop:
      for (final entry in entries) {
        final curRequests = <HomePageRequest>[];

        for (final argument in entry.descriptor.arguments) {
          if (entry.reloadArguments.has(argument.id)) continue;

          final required = argument.requiredUntilCompute(
            session,
            cache,
            entry.parameters,
          );

          if (required.isEmpty) {
            final value = await argument.computeValue(
              session,
              cache,
              entry.parameters,
            );

            if (value == null) continue entryLoop;

            entry.rawArguments[argument.id] = value;
          } else {
            curRequests.addAll(required);
          }
        }

        if (curRequests.isNotEmpty) {
          requests.addAll(curRequests);
          newEntries.add(entry);
          continue;
        }

        final arguments = entry.reloadArguments;

        final widgetRequests = entry.configuration.descriptor
            .requiredUntilCompute(session, cache, arguments);

        if (widgetRequests.isNotEmpty) {
          requests.addAll(widgetRequests);
          newEntries.add(entry);
          continue;
        }

        loaded[entry.index] = entry
          ..value = await entry.configuration.descriptor.computeValue(
            session,
            cache,
            arguments,
          );
      }

      entries.clear();
      entries.addAll(newEntries);

      await cache.runBestRequest(session, requests);
    }

    return loaded.entries
        .sorted((a, b) => a.key.compareTo(b.key))
        .map((e) => e.value)
        .toList(growable: false);
  }
}
