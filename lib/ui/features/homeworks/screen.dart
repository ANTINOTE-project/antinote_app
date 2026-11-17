// ignore_for_file: unused_import

import 'dart:async';
import 'dart:math';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/features/homeworks/details.dart';
import 'package:antinote_app/ui/features/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/loading.dart';
import 'package:antinote_app/ui/widgets/overflow_row.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:antinote_app/ui/widgets/remote_html.dart';
import 'package:collection/collection.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'render_ui.dart';
import 'urgency.dart';

typedef Homeworks = Map<DateTime, ValueNotifier<List<Homework>?>>;

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen>
    with PageMixin<HomeworksScreen>, TabMixin<HomeworksScreen> {
  late Map<int, GlobalKey<SliverAnimatedListState>> _weeks;
  late SpecificInstanceParameters _data;
  final Homeworks _homeworks = {};

  PageController? _pageController;
  int? _lastPage;

  void _onPageDrag() {
    final curPage = _pageController?.page?.round();
    if (curPage == null) return;

    _lastPage ??= curPage;

    if (_lastPage != curPage) {
      _lastPage = curPage;

      reload();
    }
  }

  Future<void> _updateHomeworks(int weekIndex, {RemoteSession? session}) async {
    Future<void> update(RemoteSession session) async {
      final weekStart = session.instance.firstMonday
          .add(Duration(days: 7 * weekIndex))
          .toDay();
      final weekEnd = weekStart.add(const Duration(days: 6)).toDay();
      final days = DateRange(start: weekStart, end: weekEnd).listDays();

      final week = session.instance.getWeekNumberForDate(
        weekStart,
        forceRelativeToSchoolYear: true,
      );

      for (final day in days) {
        _homeworks.putIfAbsent(day, () => ValueNotifier([]));
      }

      final pageData = await session.access(
        NotebookPageAccessor(section: .homework, weeks: {week}),
      );

      final triaged = {for (final day in days) day: <Homework>[]};

      for (final homework in pageData.homeworkSet?.homeworks ?? <Homework>[]) {
        triaged[homework.deadlineDate]!.add(homework);
      }

      for (final day in triaged.keys.sorted((a, b) => b.compareTo(a))) {
        final newHomeworks = triaged[day]!.toList(growable: false);
        final oldHomeworks = _homeworks[day]?.value;
        _homeworks[day]!.value = newHomeworks;

        if (newHomeworks.isEmpty && (oldHomeworks?.isNotEmpty ?? true)) {
          _weeks[weekIndex]?.currentState?.removeItem(days.indexOf(day), (
            context,
            animation,
          ) {
            return AnimatedScale(
              alignment: .topCenter,
              scale: animation.value,
              duration: const Duration(seconds: 4),
              curve: Curves.fastOutSlowIn,
              child: _Day(day: day, homeworks: const [], onReturn: () {}),
            );
          });
        }
      }
    }

    if (session != null) {
      await update(session);
    } else {
      await context.ar.runTask(
        context: context,
        callback: update,
        debugLabel: 'Fetch new homeworks',
      );
    }
  }

  @override
  void dispose() {
    _pageController?.removeListener(_onPageDrag);
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    return buildRefreshIndicator(
      child: PageView.builder(
        itemCount: _weeks.length,
        controller: _pageController,

        itemBuilder: (context, index) {
          final weekStart = _data.firstMonday
              .add(Duration(days: 7 * index))
              .toDay();
          final weekNumber = _data.getWeekNumberForDate(
            weekStart,
            forceRelativeToSchoolYear: true,
          );

          final rawWeekEnd = weekStart.add(const Duration(days: 6));
          final weekEnd = DateTime.fromMillisecondsSinceEpoch(
            min(
              _data.lastDate.millisecondsSinceEpoch,
              rawWeekEnd.millisecondsSinceEpoch,
            ),
            isUtc: true,
          ).toDay();

          final days = DateRange(start: weekStart, end: weekEnd).listDays();

          final loaded = days.every(
            (element) => _homeworks[element]?.value != null,
          );

          final displayableDays = days
              .where(
                (element) =>
                    _homeworks[element]!.value?.isNotEmpty ?? true, // TODO: Fix
              )
              .toList(growable: false);

          final Widget child;

          if (!loaded) {
            // loading state
            child = const Center(key: ValueKey(false), child: LoadingWidget());

            // empty state
          } else if (displayableDays.isEmpty) {
            child = Center(
              key: const ValueKey(true),
              child: Column(
                mainAxisAlignment: .center,
                spacing: 6,

                children: [
                  Icon(HugeIconsSolid.work, color: context.c.outline, size: 44),

                  Text(
                    context.l10n.noHomeworkForWeek,
                    style: TextStyle(
                      color: context.c.outline,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
            );

            // loaded state
          } else {
            child = CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const .symmetric(horizontal: 4),

                  sliver: SliverList.builder(
                    itemCount: displayableDays.length,

                    itemBuilder: (context, index) {
                      final day = displayableDays[index];
                      final value = _homeworks[day]!.value;

                      if (value == null) {
                        return const SizedBox.shrink();
                      }

                      return _Day(
                        day: day,
                        homeworks: value,
                        onReturn: () {
                          reload(fromRefreshIndicator: true);
                        },
                      );
                    },
                  ),
                ),

                const BottomPadding(padding: 20),
              ],
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: _WeekPicker(
                weekNumber: weekNumber,
                weekCount: _weeks.length,
                curWeekIndex: index,
              ),
            ),

            body: RefreshIndicator(
              onRefresh: () => reload(fromRefreshIndicator: true),

              child: AnimatedSwitcher(
                switchInCurve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 300),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Future<void> load(RemoteSession session) async {
    _data = session.instance;

    final weekCount =
        ((session.instance.lastDate.millisecondsSinceEpoch -
                session.instance.firstMonday.millisecondsSinceEpoch) ~/
            (Duration.millisecondsPerSecond *
                Duration.secondsPerMinute *
                Duration.minutesPerHour *
                Duration.hoursPerDay *
                7)) +
        1;

    if (!loaded) {
      _weeks = {
        for (int weekIndex = 0; weekIndex < weekCount; weekIndex++)
          weekIndex: GlobalKey(),
      };
    }

    final int currentWeekIndex;

    if (_pageController == null ||
        !_pageController!.hasClients ||
        _pageController?.page == null) {
      final now =
          session.instance.demoDateTime ??
          session.instance.findBusinessDay(
            DateTime.now().toDay(true),
            const .new(days: 1),
          );
      final diffWeeks =
          ((now.millisecondsSinceEpoch -
                  session.instance.firstMonday.millisecondsSinceEpoch) ~/
              (Duration.millisecondsPerSecond *
                  Duration.secondsPerMinute *
                  Duration.minutesPerHour *
                  Duration.hoursPerDay)) ~/
          7;
      currentWeekIndex = diffWeeks.clamp(0, weekCount - 1);
    } else {
      currentWeekIndex = _pageController!.page!.round();
    }

    if (_pageController == null) {
      for (final day in DateRange(
        start: session.instance.firstDate.toDay(),
        end: session.instance.lastDate.toDay(),
      ).listDays()) {
        _homeworks[day] = ValueNotifier(null);
      }

      _pageController = PageController(initialPage: currentWeekIndex);
      _pageController?.addListener(_onPageDrag);
    }

    await _updateHomeworks(currentWeekIndex, session: session);
  }
}

class _Day extends StatefulWidget {
  final DateTime day;
  final List<Homework> homeworks;
  final VoidCallback onReturn;

  const _Day({
    required this.day,
    required this.homeworks,
    required this.onReturn,
  });

  @override
  State<_Day> createState() => _DayState();
}

class _DayState extends State<_Day> with AutomaticKeepAliveClientMixin {
  final ExpansibleController controller = ExpansibleController();

  @override
  bool get wantKeepAlive => needToDisplay == controller.isExpanded;

  bool get needToDisplay =>
      !DateTime.now().copyWith(isUtc: true).toDay().isAfter(widget.day) ||
      (widget.homeworks.any((element) => !element.isDone));

  double get progress =>
      widget.homeworks.where((element) => element.isDone).length /
      widget.homeworks.length;

  bool get isUrgent => widget.homeworks.any((h) => h.urgency != .none);

  void _displayIfNeeded() {
    if (needToDisplay) {
      controller.expand();
    }
  }

  @override
  void initState() {
    super.initState();
    _displayIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _Day oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.homeworks != widget.homeworks) {
      _displayIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Expansible(
      controller: controller,

      headerBuilder: (context, animation) {
        return Padding(
          padding: const .only(left: 12, right: 8, top: 6, bottom: 8),

          child: Pressable(
            onPressed: controller.toggle,
            hasVisuals: false,

            child: Row(
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,

                    builder: (context, value, _) {
                      final color = isUrgent
                          ? context.c.error
                          : Color.lerp(
                              context.c.outline,
                              context.c.primary,
                              value,
                            );

                      return Row(
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,

                            child: CircularProgressIndicator(
                              color: color,
                              backgroundColor: context.c.outlineVariant,
                              value: value,
                              strokeWidth: 4,
                              strokeCap: .round,
                            ),
                          ),

                          const SizedBox(width: 12),

                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            alignment: .centerLeft,

                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              switchInCurve: Curves.easeOutExpo,
                              switchOutCurve: Curves.easeIn,

                              transitionBuilder: (child, anim) {
                                return ScaleTransition(
                                  scale: anim,
                                  child: child,
                                );
                              },

                              child: isUrgent
                                  ? Padding(
                                      key: const ValueKey('urgent'),
                                      padding: const .only(right: 6),
                                      child: Icon(
                                        HugeIconsSolid.alert02,
                                        color: color,
                                        size: 18,
                                      ),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('none'),
                                    ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              widget.day.asRelativeDate(context),
                              style: TextStyle(
                                color: color,
                                fontWeight: .bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutExpo,
                  switchOutCurve: Curves.easeIn,

                  transitionBuilder: (child, anim) {
                    return ScaleTransition(scale: anim, child: child);
                  },

                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: .center,
                      children: [...previousChildren, ?currentChild],
                    );
                  },

                  child: Icon(
                    animation.value > 0.5
                        ? HugeIconsSolid.arrowUp01
                        : HugeIconsSolid.arrowDown01,
                    key: ValueKey(animation.value > 0.5),
                    color: context.c.outline,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        );
      },

      bodyBuilder: (BuildContext context, Animation<double> animation) {
        return Padding(
          padding: const .fromLTRB(8, 0, 8, 16),

          child: Column(
            spacing: 6,

            children: [
              for (final homework in widget.homeworks)
                HomeworkCard(homework: homework, onReturn: widget.onReturn),
            ],
          ),
        );
      },
    );
  }
}

class _WeekPicker extends StatefulWidget {
  final int weekCount;
  final int curWeekIndex;
  final int weekNumber;

  const _WeekPicker({
    required this.weekCount,
    required this.curWeekIndex,
    required this.weekNumber,
  });

  @override
  State<_WeekPicker> createState() => _WeekPickerState();
}

class _WeekPickerState extends State<_WeekPicker>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final canGoBack = widget.curWeekIndex > 0;
    final canGoForward = widget.curWeekIndex < widget.weekCount - 1;

    return Row(
      mainAxisAlignment: .center,
      spacing: 8,

      children: [
        _DotIndicator(active: canGoBack),

        Text(
          context.l10n.weekNumber(widget.weekNumber),
          style: const TextStyle(fontWeight: .bold, fontSize: 18),
        ),

        _DotIndicator(active: canGoForward),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool active;

  const _DotIndicator({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),

      width: 7,
      height: 7,

      decoration: BoxDecoration(
        color: active ? context.c.onSurface : context.c.outlineVariant,
        shape: .circle,
      ),
    );
  }
}
