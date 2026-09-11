import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/methods.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

enum AccountType { student, parent }

class AccountTypeLoginScreen extends StatelessWidget {
  const AccountTypeLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: Text(context.l10n.whoAreYou),
        subtitle: Text(context.l10n.whoAreYouSubtitle),
      ),

      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const .symmetric(horizontal: 12),

            sliver: SliverMainAxisGroup(
              slivers: [
                ListWidget(
                  gap: 6,

                  items: const [
                    _AccountTypeTile(
                      icon: HugeIconsSolid.student,
                      accountType: .student,
                    ),
                    _AccountTypeTile(
                      icon: HugeIconsSolid.manWoman,
                      accountType: .parent,
                    ),
                  ],

                  itemBuilder: (_, item, _) => item,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleIcon extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Color onAccent;

  const _RoleIcon({
    required this.icon,
    required this.accent,
    required this.onAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: accent, shape: .circle),
      child: Icon(icon, color: onAccent, size: 22),
    );
  }
}

class _AccountTypeTile extends StatelessWidget {
  final IconData icon;
  final AccountType accountType;

  const _AccountTypeTile({required this.icon, required this.accountType});

  String _title(BuildContext context) {
    return switch (accountType) {
      .student => context.l10n.loginStudentAccount,
      .parent => context.l10n.loginParentAccount,
    };
  }

  String _subtitle(BuildContext context) {
    return switch (accountType) {
      .student => context.l10n.loginStudentAccountSubtitle,
      .parent => context.l10n.loginParentAccountSubtitle,
    };
  }

  Future<void> _onPressed(BuildContext context) async {
    final result = await Navigator.push<RegisterableAccount>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LoginMethodsScreen(accountType: accountType);
        },
      ),
    );

    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = switch (accountType) {
      .student => context.c.primary,
      .parent => context.c.tertiary,
    };

    final onAccent = switch (accountType) {
      .student => context.c.onPrimary,
      .parent => context.c.onTertiary,
    };

    return TileWidget(
      borderRadius: const .all(ListWidget.radius),
      padding: const .symmetric(horizontal: 16, vertical: 14),
      backgroundColor: context.c.surfaceContainer,

      leading: _RoleIcon(icon: icon, accent: accent, onAccent: onAccent),
      trailing: Icon(HugeIconsSolid.arrowRight01, color: context.c.outline),

      title: Text(_title(context)),
      subtitle: Text(_subtitle(context), maxLines: 2),

      onPressed: () => _onPressed(context),
    );
  }
}
