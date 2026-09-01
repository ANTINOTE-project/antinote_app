import 'package:antinote_app/ui/l10n/app_localizations.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:material_ui/material_ui.dart';

import 'account.dart';
import 'appearance.dart';
import 'application.dart';
import 'networking.dart';

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

      body: const Padding(
        padding: .symmetric(horizontal: 12),

        child: CustomScrollView(
          slivers: [
            Appearance(),
            Networking(),
            Account(),
            Application(),

            BottomPadding(padding: 20),
          ],
        ),
      ),
    );
  }
}
