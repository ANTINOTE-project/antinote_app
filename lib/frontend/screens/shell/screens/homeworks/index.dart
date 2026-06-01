import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/html_text.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";
import "package:vibration/vibration.dart";

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen>
    with ScreenMixin<HomeworksScreen> {
  final Map<int, Map<DateTime, List<Homework>>> _weeks = {};

  late int _firstWeekNumber;
  late int _lastWeekNumber;

  int? _weekNumber;
  int _weekChangeDirection = 0;

  PageController? _pageController;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    if (_pageController == null) {
      return const Center(child: LoadingWidget());
    }

    final currentWeek = _weekNumber ?? _firstWeekNumber;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const .fromHeight(kToolbarHeight),

        child: _HomeworksAppBar(
          firstWeekNumber: _firstWeekNumber,
          lastWeekNumber: _lastWeekNumber,

          weekNumber: currentWeek,
          weekChangeDirection: _weekChangeDirection,
        ),
      ),

      body: buildRefreshIndicator(
        child: RefreshIndicator(
          onRefresh: () => reload(fromRefreshIndicator: true),

          child: PageView.builder(
            itemCount: _lastWeekNumber - _firstWeekNumber + 1,
            controller: _pageController,

            onPageChanged: (index) {
              final targetWeek = _firstWeekNumber + index;
              if (targetWeek == _weekNumber) return;

              final sign = (targetWeek - (_weekNumber ?? targetWeek)).sign;

              setState(() {
                _weekChangeDirection = sign;
                _weekNumber = targetWeek;
              });

              reload();
            },

            itemBuilder: (context, index) {
              final week = _firstWeekNumber + index;
              final homeworks = _weeks[week];

              if (homeworks == null) {
                return const Center(child: LoadingWidget());
              }

              return CustomScrollView(
                slivers: [
                  _HomeworkList(organizedHomeworks: homeworks),

                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
    await session.ensurePage(88);

    _firstWeekNumber = session.instance.firstWeekNumber;
    _lastWeekNumber = session.instance.getWeekNumberForDate(
      session.instance.lastDate,
    );

    _weekNumber ??= session.instance.getWeekNumberForDate(.now());
    _pageController ??= PageController(
      initialPage: (_weekNumber ?? _firstWeekNumber) - _firstWeekNumber,
    );

    final week = _weekNumber!;
    if (_weeks.containsKey(week)) return;

    final page = await session.access(NotebookPageAccessor(weeks: {week}));

    final homeworks = page.homeworkSet?.homeworks ?? []
      ..sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));

    final organized = <DateTime, List<Homework>>{};

    for (final homework in homeworks) {
      organized.putIfAbsent(homework.deadlineDate, () => []);
      organized[homework.deadlineDate]!.add(homework);
    }

    _weeks[week] = organized;
  }
}

class _HomeworkList extends StatelessWidget {
  final Map<DateTime, List<Homework>> organizedHomeworks;

  const _HomeworkList({required this.organizedHomeworks});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const .only(left: 12, right: 12),

      sliver: SliverList.builder(
        itemCount: organizedHomeworks.length,

        itemBuilder: (context, index) {
          final date = organizedHomeworks.keys.elementAt(index);
          final homeworksForSubject = organizedHomeworks[date]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),

            child: Column(
              spacing: 12,

              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),

                  child: Pressable(
                    hasVisuals: false,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          date.asRelativeDate(context),

                          style: TextStyle(
                            color: context.c.outline,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        Icon(
                          HugeIconsSolid.arrowDown01,
                          color: context.c.outline,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),

                Column(
                  children: homeworksForSubject.mapL(
                    (homework) => _HomeworkCard(homework: homework),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;

  const _HomeworkCard({required this.homework});

  @override
  Widget build(BuildContext context) {
    final colors = AdaptedColors.fromScheme(
      homework.backgroundColor,
      context.c,
    );

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
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(20),
            color: colors.background,
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
                        color: colors.base,
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                      ),
                    ),
                  ),

                  Text(
                    dateStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.subtitle,
                    ),
                  ),
                ],
              ),

              HtmlText(
                rawHtml: homework.description,
                collapseLineBreaks: true,

                overflow: TextOverflow.ellipsis,
                maxLines: 3,

                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
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
                    color: colors.border,
                    size: 21,
                  ),

                  Text(
                    homework.isDone
                        ? context.l10n.homeworkSetDone
                        : context.l10n.homeworkSetNotDone,
                    style: TextStyle(
                      color: colors.border,
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

class _HomeworksAppBar extends StatelessWidget {
  final int weekNumber;
  final int weekChangeDirection;
  final int firstWeekNumber;
  final int lastWeekNumber;

  const _HomeworksAppBar({
    required this.weekNumber,
    required this.weekChangeDirection,
    required this.firstWeekNumber,
    required this.lastWeekNumber,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _WeekPicker(
        weekNumber: weekNumber,
        weekChangeDirection: weekChangeDirection,
        firstWeekNumber: firstWeekNumber,
        lastWeekNumber: lastWeekNumber,
      ),
    );
  }
}

class _WeekPicker extends StatefulWidget {
  final int weekNumber;
  final int weekChangeDirection;

  final int firstWeekNumber;
  final int lastWeekNumber;

  const _WeekPicker({
    required this.weekNumber,
    required this.weekChangeDirection,
    required this.firstWeekNumber,
    required this.lastWeekNumber,
  });

  @override
  State<_WeekPicker> createState() => _WeekPickerState();
}

class _WeekPickerState extends State<_WeekPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  int _direction = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _buildAnimations();
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(_WeekPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.weekNumber != widget.weekNumber) {
      _direction = widget.weekChangeDirection;

      _buildAnimations();

      _controller.forward(from: 0);

      _vibrate();
    }
  }

  void _buildAnimations() {
    _slideAnim = Tween<double>(
      begin: 30.0 * _direction,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 30, amplitude: 80);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = widget.weekNumber > widget.firstWeekNumber;
    final canGoForward = widget.weekNumber < widget.lastWeekNumber;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,

      children: [
        _DotIndicator(active: canGoBack),

        AnimatedBuilder(
          animation: _controller,

          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_slideAnim.value, 0),

              child: Opacity(
                opacity: _fadeAnim.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },

          child: Text(
            context.l10n.weekNumber(widget.weekNumber),
            key: ValueKey(widget.weekNumber),

            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
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
