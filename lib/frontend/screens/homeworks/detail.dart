import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/attachment.dart";
import "package:antinote_app/frontend/widgets/customs/icon.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/remote_html.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class HomeworkDetailScreen extends StatefulWidget {
  final void Function(bool value) onHomeworkChange;
  final Homework homework;

  const HomeworkDetailScreen({
    super.key,
    required this.homework,
    required this.onHomeworkChange,
  });

  @override
  State<HomeworkDetailScreen> createState() => _HomeworkDetailScreenState();
}

class _HomeworkDetailScreenState extends State<HomeworkDetailScreen> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.homework.isDone;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(
      context,
      widget.homework.backgroundColor,
    );

    final renderLabel = switch (widget.homework.assignmentToRenderType) {
      .pronoteRender => context.l10n.homeworkRenderPronote,
      .noRender => context.l10n.homeworkRenderNone,
      .paperRender => context.l10n.homeworkRenderPaper,
      .kiosqueRender => context.l10n.homeworkRenderKiosque, // unknown
      .pronoteAudioRecordingRender => context.l10n.homeworkRenderPronoteAudio,
    };

    final renderIcon = switch (widget.homework.assignmentToRenderType) {
      .pronoteRender => HugeIconsSolid.fileUpload,
      .noRender => null,
      .paperRender => HugeIconsSolid.course,
      .kiosqueRender => HugeIconsSolid.note01, // unknown
      .pronoteAudioRecordingRender => HugeIconsSolid.mic01,
    };

    return Scaffold(
      appBar: const AppBarWidget(),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const .symmetric(horizontal: 12),

        child: Column(
          spacing: 6,

          children: [
            Padding(
              padding: const .only(bottom: 6),

              child: Column(
                children: [
                  Text(
                    widget.homework.subject.name ?? context.l10n.noSubject,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: TextStyle(
                      fontWeight: .w800,
                      fontSize: 27,
                      color: scheme.primary,
                    ),
                  ),

                  Text(
                    context.l10n.givenTheForThe(
                      widget.homework.givenDate,
                      widget.homework.deadlineDate,
                    ),

                    textAlign: .center,

                    style: TextStyle(
                      color: scheme.outline,
                      fontWeight: .w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            _Text(label: context.l10n.homeworkState, scheme: scheme),

            ListWidget(
              items: const [null],

              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              isSliver: false,

              itemBuilder: (context, _, borderRadius) => Column(
                children: [
                  ItemWidget(
                    backgroundColor: scheme.primaryContainer,

                    borderRadius:
                        widget.homework.assignmentToRenderType == .noRender
                        ? borderRadius
                        : borderRadius.copyWith(
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.zero,
                          ),

                    onPressed: () async {
                      setState(() {
                        _isDone = !_isDone;
                      });

                      await SessionManager.execute(
                        context: context,

                        callback: (session) async {
                          final cachedHomework = session
                              .getCachedValue<Homework>(
                                .HOMEWORK,
                                widget.homework.visualId,
                              );

                          await session.access(
                            ChangeHomeworkStateAccessor(
                              homeworksToUpdate: {cachedHomework: _isDone},
                            ),
                          );
                        },
                      );

                      widget.onHomeworkChange.call(_isDone);
                    },

                    leading: IconWidget(
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
                            color: _isDone
                                ? scheme.onPrimaryContainer
                                : scheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (widget.homework.assignmentToRenderType != .noRender)
                    ItemWidget(
                      backgroundColor: scheme.surfaceContainer,

                      borderRadius: borderRadius.copyWith(
                        topLeft: Radius.zero,
                        topRight: Radius.zero,
                      ),

                      leading: renderIcon != null
                          ? Icon(renderIcon, color: scheme.onSurface, size: 21)
                          : null,

                      title: Text(
                        renderLabel,
                        style: TextStyle(color: scheme.onSurface),
                      ),
                    ),
                ],
              ),
            ),

            if (widget.homework.description.trim().isNotEmpty) ...[
              _Text(label: context.l10n.homeworkDescription, scheme: scheme),

              ItemWidget(
                backgroundColor: scheme.surfaceContainer,
                borderRadius: const .all(ListWidget.radius),

                title: RemoteHtml(
                  rawHtml: widget.homework.description,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: .w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],

            if (widget.homework.duration > 0 ||
                widget.homework.difficultyLevel > 0) ...[
              _Text(label: context.l10n.homeworkDifficulty, scheme: scheme),

              ItemWidget(
                backgroundColor: scheme.surfaceContainer,
                borderRadius: const .all(ListWidget.radius),

                title: Row(
                  spacing: 6,

                  children: [
                    if (widget.homework.duration > 0)
                      Text(
                        Formatters.formatDurationInMinutes(
                          Duration(minutes: widget.homework.duration.round()),
                        ),
                      ),

                    if (widget.homework.duration > 0 &&
                        widget.homework.difficultyLevel > 0)
                      SizedBox(
                        height: 20,

                        child: VerticalDivider(
                          color: scheme.outline,
                          radius: .circular(999),
                          thickness: 2,
                          width: 5,
                        ),
                      ),

                    if (widget.homework.difficultyLevel > 0)
                      ...List.generate(
                        widget.homework.difficultyLevel,

                        (index) => Icon(
                          HugeIconsSolid.star,
                          color: scheme.primary,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            if (widget.homework.attachments.isNotEmpty) ...[
              _Text(label: context.l10n.homeworkAttachments, scheme: scheme),

              ListWidget(
                items: widget.homework.attachments,

                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                isSliver: false,

                itemBuilder: (context, attachment, borderRadius) {
                  return AttachmentItemWidget(
                    attachment: attachment,
                    borderRadius: borderRadius,
                    backgroundColor: scheme.surfaceContainer,
                  );
                },
              ),
            ],

            Padding(
              padding: .only(bottom: MediaQuery.paddingOf(context).bottom + 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _Text extends StatelessWidget {
  final String label;
  final ColorScheme scheme;

  const _Text({required this.label, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 8, top: 14),

      child: Align(
        alignment: .centerLeft,

        child: Text(
          label,

          style: TextStyle(
            color: scheme.outline,
            fontWeight: .bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
