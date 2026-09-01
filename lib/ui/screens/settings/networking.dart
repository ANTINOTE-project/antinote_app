import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:material_ui/material_ui.dart';

class Networking extends StatefulWidget {
  const Networking({super.key});

  @override
  State<Networking> createState() => _NetworkingState();
}

class _NetworkingState extends State<Networking> {
  Future<void>? reconnectFuture;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.s.networking,
      builder: (context, child) => ListWidget.list(
        items: [
          TileWidgetData(
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
          TileWidgetData(
            title: Text(context.l10n.reconnectAccount),
            onPressed: () {
              if (reconnectFuture != null) return;

              setState(() {
                reconnectFuture = () async {
                  await context.ar.curSession?.ensureSession(
                    storage: context.ar.storage,
                    options: context.s.networking.sessionOptions,
                    force: true,
                  );

                  reconnectFuture = null;
                }();
              });
            },
            trailing: FutureBuilder(
              future: reconnectFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == .none ||
                    snapshot.connectionState == .done) {
                  return const SizedBox.shrink();
                }

                return const LoadingWidget();
              },
            ),
          ),
        ],
      ),
    );
  }
}
