import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/main.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class LoginUrlScreen extends StatefulWidget {
  const LoginUrlScreen({super.key});

  @override
  State<LoginUrlScreen> createState() => _LoginUrlScreenState();
}

class _LoginUrlScreenState extends State<LoginUrlScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  Completer<SpecificInstanceParameters?>? lastApplicableParameters;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();

    setState(() {
      lastApplicableParameters = Completer();
    });

    _debounce = Timer(const Duration(seconds: 1), () async {
      final url = Uri.tryParse(_controller.text.trim());

      if (url == null) {
        lastApplicableParameters?.complete(null);

        return;
      }

      try {
        final workspacesSession = await PronoteSession.init(
          url,
          workspace: Workspace.common,
        );
        await workspacesSession.access(const InstanceParametersAccessor());
        await workspacesSession.access(const DisconnectionAccessor.unlogged());

        for (final workspace in workspacesSession.broadInstance.workspaces) {
          try {
            final session = await PronoteSession.init(
              url,
              workspace: workspace,
            );
            await session.access(const InstanceParametersAccessor());
            await session.access(const DisconnectionAccessor.unlogged());

            lastApplicableParameters?.complete(session.instance);
            break;
          } catch (e, st) {
            if (kDebugMode) {
              talker.error(
                "Could not start ${workspace.label} session at $url",
                e,
                st,
              );
            }
          }
        }
      } catch (e) {
        lastApplicableParameters?.complete(null);

        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginUrl),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              // TODO: Faire en sorte que ça n'overflow pas.
              child: FieldWidget(
                controller: _controller,
                hintText: context.l10n.loginCitySubtitle,
                onChanged: (_) => _onQueryChanged(),
              ),
            ),
          ),
          FutureBuilder(
            future: lastApplicableParameters?.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == .none) {
                return const SliverOffstage();
              }

              if (snapshot.connectionState != .done) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData) {
                return Center(child: Text(context.l10n.couldNotLoad));
              }

              final instance = snapshot.requireData!;

              return SliverPadding(
                padding: const .symmetric(horizontal: 12),

                sliver: ListWidget(
                  items: [
                    (
                      title: context.l10n.instanceName,
                      subtitle: context.l10n.instanceNameValue(
                        instance.establishmentName,
                        instance.loginEstablishmentName,
                      ),
                    ),
                    (
                      title: context.l10n.remoteVersion,
                      subtitle: instance.version.toString(),
                    ),
                    (
                      title: context.l10n.remoteYear,
                      subtitle: context.l10n.remoteYearSubtitle(
                        instance.firstDate,
                        instance.lastDate,
                      ),
                    ),
                    (
                      title: context.l10n.remoteYear,
                      subtitle: context.l10n.remoteYearSubtitle(
                        instance.firstDate,
                        instance.lastDate,
                      ),
                    ),
                    (title: context.l10n.remotePeriods, subtitle: ""),
                  ],

                  itemBuilder: (context, item, borderRadius) {
                    return ItemWidget(
                      borderRadius: borderRadius,

                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
