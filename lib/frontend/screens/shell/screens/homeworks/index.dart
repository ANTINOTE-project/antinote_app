import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/frontend/widgets/remote_html.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:vibration/vibration.dart";

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen>
    with ScreenMixin<HomeworksScreen> {
  List<Homework> _homeworks = [];

  late int _firstWeekNumber;
  late int _lastWeekNumber;

  int? _weekNumber;
  int _weekChangeDirection = 0;

  void _changeWeek(int delta) {
    final current = _weekNumber ?? _firstWeekNumber;
    final clamped = (current + delta).clamp(_firstWeekNumber, _lastWeekNumber);
    if (clamped == current) return;

    setState(() {
      _weekNumber = clamped;
      _weekChangeDirection = delta;
    });

    reload();
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;

          if (v < -300) {
            _changeWeek(1);
          } else if (v > 300) {
            _changeWeek(-1);
          }
        },

        child: CustomScrollView(
          slivers: [
            HomeworksAppBar(
              firstWeekNumber: _firstWeekNumber,
              lastWeekNumber: _lastWeekNumber,

              weekNumber: _weekNumber ?? _firstWeekNumber,
              weekChangeDirection: _weekChangeDirection,

              setWeekNumber: (wn) {
                final current = _weekNumber ?? _firstWeekNumber;
                final clamped = wn.clamp(_firstWeekNumber, _lastWeekNumber);

                setState(() {
                  _weekNumber = clamped;
                  _weekChangeDirection = (clamped - current).sign;
                });

                reload();
              },
            ),

            SliverList.builder(
              itemCount: _homeworks.length,

              itemBuilder: (context, index) {
                final homework = _homeworks[index];

                final colors = AdaptedColors.fromScheme(
                  homework.backgroundColor,
                  context.c,
                );

                final date = DateFormat(
                  "dd/MM/yyyy",
                ).format(homework.deadlineDate);

                final title = RemoteHtml(rawHtml: homework.description);

                return Padding(
                  padding: const .only(bottom: 8, left: 12, right: 12),

                  child: Pressable(
                    borderRadius: .circular(20),

                    child: Ink(
                      decoration: BoxDecoration(
                        border: .all(color: colors.border),
                        borderRadius: .circular(20),
                        color: colors.background,
                      ),

                      padding: const .symmetric(horizontal: 12, vertical: 8),

                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: .start,
                                mainAxisSize: .min,

                                children: [
                                  Text(
                                    homework.subject.name ??
                                        context.l10n.noSubject,

                                    overflow: .ellipsis,
                                    maxLines: 1,

                                    style: TextStyle(
                                      color: colors.base,
                                      fontWeight: .w800,
                                      fontSize: 21,
                                    ),
                                  ),

                                  DefaultTextStyle(
                                    style: TextStyle(
                                      color: colors.text,
                                      fontWeight: .bold,
                                      fontSize: 15,
                                    ),

                                    overflow: .ellipsis,
                                    maxLines: 3,

                                    child: title,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Column(
                              mainAxisAlignment: .spaceBetween,
                              crossAxisAlignment: .end,

                              children: [
                                Text(
                                  homework.isDone
                                      ? context.l10n.homeworkDone
                                      : context.l10n.homeworkNotDone,
                                  style: TextStyle(
                                    fontWeight: .w600,
                                    color: context.c.outline,
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  date,
                                  style: TextStyle(
                                    fontWeight: .w600,
                                    color: context.c.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget()));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(88);

    _firstWeekNumber = session.instance.firstWeekNumber;
    _lastWeekNumber = session.instance.getWeekNumberForDate(
      session.instance.lastDate,
    );

    _weekNumber ??= session.instance.getWeekNumberForDate(.now());

    final page = await session.access(
      NotebookPageAccessor(weeks: {_weekNumber ?? _firstWeekNumber}),
    );

    _homeworks = page.homeworkSet?.homeworks ?? []
      ..sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));
  }
}

class HomeworksAppBar extends StatelessWidget {
  final void Function(int wn) setWeekNumber;
  final int weekNumber;
  final int weekChangeDirection;

  final int firstWeekNumber;
  final int lastWeekNumber;

  const HomeworksAppBar({
    super.key,

    required this.setWeekNumber,
    required this.weekNumber,
    required this.weekChangeDirection,

    required this.firstWeekNumber,
    required this.lastWeekNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,

      title: _WeekPicker(
        weekNumber: weekNumber,
        weekChangeDirection: weekChangeDirection,
        firstWeekNumber: firstWeekNumber,
        lastWeekNumber: lastWeekNumber,
        setWeekNumber: setWeekNumber,
      ),
    );
  }
}

class _WeekPicker extends StatefulWidget {
  final void Function(int) setWeekNumber;
  final int weekNumber;
  final int weekChangeDirection;

  final int firstWeekNumber;
  final int lastWeekNumber;

  const _WeekPicker({
    required this.setWeekNumber,
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

  void _change(int delta) {
    final next = widget.weekNumber + delta;
    if (next < widget.firstWeekNumber || next > widget.lastWeekNumber) return;

    widget.setWeekNumber(next);
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;

        if (v < -300) {
          _change(1);
        } else if (v > 300) {
          _change(-1);
        }
      },

      child: Row(
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
      ),
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
