import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:antinote_app/frontend/screens/timetable/events/pause/widget.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/main.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

import "events/class/widget.dart";

typedef Classes = Map<DateTime, ValueNotifier<DayBlocks?>>;

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Future<Map<DateTime, DayBlocks>> update(
    PronoteSession session,
    DateRange days,
    List<DateTime> dayList,
  ) async {
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

    return loadedDays.map(
      (key, value) => MapEntry(key, blocksForDay(value, session.instance)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TimetableDisplay(updateBlocks: update);
  }
}

class TimetableDisplay extends StatefulWidget {
  const TimetableDisplay({
    super.key,
    required this.updateBlocks,
    this.configurations = WeekMappedViewConfiguration.defaultConfigs,
    this.scrollable = true,
  });

  final List<WeekMappedViewConfiguration> configurations;
  final Future<Map<DateTime, DayBlocks>> Function(
    PronoteSession session,
    DateRange days,
    List<DateTime> businessDays,
  )
  updateBlocks;

  final bool scrollable;

  @override
  State<TimetableDisplay> createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay>
    with TabMixin<TimetableDisplay> {
  late SpecificInstanceParameters _scheduleDisplayData;
  late List<DateRange> _currentGroups;
  final Classes _classes = {};

  PageController? _pageController;

  bool _animating = false;
  int? _lastPage;

  Future<void> _animateToDay(DateTime day) async {
    final index = _currentGroups.indexWhere((element) => element.contains(day));

    _animating = true;

    await _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );

    _animating = false;

    reload();
  }

  void _onPageDrag() {
    final curPage = _pageController?.page?.round();
    if (curPage == null) return;

    _lastPage ??= curPage;

    if (_lastPage != curPage) {
      _lastPage = curPage;

      reload();
    }
  }

  Future<void> _updateClasses(DateRange days, {PronoteSession? session}) async {
    final dayList = days.listDays();

    for (final day in days.listDays()) {
      if (!_scheduleDisplayData.isBusinessDay(day)) {
        _classes[day]!.value = [];

        dayList.removeWhere((element) => element.isAtSameMomentAs(day));
      }
    }

    if (dayList.isEmpty) return;
    if (_animating) return;

    final Map<DateTime, DayBlocks> result;

    if (session != null) {
      result = await widget.updateBlocks(session, days, dayList);
    } else {
      result = await SessionManager.execute(
        context: context,
        callback: (session) async =>
            await widget.updateBlocks(session, days, dayList),
      );
    }

    for (final entry in result.entries) {
      _classes[entry.key]?.value = entry.value;
    }
  }

  Holiday? _getHolidayForDay(DateTime day) {
    return _scheduleDisplayData.holidays.firstWhereOrNull(
      (element) => element.contains(day),
    );
  }

  @override
  void dispose() {
    _pageController?.removeListener(_onPageDrag);
    super.dispose();
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
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
            appBar: _buildAppBar(dayGroup, context),

            body: RefreshIndicator(
              onRefresh: () => reload(fromRefreshIndicator: true),

              child: ValueListenableBuilder(
                valueListenable: _classes[days.first]!,

                builder: (context, _, _) {
                  final allEmpty = days.every(
                    (day) => _classes[day]!.value?.isEmpty ?? false,
                  );

                  final anyLoading = days.any(
                    (day) => _classes[day]!.value == null,
                  );

                  final Widget partialChild;

                  if (anyLoading) {
                    partialChild = const Center(child: LoadingWidget());
                  } else if (allEmpty) {
                    final holiday = _getHolidayForDay(days.first);

                    partialChild = Center(
                      child: Column(
                        mainAxisAlignment: .center,
                        spacing: 6,

                        children: [
                          Icon(
                            holiday == null
                                ? HugeIconsSolid.calendar04
                                : HugeIconsSolid.beach,
                            color: context.c.outline,
                            size: 44,
                          ),

                          Text(
                            holiday?.name ?? context.l10n.noCourseToday,
                            textAlign: .center,
                            style: TextStyle(
                              fontWeight: .bold,
                              color: context.c.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final child = IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: .stretch,
                        spacing: 8,

                        children: days.expand((day) {
                          final hasClasses =
                              _classes[day]!.value?.isNotEmpty ?? false;

                          return [
                            if (hasClasses)
                              Expanded(
                                flex: days.length * 15,
                                child: _buildTimeColumn(context, days),
                              ),

                            Expanded(
                              flex: 85,

                              child: ValueListenableBuilder(
                                valueListenable: _classes[day]!,

                                builder: (context, dayClasses, child) {
                                  if (dayClasses == null) {
                                    return const LoadingWidget();
                                  }

                                  if (dayClasses.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return _buildClassesColumn(
                                    context,
                                    day,
                                    dayClasses,
                                  );
                                },
                              ),
                            ),
                          ];
                        }).toList(),
                      ),
                    );

                    if (widget.scrollable) {
                      partialChild = SingleChildScrollView(
                        padding: .only(
                          bottom: MediaQuery.paddingOf(context).bottom + 20,
                          right: 12,
                        ),

                        child: child,
                      );
                    } else {
                      partialChild = Padding(
                        padding: .only(
                          bottom: MediaQuery.paddingOf(context).bottom + 20,
                          right: 12,
                        ),
                        child: child,
                      );
                    }
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.fastOutSlowIn,
                    switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),
                    child: partialChild,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(DateRange dayGroup, BuildContext context) {
    return AppBar(
      title: TextButton.icon(
        label: Text(
          dayGroup.pprint(context),
          style: const TextStyle(fontWeight: .bold, fontSize: 16),
        ),

        icon: const Icon(HugeIconsSolid.calendar03, size: 22),

        onPressed: () async {
          final selected = await showDatePicker(
            context: context,
            currentDate: dayGroup.start,
            firstDate: _scheduleDisplayData.firstDate,
            lastDate: _scheduleDisplayData.lastDate,
          );

          if (selected == null) return;

          _animateToDay(selected.copyWith(isUtc: true).toDay());
        },
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context, List<DateTime> days) {
    final relevantSlots = <int>{};

    for (final day in days) {
      for (final clazz in _classes[day]!.value ?? <ClassBlock>[]) {
        relevantSlots.add(clazz.startSlot % _scheduleDisplayData.slotsPerDay);
        relevantSlots.add(clazz.endSlot % _scheduleDisplayData.slotsPerDay - 1);
      }
    }

    final relevantFirst = relevantSlots.firstOrNull;
    final relevantLast = relevantSlots.lastOrNull;

    if (relevantLast == null || relevantFirst == null) {
      return const SizedBox.shrink();
    }

    final displays = <Widget>[];
    int? lastAppliedSlot;

    for (int i = relevantFirst; i <= relevantLast; i++) {
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

        if (transitionValue > 0 && displays.isNotEmpty) {
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
                Align(
                  alignment: .topCenter,

                  child: Column(
                    mainAxisSize: .min,
                    spacing: 2,

                    children: [
                      const Divider(height: 0),

                      Text(
                        curSlot.label,

                        style: TextStyle(
                          color: context.c.outline,
                          fontWeight: .w800,
                        ),
                      ),
                    ],
                  ),
                ),

              if (curEndSlot.active)
                Align(
                  alignment: .bottomCenter,

                  child: Column(
                    mainAxisSize: .min,
                    spacing: 2,

                    children: [
                      Text(
                        curEndSlot.label,

                        style: TextStyle(
                          color: context.c.outline,
                          fontWeight: .w800,
                        ),
                      ),

                      const Divider(height: 0),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

      lastAppliedSlot = i;
    }

    return Column(children: displays);
  }

  Widget _buildClassesColumn(
    BuildContext context,
    DateTime day,
    DayBlocks blocks,
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
          child: switch (block) {
            ClassBlock classBlock => ClassBlockWidget(
              displayParameters: _scheduleDisplayData,
              block: classBlock,
              day: day,
            ),
            PauseBlock() => PauseBlockWidget(block: block),
          },
        ),
      );

      curTime = block.endTime;
    }

    return Column(children: displays);
  }

  @override
  List<String> get loadChannels => _animating ? [] : ["communication"];

  @override
  Stream<double?> load(PronoteSession session) async* {
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
      _pageController?.addListener(_onPageDrag);
    }

    await _updateClasses(_currentGroups[currentGroupIndex], session: session);
  }
}
