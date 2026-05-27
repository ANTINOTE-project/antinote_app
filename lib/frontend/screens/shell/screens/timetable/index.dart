import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/app_bar.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/body.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/main.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

typedef Classes = Map<DateTime, ValueNotifier<List<Class>?>>;

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with ScreenMixin<TimetableScreen> {
  late SpecificInstanceParameters _scheduleDisplayData;
  late List<DateRange> _currentGroups;
  final Classes _classes = {};

  PageController? _pageController;

  bool _animating = false;
  int? _lastPage;

  Future<void> animateToDay(DateTime day) async {
    final index = _currentGroups.indexWhere((element) => element.contains(day));

    _animating = true;

    await _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );

    _animating = false;
  }

  void onPageDrag() {
    final curPage = _pageController?.page?.round();
    if (curPage == null) return;

    _lastPage ??= curPage;

    if (_lastPage != curPage) {
      _lastPage = curPage;

      reload();
    }
  }

  Future<void> updateClasses(DateRange days, {PronoteSession? session}) async {
    if (_animating) return;

    talker.info("Fetching days ${days.pprint(context)}");
    Future<void> update(PronoteSession session) async {
      final loadedDays = {for (final day in days.listDays()) day: <Class>[]};

      await session.ensurePage(16);

      for (final clazz in (await session.access(
        TimetableAccessor.forRange(
          resource: session.userResource,
          from: days.start,
          to: days.end,
        ),
      )).classes) {
        loadedDays[clazz.startDate.toDay()]!.add(clazz);
      }

      for (final loadedDay in loadedDays.entries) {
        _classes[loadedDay.key]!.value = loadedDay.value;
      }
    }

    if (session != null) {
      await update(session);
    } else {
      await SessionManager.execute(context: context, callback: update);
    }
  }

  @override
  void dispose() {
    _pageController?.removeListener(onPageDrag);
    super.dispose();
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    final daysConfiguration = WeekMappedViewConfiguration.defaultConfigs
        .pickConfig(context);

    final days = DateRange(
      start: _scheduleDisplayData.firstDate,
      end: _scheduleDisplayData.lastDate,
    ).listDays();
    _currentGroups = daysConfiguration.daysToRangeList(
      days,
      _scheduleDisplayData,
    );

    return buildRefreshIndicator(
      child: PageView.builder(
        itemCount: _currentGroups.length,
        controller: _pageController,

        itemBuilder: (context, index) {
          final dayGroup = _currentGroups[index];
          final days = dayGroup.listDays();

          return RefreshIndicator(
            onRefresh: () => reload(fromRefreshIndicator: true),

            child: CustomScrollView(
              slivers: [
                TimetableAppBar(
                  animateToDay: animateToDay,
                  label: dayGroup.pprint(context),
                  firstDate: _scheduleDisplayData.firstDate,
                  lastDate: _scheduleDisplayData.lastDate,
                ),

                TimetableBody(
                  data: _scheduleDisplayData,
                  classes: _classes,
                  days: days,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: const Center(child: LoadingWidget(size: 30)),
    );
  }

  @override
  List<String> get loadChannels => _animating ? [] : ["communication"];

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    _scheduleDisplayData = session.instance;

    final days = DateRange(
      start: _scheduleDisplayData.firstDate,
      end: _scheduleDisplayData.lastDate,
    ).listDays();

    final daysConfiguration = WeekMappedViewConfiguration.defaultConfigs
        .pickConfig(context);
    _currentGroups = daysConfiguration.daysToRangeList(
      days,
      _scheduleDisplayData,
    );

    final int currentGroupIndex;

    if (_pageController == null ||
        !_pageController!.hasClients ||
        _pageController?.page == null) {
      currentGroupIndex = _currentGroups.indexWhere((element) {
        return element.contains(_scheduleDisplayData.nextBusinessDay);
      });
    } else {
      currentGroupIndex = _pageController!.page!.round();
    }

    if (_pageController == null) {
      for (final day in days) {
        _classes[day] = ValueNotifier(null);
      }

      _pageController = PageController(initialPage: currentGroupIndex);
      _pageController?.addListener(onPageDrag);
    }

    await updateClasses(_currentGroups[currentGroupIndex], session: session);
  }
}
