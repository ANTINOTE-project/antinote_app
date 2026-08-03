import 'package:antinote/antinote.dart';
import 'package:antinote_app/main.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class LoginSelectWorkspaceScreen extends StatefulWidget {
  final MobileInstanceParameters parameters;

  const LoginSelectWorkspaceScreen({super.key, required this.parameters});

  @override
  State<LoginSelectWorkspaceScreen> createState() =>
      _LoginSelectWorkspaceScreenState();
}

class _LoginSelectWorkspaceScreenState
    extends State<LoginSelectWorkspaceScreen> {
  static const _iconMap = <WorkspaceType, IconData>{
    .mobileAdministrateur: HugeIconsSolid.manager,
    .mobileProfesseur: HugeIconsSolid.teacher,
    .mobileEtablissement: HugeIconsSolid.school,
    .mobileParent: HugeIconsSolid.manWoman,
    .mobileAccompagnant: HugeIconsSolid.userGroup,
    .mobileEleve: HugeIconsSolid.student,
  };

  late List<Workspace> _workspaces;

  late bool _casLoginActive;
  late bool _isCasActive;

  @override
  void initState() {
    super.initState();

    _workspaces = widget.parameters.workspaces;
    _workspaces.sort((a, b) => a.type == .mobileEleve ? -1 : 1);

    _casLoginActive = widget.parameters.casActive;
    _isCasActive = widget.parameters.casActive;
  }

  Future<void> onSelected(BuildContext context, Workspace workspace) async {
    final LoginResult? result;

    if (_casLoginActive) {
      result = await context.push<LoginResult>(
        Routes.auth.webview,
        extra: {'parameters': widget.parameters, 'workspace': workspace},
      );
    } else {
      result = await context.push<LoginResult>(
        Routes.auth.password,
        extra: {'workspace': workspace, 'baseUrl': widget.parameters.baseUrl},
      );
    }

    if (result != null && context.mounted) {
      context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.loginSelect)),

      body: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 6),

        child: CustomScrollView(
          slivers: [
            if (_isCasActive) ...[
              SliverToBoxAdapter(
                child: ItemWidget(
                  borderRadius: const .all(ListWidget.radius),

                  title: Text(context.l10n.activateCas),

                  trailing: Switch(
                    value: _casLoginActive,

                    onChanged: (value) => setState(() {
                      _casLoginActive = value;
                    }),
                  ),
                ),
              ),

              const SliverPadding(padding: .only(bottom: 8)),
            ],

            ListWidget(
              items: _workspaces,

              itemBuilder: (context, workspace, borderRadius) {
                final isNotStudent = workspace.type != .mobileEleve;

                return ItemWidget(
                  borderRadius: borderRadius,

                  onPressed: () async {
                    if (isNotStudent) {
                      return talker.warning(
                        'Login with an account that is not a student one is not implemented',
                      );
                    }

                    await onSelected(context, workspace);
                  },

                  leading: Icon(
                    _iconMap[workspace.type],
                    color: isNotStudent ? context.c.outlineVariant : null,
                  ),

                  title: Text(
                    workspace.label,

                    style: TextStyle(
                      color: isNotStudent ? context.c.outlineVariant : null,
                    ),
                  ),

                  subtitle: Text(
                    workspace.pathSegment,

                    style: TextStyle(
                      color: isNotStudent ? context.c.outlineVariant : null,
                    ),
                  ),

                  trailing: Icon(
                    HugeIconsSolid.arrowRight01,
                    color: isNotStudent
                        ? context.c.outlineVariant
                        : context.c.outline,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
