import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class AttachmentItemWidget extends StatelessWidget {
  const AttachmentItemWidget({
    super.key,
    required this.attachment,
    required this.borderRadius,
    required this.backgroundColor,
  });

  final Attachment attachment;
  final BorderRadius borderRadius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: backgroundColor,

      onPressed: () async {
        final url = switch (attachment) {
          LinkAttachment(url: final url) => Uri.parse(url),
          FileAttachment() => await context.ar.runTask(
            context: context,
            channels: {},
            callback: (session) async {
              final cachedAttachment = session.getCachedValue<FileAttachment>(
                .FILE_ATTACHMENT,
                attachment.visualId,
              );

              return await cachedAttachment.getLinkToAttachment(session);
            },
            debugLabel: 'Retrieves link from file',
          ),
        };

        await launchUrl(
          url,
          mode: LaunchMode.inAppBrowserView,
          browserConfiguration: const BrowserConfiguration(showTitle: true),
        );
      },
      leading: Icon(icon),
      title: Text(attachment.title, maxLines: 3),
    );
  }
}
