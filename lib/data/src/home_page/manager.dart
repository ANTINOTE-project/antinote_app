import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/home_page/configuration.dart';
import 'package:antinote_app/data/src/home_page/widget/configuration.dart';
import 'package:antinote_app/data/src/home_page/widget/parameters.dart';
import 'package:antinote_app/data/src/home_page/widget/widget.dart';
import 'package:antinote_app/data/src/state.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

enum HomePageRequestType { schedules, menu, grades, schoolLife, news, homework }

final class HomePageRequest {
  final HomePageRequestType type;

  final Date? date;

  const new schedules(this.date) : type = .schedules;
  const new menu(this.date) : type = .menu;
  const new grades() : type = .grades, date = null;
  const new schoolLife() : type = .schoolLife, date = null;
  const new news() : type = .news, date = null;
  const new homework() : type = .homework, date = null;

  HomePageModule get module => switch (type) {
    .schedules => EDT.module(date!),
    .menu => MenuDeLaCantine.module(date!),
    .grades => Notes.module(),
    .schoolLife => VieScolaire.module(),
    .news => Actualites.module(),
    .homework => TravailAFaire.module(),
  };

  dynamic extractResult(HomePage page) {
    return switch (type) {
      .schedules => page.widgets.whereType<EDT>().firstOrNull?.timetable,
      .menu => <Menu>[
        ?page.widgets.whereType<MenuDeLaCantine>().firstOrNull?.currentMenu,
      ],
      .grades => page.widgets.whereType<Notes>().firstOrNull?.page,
      .schoolLife =>
        page.widgets.whereType<VieScolaire>().firstOrNull?.absences,
      .news => page.widgets.whereType<Actualites>().firstOrNull?.news,
      .homework =>
        page.widgets.whereType<TravailAFaire>().firstOrNull?.homeworks,
    };
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

  /// Ensures at least events for the day and the app states are loaded.
  bool hasDayBaseSchedules(Date day) => _daySchedules.containsKey(day);
  List<Event> dayEvents(Date day) => _daySchedules[day]!.events;
  List<AppStateEntry> dayAppStates(Date day) => _daySchedules[day]!.appStates;
  List<Block> dayBlocks(Date day) => _daySchedules[day]!.blocks;

  /// Ensures the menu for a day is loaded.
  bool hasMenuForDay(Date day) => _dayMenus.containsKey(day);
  Menu dayMenu(Date day) => _dayMenus[day] ?? Menu(time: day, meals: []);

  /// We expect the most important requests to be put at the start.
  ///
  /// We create the request with the most modules possible and update the object
  /// accordingly.
  ///
  /// We may use other requests than the home page if we have only a single
  /// module and [session.options.saveNavigationRequests] is [true].
  Future<void> runBestRequest(
    RemoteSession session,
    List<HomePageRequest> requests,
  ) async {
    if (requests.isEmpty) return;

    final keptModules = <({HomePageRequest req, HomePageModule mod})>[];

    for (final request in requests) {
      final module = request.module;
      if (keptModules.any((element) => element.mod.widget == module.widget)) {
        continue;
      }

      keptModules.add((req: request, mod: module));
    }

    final result = await session.access(
      HomePageAccessor(modules: keptModules.mapL((e) => e.mod)),
    );

    // TODO: Do some grouping optimization (like do a timetable request when
    // TODO: there are 7 days to fetch and other useful home page requests are
    // TODO: consumed).

    for (final (req: request, mod: _) in keptModules) {
      _applyResponse(session, request, request.extractResult(result));
    }
  }

  void _applyResponse(RemoteSession session, HomePageRequest req, dynamic res) {
    switch (req.type) {
      case .schedules:
        final schedule = res as Timetable?;

        // TODO: Make this into a range so that not only the requested day (if
        // TODO: empty) is asserted as class-free.
        final scheduleDays = (schedule?.dayList() ?? <DateTime>{}).union({
          req.date!,
        });

        for (final day in scheduleDays) {
          final relevant =
              schedule?.classes
                  .where(
                    (element) =>
                        element.startDate.toDay().isAtSameMomentAs(day),
                  )
                  .toList(growable: false) ??
              [];

          final events = eventsForDay(relevant, session.instance);
          _daySchedules[day.toDay()] = (
            events: events,
            appStates: AppStateScheduler.scheduleForDay(
              day.toDay(),
              events: events,
              params: session.instance,
            ),
            blocks: blocksForDay(events, session.instance),
          );
        }
      case .menu:
        // TODO: When the first day of the week is selected in the menu page
        // TODO: (only), all menus for the week are returned, do the same change
        // TODO: as in the schedules above.
        final menus = res as List<Menu>;
        bool foundRequested = false;

        for (final menu in menus) {
          if (menu.time.isAtSameMomentAs(req.date!)) foundRequested = true;
          _dayMenus[menu.time.toDay()] = menu;
        }

        if (!foundRequested) _dayMenus[req.date!.toDay()] = null;
      case .grades:
        // TODO: Handle this case.
        throw UnimplementedError();
      case .schoolLife:
        // TODO: Handle this case.
        throw UnimplementedError();
      case .news:
        // TODO: Handle this case.
        throw UnimplementedError();
      case .homework:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void applyCache(HomePageCache other) {
    _daySchedules.addAll(other._daySchedules);
    _dayMenus.addAll(other._dayMenus);
    // TODO: Handle other cases.
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
