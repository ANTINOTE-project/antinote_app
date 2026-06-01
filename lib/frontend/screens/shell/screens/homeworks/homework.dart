import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/html_text.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";
import "package:url_launcher/url_launcher.dart";

class HomeworkScreen extends StatelessWidget {
  final Homework homework;

  const HomeworkScreen({super.key, required this.homework});

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);
    final date = DateFormat("dd/MM/yyyy").format(homework.deadlineDate);

    return Scaffold(
      appBar: const AppBarWidget(),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const .symmetric(horizontal: 12),

        child: Column(
          spacing: 12,

          children: [
            Padding(
              padding: const .only(bottom: 6),

              child: Column(
                children: [
                  Text(
                    homework.subject.name ?? context.l10n.noSubject,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: TextStyle(
                      fontWeight: .w800,
                      fontSize: 27,
                      color: scheme.primary,
                    ),
                  ),

                  Text(
                    context.l10n.forThe(date),

                    style: TextStyle(
                      color: scheme.outline,
                      fontWeight: .w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            _Text(
              label: context.l10n.homeworkDescription,
              icon: HugeIconsSolid.task01,
            ),

            ItemWidget(
              borderRadius: const .all(ListWidget.radius),

              title: HtmlText(
                rawHtml: homework.description,
                maxLines: 999999, // i dont know why null is not working

                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            if (homework.attachments.isNotEmpty) ...[
              _Text(
                label: context.l10n.homeworkAttachments,
                icon: HugeIconsSolid.attachment,
              ),

              ListWidget(
                items: homework.attachments,

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
                    title: Text(attachment.title),
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
  final IconData icon;

  const _Text({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 6, top: 10),

      child: Row(
        spacing: 6,

        children: [
          Icon(icon, color: context.c.outline, size: 22),

          Text(
            label,

            style: TextStyle(
              color: context.c.outline,
              fontWeight: .bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
