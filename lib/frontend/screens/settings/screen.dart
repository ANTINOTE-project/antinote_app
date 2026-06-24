import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/settings/networking.dart";
import "package:antinote_app/frontend/screens/settings/theme.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

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
            _TextIcon(
              icon: HugeIconsSolid.paintBoard,
              label: context.l10n.theme,
            ),

            const ColorPicker(),
            const SliverPadding(padding: .only(top: 12)),
            const PreviewColor(),

            _TextIcon(
              icon: HugeIconsSolid.securedNetwork,
              label: context.l10n.network,
            ),

            const Networking(),

            _TextIcon(
              icon: HugeIconsSolid.userAccount,
              label: context.l10n.accounts,
            ),
            SliverToBoxAdapter(
              child: ButtonWidget(
                onPressed: () => context.push(Routes.auth.accounts),
                label: context.l10n.choseAnAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TextIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const .only(left: 6, top: 16, bottom: 4),
      sliver: SliverToBoxAdapter(
        child: Row(
          spacing: 8,

          children: [
            Icon(icon, color: context.c.outline, size: 22),

            Text(
              label,
              style: TextStyle(
                color: context.c.outline,
                fontWeight: .bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
