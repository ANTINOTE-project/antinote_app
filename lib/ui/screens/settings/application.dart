import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverTextIcon(
          icon: HugeIconsSolid.more,
          label: context.l10n.application,
        ),

        ListWidget.list(
          items: [
            .new(
              title: Text(context.l10n.about),
              trailing: Icon(
                HugeIconsSolid.arrowRight01,
                color: context.c.outline,
              ),

              onPressed: () async {
                final info = await PackageInfo.fromPlatform();
                if (!context.mounted) return;

                showLicensePage(
                  context: context,
                  applicationName: context.l10n.appName,
                  applicationLegalese: context.l10n.appLegalese,
                  applicationVersion: info.version,
                  applicationIcon: const SizedBox(
                    height: 64,
                    width: 64,
                    child: CircleAvatar(
                      foregroundImage: AssetImage('assets/icon.png'),
                      radius: 90,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
