import 'dart:async';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/lists/workspaces.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/field.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class UrlMethodScreen extends StatefulWidget {
  const UrlMethodScreen({super.key});

  @override
  State<UrlMethodScreen> createState() => _UrlMethodScreenState();
}

class _UrlMethodScreenState extends State<UrlMethodScreen> {
  final _controller = TextEditingController(
    text: kDebugMode ? 'https://demo.index-education.net/pronote' : null,
  );
  Timer? _debounce;

  Completer<SpecificInstanceParameters?>? lastApplicableParameters;
  Uri? instanceUrl;

  @override
  void didChangeDependencies() {
    _onQueryChanged();
    super.didChangeDependencies();
  }

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

    _debounce = Timer(const Duration(seconds: 3), () async {
      instanceUrl = Uri.tryParse(_controller.text.trim());

      if (instanceUrl == null) {
        return lastApplicableParameters?.complete(null);
      }

      try {
        final workspacesSession = await RemoteSession.init(
          instanceUrl!,
          workspace: Workspace.common,
          parameters: {
            ...RemoteSession.baseParameters,
            ...RemoteSession.delegationBypassParameters,
          },
        );

        await workspacesSession.access(const InstanceParametersAccessor());
        await workspacesSession.access(const DisconnectionAccessor.unlogged());

        for (final workspace in workspacesSession.broadInstance.workspaces) {
          try {
            final session = await RemoteSession.init(
              instanceUrl!,
              workspace: workspace,
              parameters: {
                ...RemoteSession.baseParameters,
                ...RemoteSession.delegationBypassParameters,
              },
            );

            await session.access(const InstanceParametersAccessor());
            await session.access(const DisconnectionAccessor.unlogged());

            lastApplicableParameters?.complete(session.instance);
            break;
          } catch (e, st) {
            if (kDebugMode) {
              logger.severe(
                'Could not start ${workspace.label} session at $instanceUrl',
                e,
                st,
              );
            }
          }
        }
      } catch (e) {
        return lastApplicableParameters?.complete(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.loginUrl)),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const .symmetric(horizontal: 12, vertical: 8),

              // TODO: Make it so it doesn't overflow
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
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              if (snapshot.connectionState != .done) {
                return const SliverFillRemaining(child: LoadingWidget());
              }

              if (!snapshot.hasData) {
                return SliverFillRemaining(
                  child: Center(child: Text(context.l10n.couldNotLoad)),
                );
              }

              final instance = snapshot.requireData!;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),

                sliver: SliverToBoxAdapter(
                  child: Column(
                    spacing: 8,

                    children: [
                      ListWidget.list(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        isSliver: false,

                        items: [
                          .new(
                            title: Text(context.l10n.instanceName),
                            subtitle: Text(
                              context.l10n.instanceNameValue(
                                instance.establishmentName,
                                instance.loginEstablishmentName,
                              ),
                            ),
                          ),
                          .new(
                            title: Text(context.l10n.remoteVersion),
                            subtitle: Text(instance.version.toString()),
                          ),
                          .new(
                            title: Text(context.l10n.remoteYear),
                            subtitle: Text(
                              context.l10n.remoteYearSubtitle(
                                instance.firstDate,
                                instance.lastDate,
                              ),
                            ),
                          ),
                          .new(
                            title: Text(context.l10n.remotePeriods),
                            subtitle: Text(
                              instance.periods
                                  .map(
                                    (e) =>
                                        '- ${e.name} (${e.startDate} → ${e.endDate})',
                                  )
                                  .join('\n'),
                            ),
                          ),
                        ],
                      ),

                      ButtonWidget(
                        onPressed: () async {
                          try {
                            final parameters =
                                await MobileInstanceParameters.fetch(
                                  instanceUrl!,
                                );

                            if (!context.mounted) return;

                            final result =
                                await Navigator.push<RegisterableAccount>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return WorkspacesListScreen(
                                        parameters: parameters!,
                                      );
                                    },
                                  ),
                                );

                            if (result != null && context.mounted) {
                              Navigator.pop(context, result);
                            }
                          } catch (e, st) {
                            logger.severe(
                              'Error during fetch of parameters',
                              e,
                              st,
                            );
                          }
                        },

                        label: context.l10n.loginButton,
                      ),
                    ],
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
