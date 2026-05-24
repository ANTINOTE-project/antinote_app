import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/modal.dart";
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

  late bool casLoginActive;

  @override
  void initState() {
    super.initState();
    casLoginActive = widget.parameters.casActive;
  }

  Future<void> onSelected(BuildContext context, Workspace workspace) async {
    final LoginResult? result;

    if (casLoginActive) {
      result = await context.push<LoginResult>(
        Routes.auth.search.webview,
        extra: {"parameters": widget.parameters, "workspace": workspace},
      );
    } else {
      result = await Modal.show(
        context,
        context.l10n.loginCredentials,
        Form(child: Column(children: [TextFormField(), TextFormField()])),
      );
    }

    if (result != null && context.mounted) {
      context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginSelect),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),

        child: CustomScrollView(
          slivers: [
            if (widget.parameters.casActive) ...[
              SliverToBoxAdapter(
                child: ListItemCard(
                  onPressed: null,
                  title: context.l10n.activateCas,
                  color: context.c.surfaceContainerHigh,
                  trailing: Switch(
                    value: casLoginActive,
                    onChanged: (value) => setState(() {
                      casLoginActive = value;
                    }),
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(top: 12)),
            ],

            SliverList.builder(
              itemCount: widget.parameters.workspaces.length,
              itemBuilder: (context, index) {
                final workspace = widget.parameters.workspaces[index];

                return ListItemCard(
                  onPressed: () async => await onSelected(context, workspace),
                  leading: Icon(_iconMap[workspace.type]),
                  title: workspace.label,
                  trailing: const Icon(HugeIconsSolid.arrowRight01),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
