import 'package:antinote_app/ui/screens/auth/lists/accounts.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import 'sync_screen.dart';

class Account extends StatelessWidget {
  const Account({super.key});

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
          ],
        ),
      ],
    );
  }
}
