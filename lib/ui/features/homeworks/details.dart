import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/animated_icon.dart';
import 'package:antinote_app/ui/widgets/app_bar.dart';
import 'package:antinote_app/ui/widgets/attachment.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/list.dart';
import 'package:antinote_app/ui/widgets/remote_html.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class HomeworkDetailsScreen extends StatelessWidget {
  final void Function(bool value) onHomeworkChange;
  final Homework homework;

  const HomeworkDetailsScreen({
    super.key,
    required this.homework,
    required this.onHomeworkChange,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);

    return Scaffold(
      appBar: AppBarWidget(
        title: Text(
          homework.subject.name ?? context.l10n.noSubject,
          style: TextStyle(color: scheme.primary, fontWeight: .w800),
        ),

        subtitle: Text(
          context.l10n.givenTheForThe(
            homework.givenDate,
            homework.deadlineDate,
          ),
        ),
      ),

      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),

        slivers: [
          SliverPadding(
            padding: const .symmetric(horizontal: 12),

            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: _HomeworkStateSection(
                    homework: homework,
                    scheme: scheme,
                    onHomeworkChange: onHomeworkChange,
                  ),
                ),

                if (homework.description.trim().isNotEmpty) ...[
                  const SliverPadding(padding: .only(top: 16)),
                  TextIcon.sliver(label: context.l10n.homeworkDescription),

                  SliverToBoxAdapter(
                    child: TileWidget(
                      backgroundColor: scheme.surfaceContainer,
                      borderRadius: const .all(ListWidget.radius),

                      title: SelectableRegion(
                        selectionControls: materialTextSelectionControls,
                        child: RemoteHtml(
                          rawHtml: homework.description,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: .w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                if (homework.assignmentToRenderType != .noRender) ...[
                  const SliverPadding(padding: .only(top: 16)),
                  TextIcon.sliver(label: context.l10n.homeworkRenderLabel),

                  _HomeworkRenderSection(homework: homework, scheme: scheme),
                ],

                if (homework.duration > 0 || homework.difficultyLevel > 0) ...[
                  const SliverPadding(padding: .only(top: 16)),
                  TextIcon.sliver(label: context.l10n.homeworkDifficulty),

                  _HomeworkDifficultySection(
                    homework: homework,
                    scheme: scheme,
                  ),
                ],

                if (homework.attachments.isNotEmpty) ...[
                  const SliverPadding(padding: .only(top: 16)),
                  TextIcon.sliver(label: context.l10n.homeworkAttachments),

                  ListWidget(
                    items: homework.attachments,

                    itemBuilder: (context, attachment, borderRadius) {
                      return AttachmentItemWidget(
                        attachment: attachment,
                        borderRadius: borderRadius,
                        backgroundColor: scheme.surfaceContainer,
                      );
                    },
                  ),
                ],

                const BottomPadding(padding: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkStateSection extends StatefulWidget {
  final Homework homework;
  final ColorScheme scheme;
  final void Function(bool value) onHomeworkChange;

  const _HomeworkStateSection({
    required this.homework,
    required this.scheme,
    required this.onHomeworkChange,
  });

  @override
  State<_HomeworkStateSection> createState() => _HomeworkStateSectionState();
}

class _HomeworkStateSectionState extends State<_HomeworkStateSection> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.homework.isDone;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final homework = widget.homework;

    return TileWidget(
      backgroundColor: scheme.primaryContainer,
      borderRadius: const .all(ListWidget.radius),

      onPressed: () async {
        setState(() {
          _isDone = !_isDone;
        });

        await context.ar.runTask(
          context: context,

          callback: (session) async {
            final cachedHomework = session.getCachedValue<Homework>(
              .HOMEWORK,
              homework.visualId,
            );

            await session.access(
              ChangeHomeworkStateAccessor(
                homeworksToUpdate: {cachedHomework: _isDone},
              ),
            );
          },
          debugLabel: 'Update state for homework',
        );

        widget.onHomeworkChange.call(_isDone);
      },

      leading: AnimatedIconWidget(
        iconOn: HugeIconsSolid.tick03,
        iconOff: HugeIconsStroke.tick03,

        colorOn: scheme.onPrimaryContainer,
        colorOff: scheme.outline,

        size: 21,
        value: _isDone,
      ),

      title: AnimatedSize(
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
            style: TextStyle(
              color: _isDone ? scheme.onPrimaryContainer : scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeworkRenderSection extends StatelessWidget {
  final Homework homework;
  final ColorScheme scheme;

  const _HomeworkRenderSection({required this.homework, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final renderLabel = switch (homework.assignmentToRenderType) {
      .remoteRender => context.l10n.homeworkRenderPronote,
      .noRender => context.l10n.homeworkRenderNone,
      .paperRender => context.l10n.homeworkRenderPaper,
      .kiosqueRender => context.l10n.homeworkRenderKiosque, // unknown
      .remoteAudioRecordingRender => context.l10n.homeworkRenderPronoteAudio,
    };

    final renderIcon = switch (homework.assignmentToRenderType) {
      .remoteRender => HugeIconsSolid.fileUpload,
      .noRender => null,
      .paperRender => HugeIconsSolid.course,
      .kiosqueRender => HugeIconsSolid.note01, // unknown
      .remoteAudioRecordingRender => HugeIconsSolid.mic01,
    };

    return SliverToBoxAdapter(
      child: TileWidget(
        backgroundColor: scheme.surfaceContainer,
        borderRadius: const .all(ListWidget.radius),

        leading: renderIcon != null
            ? Icon(renderIcon, color: scheme.onSurface, size: 21)
            : null,

        title: Text(renderLabel, style: TextStyle(color: scheme.onSurface)),
      ),
    );
  }
}

class _HomeworkDifficultySection extends StatelessWidget {
  final Homework homework;
  final ColorScheme scheme;

  const _HomeworkDifficultySection({
    required this.homework,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListWidget.list(
      items: [
        if (homework.duration > 0)
          TileWidgetData(
            backgroundColor: scheme.surfaceContainer,
            title: Text(
              Formatters.formatDurationInMinutes(
                Duration(minutes: homework.duration.round()),
              ),
            ),
          ),

        if (homework.difficultyLevel > 0)
          TileWidgetData(
            backgroundColor: scheme.surfaceContainer,
            title: Row(
              spacing: 4,

              children: List.generate(
                homework.difficultyLevel,
                (index) =>
                    Icon(HugeIconsSolid.star, color: scheme.primary, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}
