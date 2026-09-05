import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/password.dart';
import 'package:antinote_app/ui/screens/auth/webview.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class WorkspacesListScreen extends StatefulWidget {
  final MobileInstanceParameters parameters;

  const WorkspacesListScreen({super.key, required this.parameters});

  @override
  State<WorkspacesListScreen> createState() => _WorkspacesListScreenState();
}

class _WorkspacesListScreenState extends State<WorkspacesListScreen> {
  static const _iconMap = <WorkspaceType, IconData>{
    .mobileAdministrateur: HugeIconsSolid.manager,
    .mobileProfesseur: HugeIconsSolid.teacher,
    .mobileEtablissement: HugeIconsSolid.school,
    .mobileParent: HugeIconsSolid.manWoman,
    .mobileAccompagnant: HugeIconsSolid.userGroup,
    .mobileEleve: HugeIconsSolid.student,
    .mobileEntreprise: HugeIconsSolid.corporate,
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
    final result = await Navigator.push<RegisterableAccount>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return _casLoginActive
              ? WebviewLoginScreen(
                  parameters: widget.parameters,
                  workspace: workspace,
                )
              : PasswordLoginScreen(
                  workspace: workspace,
                  baseUrl: widget.parameters.baseUrl,
                );
        },
      ),
    );

    if (result != null && context.mounted) Navigator.pop(context, result);
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
                child: TileWidget(
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

                return TileWidget(
                  borderRadius: borderRadius,

                  onPressed: isNotStudent
                      ? null
                      : () => onSelected(context, workspace),

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
