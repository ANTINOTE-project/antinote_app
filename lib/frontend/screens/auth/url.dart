import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/main.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class LoginUrlScreen extends StatefulWidget {
  const LoginUrlScreen({super.key});

  @override
  State<LoginUrlScreen> createState() => _LoginUrlScreenState();
}

class _LoginUrlScreenState extends State<LoginUrlScreen> {
  final _controller = TextEditingController(
    text: kDebugMode ? "https://demo.index-education.net/pronote" : null,
  );
  Timer? _debounce;

  Completer<SpecificInstanceParameters?>? lastApplicableParameters;
  Uri? instanceUrl;

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
      instanceUrl = Uri.tryParse(_controller.text.trim());

      if (instanceUrl == null) {
        return lastApplicableParameters?.complete(null);
      }

      try {
        final workspacesSession = await RemoteSession.init(
          instanceUrl!,
          workspace: Workspace.common,
        );

        await workspacesSession.access(const InstanceParametersAccessor());
        await workspacesSession.access(const DisconnectionAccessor.unlogged());

        for (final workspace in workspacesSession.broadInstance.workspaces) {
          try {
            final session = await RemoteSession.init(
              instanceUrl!,
              workspace: workspace,
            );

            await session.access(const InstanceParametersAccessor());
            await session.access(const DisconnectionAccessor.unlogged());

            lastApplicableParameters?.complete(session.instance);
            break;

            // catch
          } catch (e, st) {
            if (kDebugMode) {
              talker.error(
                "Could not start ${workspace.label} session at $instanceUrl",
                e,
                st,
              );
            }
          }
        }

        // catch
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
              if (snapshot.connectionState == ConnectionState.none) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              if (snapshot.connectionState != ConnectionState.done) {
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
                      ListWidget(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        isSliver: false,

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
                            title: context.l10n.remotePeriods,
                            subtitle: instance.periods
                                .map(
                                  (e) =>
                                      "- ${e.name} (${e.startDate} → ${e.endDate})",
                                )
                                .join("\n"),
                          ),
                        ],

                        itemBuilder: (context, item, borderRadius) {
                          return ItemWidget(
                            borderRadius: borderRadius,

                            titleMaxLines: null,
                            title: Text(item.title),
                            subtitleMaxLines: null,
                            subtitle: Text(item.subtitle),
                          );
                        },
                      ),

                      ButtonWidget(
                        onPressed: () async {
                          try {
                            final parameters =
                                await MobileInstanceParameters.fetch(
                                  instanceUrl!,
                                );

                            if (!context.mounted) return;

                            final result = await context.push<LoginResult>(
                              Routes.auth.workspace,
                              extra: {"parameters": parameters},
                            );

                            if (result != null && context.mounted) {
                              context.pop(result);
                            }

                            // catch
                          } catch (e, st) {
                            talker.error(
                              "Error during fetch of parameters",
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
