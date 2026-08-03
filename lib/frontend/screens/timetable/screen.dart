import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/frontend/screens/shell/tab.dart';
import 'package:antinote_app/frontend/screens/timetable/events/block.dart';
import 'package:antinote_app/frontend/utils/utils.dart';
import 'package:antinote_app/frontend/widgets/customs/loading.dart';
import 'package:antinote_app/main.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

typedef RelevantSlots = ({int firstSlot, int lastSlot});
typedef Classes = Map<DateTime, ValueNotifier<DayBlocks?>>;

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Future<Map<DateTime, DayBlocks>> update(
    RemoteSession session,
    DateRange days,
    List<DateTime> dayList,
  ) async {
    final loadedDays = {for (final day in dayList) day: <Class>[]};

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
      (key, value) => MapEntry(
        key,
        blocksForDay(eventsForDay(value, session.instance), session.instance),
      ),
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
    RemoteSession session,
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
  late WeekMappedViewConfiguration _currentConfiguration;
  late List<DateRange> _currentGroups;
  final Classes _blocks = {};

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

  Future<void> _updateClasses(DateRange days, {RemoteSession? session}) async {
    final dayList = days.listDays();

    for (final day in days.listDays()) {
      if (!_scheduleDisplayData.isBusinessDay(day)) {
        _blocks[day]!.value = [];

        dayList.removeWhere((element) => element.isAtSameMomentAs(day));
      }
    }

    if (dayList.isEmpty) return;
    if (_animating) return;

    late final Map<DateTime, DayBlocks> result;

    try {
      if (session != null) {
        result = await widget.updateBlocks(session, days, dayList);
      } else {
        result = await context.sm.runTask(
          context: context,
          callback: (session) async =>
              await widget.updateBlocks(session, days, dayList),
          debugLabel: 'Fetch classes for ${days.toString()}',
        );
      }
    } catch (e, st) {
      result = {};
      debugPrintStack(label: e.toString(), stackTrace: st);
    }

    for (final entry in result.entries) {
      _blocks[entry.key]?.value = entry.value;
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
    ensureCorrectConfiguration();

    return buildRefreshIndicator(
      child: PageView.builder(
        itemCount: _currentGroups.length,
        controller: _pageController,

        itemBuilder: (context, index) {
          final dayGroup = _currentGroups[index];
          final days = dayGroup.listDays();

          final slots = findRelevantSlots(days);

          return Scaffold(
            appBar: _buildAppBar(dayGroup, context),

            body: RefreshIndicator(
              onRefresh: () => reload(fromRefreshIndicator: true),

              child: ValueListenableBuilder(
                valueListenable: _blocks[days.first]!,

                builder: (context, _, _) {
                  final allEmpty = days.every(
                    (day) => _blocks[day]!.value?.isEmpty ?? false,
                  );

                  final anyLoading = days.any(
                    (day) => _blocks[day]!.value == null,
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
                        spacing: 8,
                        children: [
                          if (slots != null)
                            Flexible(
                              flex: days.length * 15,
                              child: _buildTimeColumn(context, slots, days),
                            ),

                          for (final day in days)
                            Expanded(
                              flex: 85,
                              child: ValueListenableBuilder(
                                valueListenable: _blocks[day]!,
                                builder: (context, dayClasses, child) {
                                  if (dayClasses == null) {
                                    return const LoadingWidget();
                                  }
                                  if (dayClasses.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return _buildEventsColumn(
                                    context,
                                    day,
                                    slots!, // TODO: Find if this is a safe cast.
                                    dayClasses,
                                  );
                                },
                              ),
                            ),
                        ],
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

  RelevantSlots? findRelevantSlots(List<DateTime> days) {
    final relevantSlots = <int>{};

    for (final day in days) {
      for (final block in _blocks[day]!.value ?? <Block>[]) {
        relevantSlots.add(block.startSlot % _scheduleDisplayData.slotsPerDay);
        relevantSlots.add(block.endSlot % _scheduleDisplayData.slotsPerDay - 1);
      }
    }

    if (relevantSlots.isEmpty) return null;

    final sortedSlots = relevantSlots.sorted((a, b) => a.compareTo(b));
    return (firstSlot: sortedSlots.first, lastSlot: sortedSlots.last);
  }

  Widget _buildTimeColumn(
    BuildContext context,
    RelevantSlots slots,
    List<DateTime> days,
  ) {
    final relevantFirst = slots.firstSlot;
    final relevantLast = slots.lastSlot;

    final displays = <Widget>[];
    int? lastAppliedSlot;

    final borderSide = BorderSide(color: context.c.outlineVariant);

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

        talker.info('${from.timing} -> ${to.timing} : $value');
        displays.add(Expanded(flex: value, child: const SizedBox.shrink()));
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
            Expanded(flex: transitionValue, child: const SizedBox.shrink()),
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
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: curSlot.active ? borderSide : .none,
                bottom: curEndSlot.active ? borderSide : .none,
              ),
            ),
            padding: const .symmetric(horizontal: 5),
            child: Column(
              children: [
                if (curSlot.active)
                  Text(
                    curSlot.label,
                    maxLines: 1,
                    textAlign: .center,
                    style: TextStyle(
                      color: context.c.outline,
                      fontWeight: .w800,
                      overflow: .visible,
                    ),
                  ),

                const Spacer(),

                if (curEndSlot.active)
                  Text(
                    curEndSlot.label,
                    maxLines: 1,
                    textAlign: .center,
                    style: TextStyle(
                      color: context.c.outline,
                      fontWeight: .w800,
                      overflow: .visible,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      lastAppliedSlot = i;
    }

    return Column(children: displays);
  }

  Widget _buildEventsColumn(
    BuildContext context,
    DateTime day,
    RelevantSlots slots,
    DayBlocks blocks,
  ) {
    final displays = <Widget>[];
    DateTime curTime = _scheduleDisplayData.timeForSlot(
      _scheduleDisplayData.starts[slots.firstSlot],
      day,
    );

    for (final block in blocks) {
      if (!curTime.isAtSameMomentAs(block.startTime)) {
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
          child: BlockWidget(block: block),
        ),
      );

      curTime = block.endTime;
    }

    final endTime = _scheduleDisplayData.timeForSlot(
      _scheduleDisplayData.endings[slots.lastSlot],
      day,
    );

    if (!endTime.isAtSameMomentAs(curTime)) {
      displays.add(
        Expanded(
          flex: endTime.difference(curTime).inMinutes,
          child: const SizedBox.expand(),
        ),
      );
    }

    return Column(children: displays);
  }

  @override
  List<String> get loadChannels => _animating ? [] : ['communication'];

  int ensureCorrectConfiguration() {
    final days = DateRange(
      start: _scheduleDisplayData.firstDate,
      end: _scheduleDisplayData.lastDate,
    ).listDays();

    final daysConfiguration = widget.configurations.pickConfig(context);
    final newGroups = daysConfiguration.daysToRangeList(
      days,
      _scheduleDisplayData,
    );

    int currentGroupIndex;

    if (_pageController == null ||
        !_pageController!.hasClients ||
        _pageController?.page == null) {
      _currentConfiguration = daysConfiguration;
      _currentGroups = newGroups;

      currentGroupIndex = _currentGroups.indexWhere((element) {
        return element.contains(_scheduleDisplayData.nextBusinessDay);
      });

      if (currentGroupIndex == -1) {
        if (DateTime.now()
            .copyWith(isUtc: true)
            .isBefore(_scheduleDisplayData.firstDate)) {
          currentGroupIndex = 0;
        } else {
          currentGroupIndex = _currentGroups.length - 1;
        }
      }
    } else {
      currentGroupIndex = _pageController!.page!.round();
    }

    if (daysConfiguration != _currentConfiguration) {
      final oldFocusedDays = _currentGroups[currentGroupIndex].listDays();
      final votes = <int, int>{};
      int? bestIndex;
      int bestVoteCount = 1;
      for (final oldDay in oldFocusedDays) {
        // Binary search is kinda redundant.
        // TODO Change it to a 2-phase binary search then a nudge for every other day.
        var min = 0;
        var max = newGroups.length;
        while (min < max) {
          var mid = min + ((max - min) >> 1);
          var element = newGroups[mid];
          if (element.contains(oldDay)) {
            if (votes.isEmpty) {
              bestIndex = mid;
            }

            votes[mid] = (votes[mid] ?? 0) + 1;

            break;
          } else if (oldDay.isAfter(element.end)) {
            min = mid + 1;
          } else {
            max = mid;
          }
        }
      }

      for (final MapEntry(key: index, value: voteCount) in votes.entries) {
        if (bestIndex == null || bestVoteCount < voteCount) {
          bestIndex = index;
          bestVoteCount = voteCount;
        }
      }

      currentGroupIndex = bestIndex ?? newGroups.length - 1;

      if (_pageController != null && _pageController!.hasClients) {
        _pageController!.jumpToPage(currentGroupIndex);
      }
    }

    _currentConfiguration = daysConfiguration;
    _currentGroups = newGroups;

    if (_pageController == null) {
      for (final day in days) {
        _blocks[day] = ValueNotifier(null);
      }

      _pageController = PageController(initialPage: currentGroupIndex);
      _pageController?.addListener(_onPageDrag);
    }

    return currentGroupIndex;
  }

  @override
  Stream<double?> load(RemoteSession session) async* {
    _scheduleDisplayData = session.instance;

    final currentGroupIndex = ensureCorrectConfiguration();

    await _updateClasses(_currentGroups[currentGroupIndex], session: session);
  }
}
