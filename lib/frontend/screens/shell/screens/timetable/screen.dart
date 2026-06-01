import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/body.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/class_block.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/main.dart";
import "package:antinote_app/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

typedef Classes = Map<DateTime, ValueNotifier<List<ClassBlock>?>>;

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
    final dayList = days.listDays();

    for (final day in days.listDays()) {
      if (!_scheduleDisplayData.isBusinessDay(day)) {
        _classes[day]!.value = [];

        dayList.removeWhere((element) => element.isAtSameMomentAs(day));
      }
    }

    if (dayList.isEmpty) return;
    if (_animating) return;

    talker.info("Fetching days ${days.pprint(context)}");
    Future<void> update(PronoteSession session) async {
      final loadedDays = {for (final day in dayList) day: <Class>[]};

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
        _classes[loadedDay.key]!.value = constructClassBlocksForDay(
          loadedDay.value,
        );
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

          return Scaffold(
            appBar: buildAppBar(dayGroup, context),
            body: RefreshIndicator(
              onRefresh: () => reload(fromRefreshIndicator: true),
              child: SingleChildScrollView(
                padding: .only(
                  bottom: MediaQuery.paddingOf(context).bottom + 10,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: .stretch,
                    children: [
                      Expanded(
                        flex: days.length * 15,
                        child: buildTimeColumn(context, days),
                      ),

                      for (final day in days)
                        Expanded(
                          flex: 85,
                          child: ValueListenableBuilder(
                            valueListenable: _classes[day]!,
                            builder: (context, dayClasses, child) {
                              if (dayClasses == null) {
                                return const Center(child: LoadingWidget());
                              }

                              if (dayClasses.isEmpty) {
                                final holiday = _scheduleDisplayData.holidays
                                    .firstWhereOrNull(
                                      (element) => element.contains(day),
                                    );

                                return Center(
                                  child: Column(
                                    mainAxisAlignment: .center,
                                    spacing: 6,
                                    children: [
                                      Icon(
                                        holiday == null
                                            ? HugeIconsSolid.calendar04
                                            : HugeIconsSolid.beach,
                                        size: 44,
                                        color: context.c.outline,
                                      ),
                                      Text(
                                        holiday?.name ??
                                            context.l10n.noCourseToday,
                                        style: TextStyle(
                                          fontWeight: .bold,
                                          color: context.c.outline,
                                        ),
                                        textAlign: .center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return buildClassesColumn(
                                context,
                                day,
                                dayClasses,
                              );
                              // return Column(
                              //   children: [
                              //     for (final block in dayClasses)
                              //       Expanded(
                              //         flex: block.endTime
                              //             .difference(block.startTime)
                              //             .inMinutes,
                              //         child: TimetableBlockSliver(
                              //           displayParameters: _scheduleDisplayData,
                              //           day: day,
                              //           block: block,
                              //         ),
                              //       ),
                              //   ],
                              // );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(DateRange dayGroup, BuildContext context) {
    return AppBar(
      title: TextButton.icon(
        label: Text(dayGroup.pprint(context)),

        icon: const Icon(HugeIconsSolid.calendar03),
        iconAlignment: .end,

        onPressed: () async {
          final selected = await showDatePicker(
            context: context,
            firstDate: _scheduleDisplayData.firstDate,
            lastDate: _scheduleDisplayData.lastDate,
          );

          if (selected == null) return;

          animateToDay(selected.copyWith(isUtc: true).toDay());
        },
      ),
    );
  }

  Widget buildTimeColumn(BuildContext context, List<DateTime> days) {
    final relevantSlots = <int>{};
    for (final day in days) {
      for (final clazz in _classes[day]!.value ?? <ClassBlock>[]) {
        relevantSlots.add(clazz.startSlot % _scheduleDisplayData.slotsPerDay);
        relevantSlots.add(clazz.endSlot % _scheduleDisplayData.slotsPerDay - 1);
      }
    }

    final displays = <Widget>[];

    int? lastAppliedSlot;
    for (
      int i = relevantSlots.firstOrNull ?? 0;
      i < (relevantSlots.lastOrNull ?? 0);
      i++
    ) {
      final curSlot = _scheduleDisplayData.starts[i];
      final curEndSlot = _scheduleDisplayData.endings[i];

      if (lastAppliedSlot != null && lastAppliedSlot + 1 != i) {
        final from = _scheduleDisplayData.starts[lastAppliedSlot + 1];
        final to = _scheduleDisplayData.endings[i - 1];

        final value =
            (to.timing.hour - from.timing.hour) * Duration.minutesPerHour +
            to.timing.minute -
            from.timing.minute;

        talker.info("${from.timing} -> ${to.timing} : $value");
        displays.add(Expanded(flex: value, child: const SizedBox.expand()));
      }

      if (curEndSlot.timing == curSlot.timing) continue;

      if (i > 0) {
        final previous = _scheduleDisplayData.endings[i - 1];

        final transitionValue =
            (curSlot.timing.hour - previous.timing.hour) *
                Duration.minutesPerHour +
            curSlot.timing.minute -
            previous.timing.minute;

        if (transitionValue > 0) {
          displays.add(
            Expanded(flex: transitionValue, child: const SizedBox.expand()),
          );
        }
      }

      final value =
          (curEndSlot.timing.hour - curSlot.timing.hour) *
              Duration.minutesPerHour +
          curEndSlot.timing.minute -
          curSlot.timing.minute;
      displays.add(
        Expanded(
          flex: value,
          child: Stack(
            fit: .expand,
            children: [
              if (curSlot.active)
                Align(alignment: .topCenter, child: Text(curSlot.label)),
              if (curEndSlot.active)
                Align(alignment: .bottomCenter, child: Text(curEndSlot.label)),
            ],
          ),
        ),
      );

      lastAppliedSlot = i;
    }

    return Column(children: displays);
  }

  Widget buildClassesColumn(
    BuildContext context,
    DateTime day,
    List<ClassBlock> blocks,
  ) {
    final displays = <Widget>[];

    DateTime? curTime;
    for (final block in blocks) {
      if (curTime != null && !curTime.isAtSameMomentAs(block.startTime)) {
        displays.add(
          Expanded(
            flex: block.startTime.difference(curTime).inMinutes,
            child: const SizedBox.expand(),
          ),
        );
      }

      displays.add(
        Expanded(
          flex: block.endTime.difference(block.startTime).inMinutes,
          child: TimetableBlockWidget(
            displayParameters: _scheduleDisplayData,
            day: day,
            block: block,
          ),
        ),
      );

      curTime = block.endTime;
    }

    return Column(children: displays);
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget()));
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
