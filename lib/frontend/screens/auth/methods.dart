import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/backend/src/helpers/antinote_account.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:skeletonizer/skeletonizer.dart";

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
        icon: HugeIconsSolid.maping,

        title: context.l10n.loginCity,
        subtitle: context.l10n.loginCitySubtitle,

        onPressed: () async {
          await sendResultIfLoggedIn(
            context,
            context.push<LoginResult>(Routes.auth.city),
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
            context.push<LoginResult>(Routes.auth.url),
          );
        },
      ),
    ];
  }

  Future<void> sendResultIfLoggedIn(
    BuildContext context,
    Future<LoginResult?> pushed,
  ) async {
    final result = await pushed;
    if (result == null || !context.mounted) return;

    final account = result.refreshCredentials.asAntinoteAccount(result.session);
    await context.as.addAccount(account);

    if (context.mounted) {
      if (context.getInheritedWidgetOfExactType<SessionManager>() != null) {
        final state = context.sm.state;

        state.lastSeenAccountUid = account.uid;
        state.lastSeenSession = result.session;
        state.lastSeenSessionVersion = 0;
      }

      context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = buildOptions(context);

    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.addAnAccount),

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
