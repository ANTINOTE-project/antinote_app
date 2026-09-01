import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class Networking extends StatefulWidget {
  const Networking({super.key});

  @override
  State<Networking> createState() => _NetworkingState();
}

class _NetworkingState extends State<Networking> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.s.networking,

      builder: (context, child) {
        return SliverMainAxisGroup(
          slivers: [
            SliverTextIcon(
              icon: HugeIconsSolid.securedNetwork,
              label: context.l10n.network,
            ),

            ListWidget.list(
              items: [
                TileWidgetData(
                  title: Text(context.l10n.sendNavigationRequests, maxLines: 3),

                  subtitle: Text(
                    context.l10n.sendNavigationRequestsSubtitle,
                    maxLines: 10,
                  ),

                  onPressed: () async {
                    final options = context.s.networking.sessionOptions.rebuild(
                      (options) => options.saveNavigationRequests = !context
                          .s
                          .networking
                          .sessionOptions
                          .saveNavigationRequests,
                    );

                    await context.s.networking.setSessionOptions(options);
                  },

                  trailing: Switch(
                    value: !context
                        .s
                        .networking
                        .sessionOptions
                        .saveNavigationRequests,
                    onChanged: (value) async {
                      final options = context.s.networking.sessionOptions
                          .rebuild(
                            (options) =>
                                options.saveNavigationRequests = !value,
                          );

                      await context.s.networking.setSessionOptions(options);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
