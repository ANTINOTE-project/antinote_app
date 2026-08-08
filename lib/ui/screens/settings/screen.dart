import 'package:antinote_app/ui/l10n/app_localizations.dart';
import 'package:antinote_app/ui/screens/auth/lists/accounts_list.dart';
import 'package:antinote_app/ui/screens/settings/networking.dart';
import 'package:antinote_app/ui/screens/settings/theme.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

enum AppColor {
  coral(Color(0xff904a40)),
  blue(Color(0xFF1E88E5)),
  green(Color(0xFF43A047)),
  purple(Color(0xFF8E24AA)),
  amber(Color(0xFFFFB300)),
  teal(Color(0xFF00897B));

  const AppColor(this.color);

  final Color color;

  String label(AppLocalizations l10n) => switch (this) {
    AppColor.coral => l10n.themeCoral,
    AppColor.blue => l10n.themeBlue,
    AppColor.green => l10n.themeGreen,
    AppColor.purple => l10n.themePurple,
    AppColor.amber => l10n.themeAmber,
    AppColor.teal => l10n.themeTeal,
  };
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.appSettings)),

      body: Padding(
        padding: const .symmetric(horizontal: 12),
        child: CustomScrollView(
          slivers: [
            SliverTextIcon(
              icon: HugeIconsSolid.paintBoard,
              label: context.l10n.theme,
            ),

            const AppearancePicker(),
            const SliverPadding(padding: .only(top: 12)),
            const PreviewColor(),

            SliverTextIcon(
              icon: HugeIconsSolid.securedNetwork,
              label: context.l10n.network,
            ),

            const Networking(),

            SliverTextIcon(
              icon: HugeIconsSolid.userAccount,
              label: context.l10n.accounts,
            ),

            SliverToBoxAdapter(
              child: ButtonWidget(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const AccountsListScreen();
                    },
                  ),
                ),
                label: context.l10n.choseAnAccount,
              ),
            ),

            const BottomPadding(padding: 20),
          ],
        ),
      ),
    );
  }
}
