import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
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

              return Pressable(
                onPressed: () async {
                  context.push(
                    Routes.auth.search.webview,
                    extra: {"parameters": widget.parameters, "workspace": workspace},
                  );
                },

                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),

                    child: Row(
                      spacing: 10,

                      children: [
                        const Icon(HugeIconsSolid.school),

                        Expanded(
                          child: Text(
                            workspace.label.trim(),

                            maxLines: 1,
                            overflow: .ellipsis,

                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
