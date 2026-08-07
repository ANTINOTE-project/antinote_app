import 'dart:async';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

typedef Method = ({
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onPressed,
});

class MethodsScreen extends StatelessWidget with WidgetsBindingObserver {
  const MethodsScreen({super.key});

  List<Method> buildOptions(BuildContext context) {
    return [
      (
        icon: HugeIconsSolid.mapsSearch,

        title: context.l10n.loginCity,
        subtitle: context.l10n.loginCitySubtitle,

        onPressed: () async {
          await sendResultIfLoggedIn(
            context,
            context.push<RegisterableAccount>(Routes.auth.city),
          );
        },
      ),
      (
        icon: HugeIconsSolid.qrCode01,

        title: context.l10n.loginQrCode,
        subtitle: context.l10n.loginQrCodeSubtitle,

        onPressed: () async {
          await sendResultIfLoggedIn(
            context,
            context.push<RegisterableAccount>(Routes.auth.qrCode),
          );
        },
      ),
      (
        icon: HugeIconsSolid.link04,

        title: context.l10n.loginUrl,
        subtitle: context.l10n.loginUrlSubtitle,

        onPressed: () async {
          await sendResultIfLoggedIn(
            context,
            context.push<RegisterableAccount?>(Routes.auth.url),
          );
        },
      ),
    ];
  }

  Future<void> sendResultIfLoggedIn(
    BuildContext context,
    FutureOr<RegisterableAccount?> pushed,
  ) async {
    final entry = await pushed;
    if (entry == null || !context.mounted) return;

    final result = await context.ar.registerAccount(entry);

    if (!result || !context.mounted) return;

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final options = buildOptions(context);

    return Scaffold(
      appBar: AppBarWidget(
        title: Text(context.l10n.addAnAccount),

        actions: [
          // if (kDebugMode)
          IconButton(
            onPressed: () async {
              final credentials = PasswordCredentials(
                username: 'demonstration',
                password: 'pronotevs',

                workspace: const Workspace(
                  type: WorkspaceType.mobileEleve,
                  label: '',
                  pathSegment: 'mobile.eleve.html',
                ),

                deviceUuid: Credentials.generateDeviceUuid(),
                baseUrl: Uri.parse('https://demo.index-education.net/pronote'),
                cookies: [],
              );
              final result = await credentials.login(
                options: context.s.networking.sessionOptions,
              );

              if (!context.mounted) return;

              final entry = SessionWrapper.register(result, credentials);
              await sendResultIfLoggedIn(context, entry);
            },

            icon: const Icon(HugeIconsSolid.developer),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: ListWidget(
          isSliver: false,
          items: options,

          itemBuilder: (context, item, borderRadius) {
            return ItemWidget(
              borderRadius: borderRadius,
              onPressed: item.onPressed,

              leading: Icon(item.icon),

              title: Text(
                item.title,

                maxLines: 3,

                style: const TextStyle(fontSize: 18),
              ),

              subtitle: Text(
                item.subtitle,

                maxLines: 3,

                style: const TextStyle(fontSize: 13),
              ),

              trailing: Skeleton.ignore(
                child: Icon(
                  HugeIconsSolid.arrowRight01,
                  color: context.c.outline,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
