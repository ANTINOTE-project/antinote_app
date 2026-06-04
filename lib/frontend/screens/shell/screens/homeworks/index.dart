import "dart:async";
import "dart:math";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/frontend/widgets/remote_html.dart";
import "package:antinote_app/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";

typedef Homeworks = Map<DateTime, ValueNotifier<List<Homework>?>>;

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen>
    with ScreenMixin<HomeworksScreen> {
  late SpecificInstanceParameters _homeworksDisplayData;
  late Map<int, GlobalKey<SliverAnimatedListState>> weeks;
  final Homeworks _homeworks = {};

  PageController? _pageController;

  bool _animating = false;
  int? _lastPage;

  Future<void> animateToWeek(int weekNumber) async {
    final index = weekNumber - _homeworksDisplayData.firstWeekNumber;

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

  Future<void> updateHomeworks(int week, {PronoteSession? session}) async {
    if (_animating) return;

    Future<void> update(PronoteSession session) async {
      await session.ensurePage(88);

      final weekStart = session.instance.getDateForWeekNumber(week);
      final weekEnd = weekStart.add(const Duration(days: 6));
      final days = DateRange(start: weekStart, end: weekEnd).listDays();

      for (final day in days) {
        _homeworks.putIfAbsent(day, () => ValueNotifier([]));
      }

      final pageData = await session.access(
        NotebookPageAccessor(weeks: {week}),
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
          weeks[week - _homeworksDisplayData.firstWeekNumber]?.currentState
              ?.removeItem(days.indexOf(day), (context, animation) {
                return AnimatedScale(
                  alignment: .topCenter,
                  scale: animation.value,
                  duration: const Duration(seconds: 4),
                  curve: Curves.fastOutSlowIn,
                  child: _HomeworkList(day: day, homeworks: const []),
                );
              });
        }
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
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: PageView.builder(
        itemCount: weeks.length,
        controller: _pageController,
        itemBuilder: (context, index) {
          final weekNumber = index + _homeworksDisplayData.firstWeekNumber;

          final weekStart = _homeworksDisplayData.getDateForWeekNumber(
            weekNumber,
          );
          final weekEnd = weekStart.add(const Duration(days: 6));

          final days = DateRange(
            start: weekStart,
            end: DateTime.fromMillisecondsSinceEpoch(
              min(
                _homeworksDisplayData.lastDate.millisecondsSinceEpoch,
                weekEnd.millisecondsSinceEpoch,
              ),
              isUtc: true,
            ),
          ).listDays();

          final displayableDays = days
              .where(
                (element) => _homeworks[element]!.value?.isNotEmpty ?? true,
              )
              .toList(growable: false);

          return Scaffold(
            appBar: AppBar(
              title: _WeekPicker(
                firstWeekNumber: _homeworksDisplayData.firstWeekNumber,
                weekCount: weeks.length,
                curWeekIndex: index,
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => reload(fromRefreshIndicator: true),
              child: CustomScrollView(
                slivers: [
                  SliverAnimatedList(
                    key: weeks[index],
                    itemBuilder: (context, index, animation) {
                      final day = displayableDays[index];
                      return ValueListenableBuilder(
                        valueListenable: _homeworks[day]!,
                        builder: (context, value, child) {
                          return _HomeworkList(day: day, homeworks: value);
                        },
                      );
                    },
                    initialItemCount: displayableDays.length,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              ),
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
    return const Center(child: LoadingWidget());
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    _homeworksDisplayData = session.instance;

    final firstWeekNumber = session.instance.firstWeekNumber;
    final lastWeekNumber = session.instance.getWeekNumberForDate(
      session.instance.lastDate,
    );

    if (!loaded) {
      weeks = {
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

      currentWeekIndex = curWeekNumber - firstWeekNumber;
    } else {
      currentWeekIndex = _pageController!.page!.round();
    }

    if (_pageController == null) {
      for (final day in DateRange(
        start: session.instance.firstDate,
        end: session.instance.lastDate,
      ).listDays()) {
        _homeworks[day] = ValueNotifier(null);
      }

      _pageController = PageController(initialPage: currentWeekIndex);
      _pageController?.addListener(onPageDrag);
    }

    await updateHomeworks(currentWeekIndex + firstWeekNumber, session: session);
  }
}

class _HomeworkList extends StatefulWidget {
  final DateTime day;
  final List<Homework>? homeworks;

  const _HomeworkList({required this.day, required this.homeworks});

  @override
  State<_HomeworkList> createState() => _HomeworkListState();
}

class _HomeworkListState extends State<_HomeworkList> {
  final ExpansibleController controller = ExpansibleController();

  void displayIfNeeded() {
    if (!DateTime.now().copyWith(isUtc: true).toDay().isAfter(widget.day) ||
        (widget.homeworks?.any((element) => !element.isDone) ?? false)) {
      controller.expand();
    }
  }

  @override
  void initState() {
    super.initState();
    displayIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _HomeworkList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homeworks != widget.homeworks) {
      displayIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expansible(
      controller: controller,
      headerBuilder: (context, animation) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Pressable(
            onPressed: widget.homeworks == null ? null : controller.toggle,
            hasVisuals: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.day.asRelativeDate(context),
                  style: TextStyle(
                    color: context.c.outline,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                widget.homeworks == null
                    ? const LoadingWidget(size: 12)
                    : Transform.rotate(
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
        if (widget.homeworks == null) return const SizedBox.shrink();

        return Column(
          children: [
            for (final homework in widget.homeworks!)
              _HomeworkCard(homework: homework),
          ],
        );
      },
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;

  const _HomeworkCard({required this.homework});

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);
    final dateStr = DateFormat("dd/MM/yyyy").format(homework.deadlineDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable(
        borderRadius: BorderRadius.circular(20),
        onPressed: () async {
          await context.push(Routes.homework, extra: {"homework": homework});
        },

        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outline),
            borderRadius: BorderRadius.circular(20),
            color: scheme.primaryContainer,
          ),

          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,

            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,

                children: [
                  Expanded(
                    child: Text(
                      homework.subject.name ?? context.l10n.noSubject,

                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,

                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                      ),
                    ),
                  ),

                  Text(
                    dateStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),

              RemoteHtml(
                rawHtml: homework.description,
                compact: true,
                maxLines: 3,
                style: TextStyle(color: scheme.onSurface, fontSize: 15),
              ),

              const SizedBox(height: 6),

              Row(
                spacing: 6,

                children: [
                  Icon(
                    homework.isDone
                        ? HugeIconsSolid.tick03
                        : HugeIconsStroke.tick03,
                    color: scheme.onPrimaryContainer,
                    size: 21,
                  ),

                  Text(
                    homework.isDone
                        ? context.l10n.homeworkSetDone
                        : context.l10n.homeworkSetNotDone,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
