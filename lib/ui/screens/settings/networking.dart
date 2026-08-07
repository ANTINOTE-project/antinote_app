import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';

class Networking extends StatelessWidget {
  const Networking({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.s.networking,
      builder: (context, child) => ListWidget.list(
        items: [
          ItemWidgetData(
            title: Text(context.l10n.sendNavigationRequests, maxLines: 3),
            subtitle: Text(
              context.l10n.sendNavigationRequestsSubtitle,
              maxLines: 10,
            ),
            trailing: Switch(
              value:
                  !context.s.networking.sessionOptions.saveNavigationRequests,
              onChanged: (value) async {
                final options = context.s.networking.sessionOptions.rebuild(
                  (options) => options.saveNavigationRequests = !value,
                );

                await context.s.networking.setSessionOptions(options);
              },
            ),
          ),
          ItemWidgetData(
            title: ButtonWidget(
              onPressed: () async {
                await context.ar.curSession?.ensureSession(
                  storage: context.ar.storage,
                  options: context.s.networking.sessionOptions,
                  force: true,
                );
              },
              label: context.l10n.reconnectAccount,
            ),
          ),
        ],
      ),
    );
  }
}
