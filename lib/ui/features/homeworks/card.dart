import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/features/homeworks/details.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/overflow_row.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:antinote_app/ui/widgets/remote_html.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

import 'render_ui.dart';

class HomeworkCard extends StatelessWidget {
  final Homework homework;
  final VoidCallback onReturn;

  const HomeworkCard({
    super.key,
    required this.homework,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);
    final done = homework.isDone;
    final renderIcon = homework.renderIcon;

    final chips = <Widget>[
      if (homework.assignmentToRenderType != .noRender && renderIcon != null)
        _HomeworkChip(
          icon: renderIcon,
          label: homework.renderLabel(context),
          scheme: scheme,
          emphasized: true,
        ),

      if (homework.duration > 0)
        _HomeworkChip(
          icon: HugeIconsSolid.clock01,
          label: Formatters.formatDurationInMinutes(
            Duration(minutes: homework.duration.round()),
          ),
          scheme: scheme,
        ),

      if (homework.difficultyLevel > 0)
        _HomeworkChip(
          icon: HugeIconsSolid.star,
          label: '${homework.difficultyLevel}',
          scheme: scheme,
        ),

      if (homework.attachments.isNotEmpty)
        _HomeworkChip(
          icon: HugeIconsSolid.attachment01,
          label: context.l10n.homeworkAttachmentsCount(
            homework.attachments.length,
          ),
          scheme: scheme,
        ),
    ];

    return Pressable(
      borderRadius: .circular(24),

      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeworkDetailsScreen(
              homework: homework,
              onHomeworkChange: (_) => onReturn(),
            ),
          ),
        );
      },

      child: Ink(
        decoration: BoxDecoration(
          borderRadius: .circular(24),
          color: scheme.primaryContainer,
        ),

        child: Column(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: done ? 0.55 : 1,

              child: Padding(
                padding: const .fromLTRB(14, 12, 14, 12),

                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,

                  children: [
                    Row(
                      spacing: 10,

                      children: [
                        Expanded(
                          child: Text(
                            homework.subject.name ?? context.l10n.noSubject,
                            overflow: .ellipsis,
                            maxLines: 1,
                            style: context.tt.titleLarge?.copyWith(
                              color: scheme.primary,
                              fontWeight: .w800,
                            ),
                          ),
                        ),

                        Text(
                          homework.deadlineDate.asLongNumericDate(),
                          style: context.tt.labelMedium?.copyWith(
                            color: scheme.outline,
                            fontWeight: .bold,
                          ),
                        ),
                      ],
                    ),

                    if (homework.description.trim().isNotEmpty)
                      RemoteHtml(
                        rawHtml: homework.description,
                        compact: true,
                        maxLines: 3,
                        style: context.tt.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: .w600,
                        ),
                      ),

                    if (chips.isNotEmpty)
                      Padding(
                        padding: const .only(top: 6),

                        child: OverflowRow(
                          spacing: 6,

                          badgeStyle: context.tt.labelSmall!.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: .w800,
                          ),
                          badgeDecoration: BoxDecoration(
                            color: scheme.surface.withAlpha(150),
                            borderRadius: .circular(90),
                          ),

                          children: chips,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: scheme.inversePrimary,
            ),

            _MarkDoneButton(
              homework: homework,
              scheme: scheme,
              onReturn: onReturn,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final bool emphasized;

  const _HomeworkChip({
    required this.icon,
    required this.label,
    required this.scheme,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = emphasized
        ? scheme.primary
        : scheme.surface.withAlpha(150);
    final foreground = emphasized
        ? scheme.onPrimary
        : scheme.onPrimaryContainer;
    final iconColor = emphasized ? scheme.onPrimary : scheme.primary;

    return Container(
      padding: const .symmetric(horizontal: 9, vertical: 4),

      decoration: BoxDecoration(color: background, borderRadius: .circular(90)),

      child: Row(
        mainAxisSize: .min,
        spacing: 4,

        children: [
          Icon(icon, color: iconColor, size: 15),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: .ellipsis,
              style: context.tt.labelMedium?.copyWith(
                color: foreground,
                fontWeight: .w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkDoneButton extends StatefulWidget {
  final Homework homework;
  final ColorScheme scheme;
  final VoidCallback onReturn;

  const _MarkDoneButton({
    required this.homework,
    required this.scheme,
    required this.onReturn,
  });

  @override
  State<_MarkDoneButton> createState() => _MarkDoneButtonState();
}

class _MarkDoneButtonState extends State<_MarkDoneButton> {
  bool _isLoading = false;
  bool? _optimisticIsDone;

  bool get _isDone => _optimisticIsDone ?? widget.homework.isDone;

  Color get _color =>
      _isDone ? widget.scheme.onPrimaryContainer : widget.scheme.outline;

  @override
  void didUpdateWidget(covariant _MarkDoneButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.homework.isDone == _optimisticIsDone) {
      _optimisticIsDone = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: const .vertical(bottom: .circular(21)),
      hasScale: false,

      onPressed: _isLoading
          ? null
          : () async {
              final target = !_isDone;

              setState(() {
                _isLoading = true;
                _optimisticIsDone = target;
              });

              if (target) {
                await HapticFeedback.lightImpact();
              } else {
                await HapticFeedback.selectionClick();
              }

              if (!context.mounted) return;

              await context.ar.runTask(
                context: context,

                callback: (session) async {
                  final cachedHomework = session.getCachedValue<Homework>(
                    .HOMEWORK,
                    widget.homework.visualId,
                  );

                  await session.access(
                    ChangeHomeworkStateAccessor(
                      homeworksToUpdate: {cachedHomework: target},
                    ),
                  );
                },
                debugLabel: 'Update state for homework',
              );

              if (mounted) setState(() => _isLoading = false);
              widget.onReturn();
            },

      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 8),

        child: Row(
          spacing: 6,

          children: [
            SizedBox(
              width: 21,
              height: 21,

              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutExpo,
                switchOutCurve: Curves.easeIn,

                transitionBuilder: (child, anim) {
                  return ScaleTransition(scale: anim, child: child);
                },

                child: _isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 16,
                        height: 16,

                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          strokeCap: .round,
                          color: _color,
                        ),
                      )
                    : Icon(
                        _isDone
                            ? HugeIconsSolid.tick03
                            : HugeIconsStroke.tick03,
                        key: ValueKey(_isDone),
                        color: _color,
                        size: 21,
                      ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,

              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,

                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,

                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.1, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),

                      child: child,
                    ),
                  );
                },

                child: Text(
                  _isDone
                      ? context.l10n.homeworkSetDone
                      : context.l10n.homeworkSetNotDone,

                  key: ValueKey(_isDone),
                  style: context.tt.bodyMedium?.copyWith(
                    color: _color,
                    fontWeight: .w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
