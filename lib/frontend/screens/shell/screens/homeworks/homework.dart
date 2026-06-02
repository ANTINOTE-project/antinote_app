import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/widgets/animated/icon.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/html_text.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";
import "package:url_launcher/url_launcher.dart";

class HomeworkScreen extends StatefulWidget {
  final Homework homework;

  const HomeworkScreen({super.key, required this.homework});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
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

    final deadlineDate = DateFormat(
      "dd/MM",
    ).format(widget.homework.deadlineDate);
    final givenDate = DateFormat("dd/MM").format(widget.homework.givenDate);

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
                    context.l10n.givenTheForThe(deadlineDate, givenDate),

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
                                CacheType.HOMEWORK,
                                widget.homework.visualId,
                              );

                          await session.access(
                            ChangeHomeworkStateAccessor(
                              homeworksToUpdate: {cachedHomework: _isDone},
                            ),
                          );
                        },
                      );
                    },

                    leading: IconWidget(
                      iconOn: HugeIconsSolid.tick03,
                      iconOff: HugeIconsStroke.tick03,

                      colorOn: scheme.onPrimaryContainer,
                      colorOff: scheme.onPrimaryContainer,

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
                          style: TextStyle(color: scheme.onPrimaryContainer),
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

                title: HtmlText(
                  rawHtml: widget.homework.description,

                  removeStyleAndFontSize: true,
                  maxLines: 999999, // i dont know why null is not working

                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
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
                        Utils.formatDurationInMinutes(
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
                  final icon = switch (attachment) {
                    LinkAttachment() => HugeIconsSolid.link01,

                    FileAttachment(type: final type) => switch (type) {
                      .text => HugeIconsSolid.text,
                      .pdf => HugeIconsSolid.pdf02,
                      .archive => HugeIconsSolid.archive,
                      .spreadsheet => HugeIconsSolid.googleSheet,
                      .image => HugeIconsSolid.image01,
                      .audio => HugeIconsSolid.audioWave01,
                      .video => HugeIconsSolid.video01,
                      .slides => HugeIconsSolid.slideshare,
                      .geogebra => HugeIconsSolid.math,
                      .other => HugeIconsSolid.documentAttachment,
                    },
                  };

                  return ItemWidget(
                    borderRadius: borderRadius,
                    backgroundColor: scheme.surfaceContainer,

                    onPressed: () async {
                      final url = switch (attachment) {
                        LinkAttachment(url: final url) => Uri.parse(url),

                        FileAttachment() => await SessionManager.execute(
                          context: context,

                          callback: (session) async {
                            return await attachment.getLinkToAttachment(
                              session,
                            );
                          },
                        ),
                      };

                      await launchUrl(
                        url,

                        mode: LaunchMode.inAppBrowserView,
                        browserConfiguration: const BrowserConfiguration(
                          showTitle: true,
                        ),
                      );
                    },

                    leading: Icon(icon),
                    title: Text(attachment.title, maxLines: 3),
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
