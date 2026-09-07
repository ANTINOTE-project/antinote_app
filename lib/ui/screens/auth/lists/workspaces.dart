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
  Workspace? _studentWorkspace;
  late bool _casLoginActive;
  late bool _isCasActive;

  @override
  void initState() {
    super.initState();

    final workspaces = widget.parameters.workspaces;
    _studentWorkspace = workspaces.firstWhere(
      (element) => element.type == .mobileEleve,
    );

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
        padding: const .symmetric(horizontal: 12),

        child: CustomScrollView(
          slivers: [
            if (_isCasActive) ...[
              SliverToBoxAdapter(
                child: TileWidget(
                  borderRadius: const .all(ListWidget.radius),
                  title: Text(context.l10n.activateCas),
                  switchValue: _casLoginActive,
                  onSwitchChanged: (value) => setState(() {
                    _casLoginActive = value;
                  }),
                ),
              ),

              const SliverPadding(padding: .only(bottom: 12)),
            ],

            ListWidget.list(
              items: [
                .new(
                  leading: Icon(
                    HugeIconsSolid.student,
                    color: _studentWorkspace == null
                        ? context.c.outlineVariant
                        : null,
                  ),
                  trailing: const Icon(HugeIconsSolid.arrowRight01),

                  title: Text(
                    context.l10n.loginStudentAccount,
                    style: TextStyle(
                      color: _studentWorkspace == null
                          ? context.c.outlineVariant
                          : null,
                    ),
                  ),

                  onPressed: _studentWorkspace != null
                      ? () {
                          onSelected(context, _studentWorkspace!);
                        }
                      : null,
                ),

                .new(
                  leading: const Icon(HugeIconsSolid.manWoman),
                  trailing: const Icon(HugeIconsSolid.arrowRight01),

                  title: Text(context.l10n.loginParentAccount),

                  onPressed: () {
                    showDialog(
                      context: context,

                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                            context.l10n.loginParentMessage,
                            style: context.tt.bodyLarge?.copyWith(
                              fontWeight: .w600,
                              height: 1.2,
                            ),
                          ),

                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(context.l10n.dialogClose),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
