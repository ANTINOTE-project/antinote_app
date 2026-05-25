import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/helpers/antinote_account.dart";
import "package:antinote_app/frontend/extensions/account_storage.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/extensions/session_manager.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class LoginPickScreen extends StatelessWidget with WidgetsBindingObserver {
  const LoginPickScreen({super.key});

  Future<void> sendResultIfLoggedIn(
    BuildContext context,
    Future<LoginResult?> pushed,
  ) async {
    final result = await pushed;
    if (result == null || !context.mounted) return;

    final account = result.refreshCredentials.asAntinoteAccount(result.session);
    await context.as.addAccount(account);

    if (context.mounted) {
      final state = context.sm.state;

      state.lastSeenAccountUid = account.uid;
      state.lastSeenSession = result.session;
      state.lastSeenSessionVersion = 0;

      context.pop(result);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.addAnAccount),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),

      child: Column(
        spacing: 8,

        children: [
          _buildOption(
            context: context,

            icon: HugeIconsSolid.maping,
            title: context.l10n.loginCity,
            subtitle: context.l10n.loginCitySubtitle,

            onPressed: () async {
              await sendResultIfLoggedIn(
                context,
                context.push<LoginResult>(Routes.auth.search.city),
              );
            },
          ),

          _buildOption(
            context: context,
            icon: HugeIconsSolid.link04,
            title: context.l10n.loginUrl,
            subtitle: context.l10n.loginUrlSubtitle,
            onPressed: () async {
              await sendResultIfLoggedIn(
                context,
                context.push<LoginResult>(Routes.auth.search.url),
              );
            },
          ),

          // TODO add qr code login
          // _buildOption(
          //   context: context,

          //   icon: HugeIconsSolid.qrCode01,
          //   title: context.l10n.loginQrCode,
          //   subtitle: context.l10n.loginQrCodeSubtitle,

          //   onPressed: () async {
          //     await sendResultIfLoggedIn(context, context.push(Routes.auth.qrCode));
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Pressable(
      onPressed: onPressed,

      child: Container(
        decoration: BoxDecoration(
          color: context.c.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),

        padding: const EdgeInsets.all(16),

        child: Row(
          spacing: 16,

          children: [
            Icon(icon, size: 32, color: context.c.primary),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.c.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            Icon(
              HugeIconsSolid.arrowRight01,
              color: context.c.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
