import 'package:antinote_app/ui/screens/auth/lists/accounts.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import 'sync_screen.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Future<void>? reconnectFuture;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverTextIcon(
          icon: HugeIconsSolid.userAccount,
          label: context.l10n.accounts,
        ),

        ListWidget.list(
          items: [
            .new(
              title: Text(context.l10n.chooseAnAccount),
              subtitle: Text(context.l10n.chooseAnAccountSubtitle),
              trailing: Icon(
                HugeIconsSolid.arrowRight01,
                color: context.c.outline,
              ),

              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const AccountsListScreen();
                  },
                ),
              ),
            ),

            if (kDebugMode)
              .new(
                title: Text(context.l10n.accountSyncSettings),
                subtitle: Text(context.l10n.accountSyncSettingsSubtitle),

                trailing: Icon(
                  HugeIconsSolid.arrowRight01,
                  color: context.c.outline,
                ),

                onPressed: () async {
                  if (context.ar.curAccountUid == null) {
                    await context.ar.ensureAccountPicked(context: context);
                  }

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsSyncScreen(
                        accountUid: context.ar.curAccountUid!,
                      ),
                    ),
                  );
                },
              ),

            .new(
              title: Text(context.l10n.reconnectAccount),
              onPressed: () {
                if (reconnectFuture != null) return;

                setState(() {
                  reconnectFuture = () async {
                    await context.ar.curSession?.ensureSession(
                      storage: context.ar.storage,
                      options: context.s.networking.sessionOptions,
                      force: true,
                    );

                    reconnectFuture = null;
                  }();
                });
              },

              trailing: FutureBuilder(
                future: reconnectFuture,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == .none ||
                      snapshot.connectionState == .done) {
                    return const SizedBox.shrink();
                  }

                  return const LoadingWidget(size: 15);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
