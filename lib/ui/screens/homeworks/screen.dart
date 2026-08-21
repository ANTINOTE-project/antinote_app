import 'dart:async';
import 'dart:math';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/homeworks/detail.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:antinote_app/ui/widgets/remote_html.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

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

  Future<void> _updateHomeworks(int week, {RemoteSession? session}) async {
    Future<void> update(RemoteSession session) async {
      final weekStart = session.instance.getDateForWeekNumber(week);
      final weekEnd = weekStart.add(const Duration(days: 6)).toDay();
      final days = DateRange(start: weekStart, end: weekEnd).listDays();

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
          _weeks[week - _data.firstWeekNumber]?.currentState?.removeItem(
            days.indexOf(day),
            (context, animation) {
              return AnimatedScale(
                alignment: .topCenter,
                scale: animation.value,

                duration: const Duration(seconds: 4),
                curve: Curves.fastOutSlowIn,

                child: _HomeworkList(
                  day: day,
                  homeworks: const [],
                  onReturn: () {},
                ),
              );
            },
          );
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
          final weekNumber = index + _data.firstWeekNumber;

          final weekStart = _data.getDateForWeekNumber(weekNumber);
          final weekEnd = weekStart.add(const Duration(days: 6));

          final days = DateRange(
            start: weekStart,
            end: DateTime.fromMillisecondsSinceEpoch(
              min(
                _data.lastDate.millisecondsSinceEpoch,
                weekEnd.millisecondsSinceEpoch,
              ),
              isUtc: true,
            ).toDay(),
          ).listDays();

          final bool loaded = days.every(
            (element) => _homeworks[element]!.value != null,
          );

          final displayableDays = days
              .where(
                (element) => _homeworks[element]!.value?.isNotEmpty ?? true,
              )
              .toList(growable: false);

          final Widget child;

          if (!loaded) {
            child = const Center(key: ValueKey(false), child: LoadingWidget());
          } else if (displayableDays.isEmpty) {
            child = Center(
              key: const ValueKey(true),
              child: Text(context.l10n.noHomeworkForWeek),
            );
          } else {
            child = CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const .symmetric(horizontal: 4),
                  sliver: SliverList.builder(
                    itemBuilder: (context, index) {
                      final day = displayableDays[index];
                      final value = _homeworks[day]!.value;

                      if (value == null) {
                        return const SizedBox.shrink();
                      }

                      return _HomeworkList(
                        day: day,
                        homeworks: value,
                        onReturn: () {
                          reload(fromRefreshIndicator: true);
                        },
                      );
                    },
                    itemCount: displayableDays.length,
                  ),
                ),
                const BottomPadding(padding: 20),
              ],
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: _WeekPicker(
                firstWeekNumber: _data.firstWeekNumber,
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

    final firstWeekNumber = session.instance.firstWeekNumber;
    final lastWeekNumber = session.instance.getWeekNumberForDate(
      session.instance.lastDate,
    );

    if (!loaded) {
      _weeks = {
        for (
          int weekIndex = 0;
          weekIndex <= lastWeekNumber - firstWeekNumber;
          weekIndex++
        )
          weekIndex: GlobalKey(),
      };
    }

    final int currentWeekIndex;

    if (_pageController == null ||
        !_pageController!.hasClients ||
        _pageController?.page == null) {
      final curWeekNumber = session.instance.getWeekNumberForDate(.now());

      currentWeekIndex = min(curWeekNumber, lastWeekNumber) - firstWeekNumber;
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

    await _updateHomeworks(
      currentWeekIndex + firstWeekNumber,
      session: session,
    );
  }
}

class _HomeworkList extends StatefulWidget {
  final DateTime day;
  final List<Homework> homeworks;
  final VoidCallback onReturn;

  const _HomeworkList({
    required this.day,
    required this.homeworks,
    required this.onReturn,
  });

  @override
  State<_HomeworkList> createState() => _HomeworkListState();
}

class _HomeworkListState extends State<_HomeworkList> {
  final ExpansibleController controller = ExpansibleController();

  void _displayIfNeeded() {
    if (!DateTime.now().copyWith(isUtc: true).toDay().isAfter(widget.day) ||
        (widget.homeworks.any((element) => !element.isDone))) {
      controller.expand();
    }
  }

  @override
  void initState() {
    super.initState();
    _displayIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _HomeworkList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.homeworks != widget.homeworks) {
      _displayIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expansible(
      controller: controller,

      headerBuilder: (context, animation) {
        return Padding(
          padding: const .symmetric(horizontal: 8, vertical: 6),

          child: Pressable(
            onPressed: controller.toggle,
            hasVisuals: false,

            child: Row(
              mainAxisAlignment: .spaceBetween,

              children: [
                Padding(
                  padding: const .only(left: 2, bottom: 2),

                  child: Text(
                    widget.day.asRelativeDate(context),
                    style: TextStyle(
                      color: context.c.outline,
                      fontWeight: .bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                Transform.rotate(
                  angle: animation.value * pi,
                  child: Icon(
                    HugeIconsSolid.arrowDown01,
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
            spacing: 8,

            children: [
              for (final homework in widget.homeworks)
                _HomeworkCard(homework: homework, onReturn: widget.onReturn),
            ],
          ),
        );
      },
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;
  final VoidCallback onReturn;

  const _HomeworkCard({required this.homework, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);
    final date = homework.deadlineDate.asLongNumericDate();

    return Pressable(
      borderRadius: .circular(12),

      onPressed: () async {
        await Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) {
              return HomeworkDetailScreen(
                homework: homework,
                onHomeworkChange: (_) => onReturn(),
              );
            },
          ),
        );
      },

      child: Ink(
        decoration: BoxDecoration(
          border: .all(color: scheme.inversePrimary),
          borderRadius: .circular(12),
          color: scheme.primaryContainer,
        ),

        padding: const .symmetric(horizontal: 12, vertical: 8),

        child: Column(
          crossAxisAlignment: .start,
          spacing: 6,

          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              spacing: 10,

              children: [
                Expanded(
                  child: Text(
                    homework.subject.name ?? context.l10n.noSubject,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: .w800,
                      fontSize: 21,
                    ),
                  ),
                ),

                Text(
                  date,
                  style: TextStyle(fontWeight: .bold, color: scheme.outline),
                ),
              ],
            ),

            RemoteHtml(
              rawHtml: homework.description,
              compact: true,
              maxLines: 3,

              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: .w600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              spacing: 6,

              children: [
                Icon(
                  homework.isDone
                      ? HugeIconsSolid.tick03
                      : HugeIconsStroke.tick03,
                  color: homework.isDone
                      ? scheme.onPrimaryContainer
                      : scheme.outline,
                  size: 21,
                ),

                Text(
                  homework.isDone
                      ? context.l10n.homeworkSetDone
                      : context.l10n.homeworkSetNotDone,

                  style: TextStyle(
                    color: homework.isDone
                        ? scheme.onPrimaryContainer
                        : scheme.outline,
                    fontWeight: .w800,
                    fontSize: 15.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekPicker extends StatefulWidget {
  final int weekCount;
  final int curWeekIndex;
  final int firstWeekNumber;

  const _WeekPicker({
    required this.weekCount,
    required this.curWeekIndex,
    required this.firstWeekNumber,
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
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,

      children: [
        _DotIndicator(active: canGoBack),

        Text(
          context.l10n.weekNumber(widget.curWeekIndex + widget.firstWeekNumber),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
        shape: BoxShape.circle,
      ),
    );
  }
}
