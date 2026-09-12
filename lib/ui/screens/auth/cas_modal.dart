import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/account_type.dart';
import 'package:antinote_app/ui/screens/auth/password.dart';
import 'package:antinote_app/ui/screens/auth/webview.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:collection/collection.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

Future<RegisterableAccount?> showCasModal(
  BuildContext context, {
  required MobileInstanceParameters parameters,
  required AccountType accountType,
}) async {
  final wantedType = switch (accountType) {
    .student => WorkspaceType.mobileEleve,
    .parent => WorkspaceType.mobileParent,
  };

  final workspace = parameters.workspaces.firstWhereOrNull(
    (element) => element.type == wantedType,
  );

  if (workspace == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loginWorkspaceUnavailable)),
      );
    }

    return null;
  }

  if (!parameters.casActive) {
    return Navigator.push<RegisterableAccount>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PasswordLoginScreen(
            workspace: workspace,
            baseUrl: parameters.baseUrl,
          );
        },
      ),
    );
  }

  return showModalBottomSheet<RegisterableAccount>(
    backgroundColor: context.c.surfaceContainerLowest,
    isScrollControlled: true,
    showDragHandle: true,
    context: context,

    builder: (context) => _CasModal(
      parameters: parameters,
      accountType: accountType,
      workspace: workspace,
    ),
  );
}

class _CasModal extends StatefulWidget {
  final MobileInstanceParameters parameters;
  final AccountType accountType;
  final Workspace workspace;

  const _CasModal({
    required this.parameters,
    required this.accountType,
    required this.workspace,
  });

  @override
  State<_CasModal> createState() => _CasModalState();
}

class _CasModalState extends State<_CasModal> {
  late bool _casLoginActive = widget.parameters.casActive;

  Future<void> _onContinue() async {
    final result = await Navigator.push<RegisterableAccount>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return _casLoginActive
              ? WebviewLoginScreen(
                  parameters: widget.parameters,
                  workspace: widget.workspace,
                )
              : PasswordLoginScreen(
                  workspace: widget.workspace,
                  baseUrl: widget.parameters.baseUrl,
                );
        },
      ),
    );

    if (result != null && mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        right: 12,
        left: 12,
      ),

      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        spacing: 8,

        children: [
          Padding(
            padding: const .only(left: 8, right: 8, bottom: 16),

            child: Column(
              crossAxisAlignment: .start,

              children: [
                Text(
                  context.l10n.loginConfirmTitle,
                  style: context.tt.titleLarge?.copyWith(fontWeight: .bold),
                ),

                Text(
                  context.l10n.loginConfirmSubtitle,
                  style: context.tt.bodyLarge?.copyWith(
                    color: context.c.outline,
                  ),
                ),
              ],
            ),
          ),

          TileWidget(
            borderRadius: const .all(ListWidget.radius),
            title: Text(context.l10n.activateCas),
            switchValue: _casLoginActive,
            onSwitchChanged: (value) => setState(() {
              _casLoginActive = value;
            }),
          ),

          ButtonWidget(
            onPressed: _onContinue,
            label: context.l10n.loginButton,
            icon: switch (widget.accountType) {
              .student => HugeIconsSolid.student,
              .parent => HugeIconsSolid.manWoman,
            },
          ),
        ],
      ),
    );
  }
}
