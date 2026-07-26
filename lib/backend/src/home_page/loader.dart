import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/state.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";

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
  /// This should be used instead of [Datetime.now], it is in UTC format.
  final DateTime anchorTime = DateTime.now().copyWith(isUtc: true);

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
  Menu dayMenu(Date day) => _dayMenus[day]!;

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

    // TODO: Do some grouping optimization

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
}
