import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class LoginSearchSelect extends StatefulWidget {
  final MobileInstanceParameters parameters;

  const LoginSearchSelect({super.key, required this.parameters});

  @override
  State<LoginSearchSelect> createState() => _LoginSearchSelectState();
}

class _LoginSearchSelectState extends State<LoginSearchSelect> {
  static const _iconMap = <WorkspaceType, IconData>{
    .mobileAdministrateur: HugeIconsSolid.manager,
    .mobileProfesseur: HugeIconsSolid.teacher,
    .mobileEtablissement: HugeIconsSolid.school,
    .mobileParent: HugeIconsSolid.manWoman,
    .mobileAccompagnant: HugeIconsSolid.userGroup,
    .mobileEleve: HugeIconsSolid.student,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginSelect),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    final workspaces = widget.parameters.workspaces;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),

      child: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemCount: workspaces.length,

            itemBuilder: (_, index) {
              final workspace = workspaces[index];

              return ListItemCard(
                onPressed: () async {
                  final result = await context.push<LoginResult>(
                    Routes.auth.search.webview,
                    extra: {
                      "parameters": widget.parameters,
                      "workspace": workspace,
                    },
                  );

                  if (result != null && mounted) {
                    context.pop(result);
                  }
                },

                leading: Icon(_iconMap[workspace.type]),
                label: workspace.label,
                trailing: const Icon(HugeIconsSolid.arrowRight01),
              );
            },
          ),
        ],
      ),
    );
  }
}
