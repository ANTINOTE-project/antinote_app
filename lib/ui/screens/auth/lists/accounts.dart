import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/lists/methods.dart';
import 'package:antinote_app/ui/screens/settings/sync_screen.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/foundation.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AccountsListScreen extends StatefulWidget {
  const AccountsListScreen({super.key});

  @override
  State<AccountsListScreen> createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends State<AccountsListScreen>
    with WidgetsBindingObserver, PageMixin<AccountsListScreen> {
  late List<AntinoteAccount> _accounts;

  String? _defaultUid;
  String? _loggingUid;

  @override
  Future<void> loadPage() async {
    final ar = context.ar;

    _defaultUid = (await ar.storage.getDefaultAccount())?.uid;

    _accounts = await ar.storage.listAccounts();
    _accounts.sort((a, b) => a.uid == _defaultUid ? -1 : 1);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> _onAccountPressed(AntinoteAccount account) async {
    if (_loggingUid != null) return;

    final ar = context.ar;

    if (ar.accountPicked) {
      if (ar.curAccountUid == account.uid) {
        Navigator.pop(context);
        return;
      }

      ar.unpickAccount();
    }

    setState(() {
      _loggingUid = account.uid;
    });

    final result = await ar.loadAccount(account.uid);

    if (!result && context.mounted) {
      logger.warning('Failed to pick account...');

      setState(() {
        _loggingUid = null;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> openAccountModal(
    BuildContext context,
    AntinoteAccount account,
  ) async {
    await showModalBottomSheet(
      showDragHandle: true,
      context: context,

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const .only(left: 12, right: 12, bottom: 16),
            child: Column(
              spacing: 12,
              mainAxisSize: .min,
              mainAxisAlignment: .spaceBetween,

              children: [
                ListWidget.list(
                  items: [
                    .new(
                      title: Text(context.l10n.autoLogin),
                      subtitle: Text(context.l10n.autoLoginSubtitle),
                      trailing: Switch(
                        value: _defaultUid == account.uid,
                        onChanged: (value) async {
                          await context.ar.storage.setDefault(
                            value ? account.uid : null,
                          );
                          await reload();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    .new(
                      title: Text(context.l10n.secureStore),
                      subtitle: Text(context.l10n.secureStoreSubtitle),
                      trailing: Switch(
                        value: account.storeSecurely,
                        onChanged: (value) async {
                          if (value == account.storeSecurely) {
                            return;
                          }

                          await context.ar.storage.updateAccount(
                            account.rebuild((acc) {
                              acc.storeSecurely = value;
                            }),
                            account.uid,
                          );
                          await reload();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),

                    if (kDebugMode)
                      .new(
                        title: Text(context.l10n.accountSyncSettings),
                        trailing: const Icon(HugeIconsSolid.arrowRight01),
                        onPressed: account.storeSecurely
                            ? null
                            : () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsSyncScreen(
                                      accountUid: account.uid,
                                    ),
                                  ),
                                );
                              },
                      ),
                  ],
                  isColumn: true,
                  isSliver: false,
                ),

                ButtonWidget(
                  onPressed: () async {
                    await context.ar.storage.deleteAccount(account.uid);
                    await reload();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  variant: .dangerous,
                  icon: HugeIconsSolid.delete02,
                  label: context.l10n.deleteAccount,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.ar.accountPicked,
      child: super.build(context),
    );
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    return Scaffold(
      appBar: AppBarWidget(
        title: Text(context.l10n.chooseAnAccount),
        titleAlign: .center,
        backButton: false,
      ),

      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),

        child: ButtonWidget(
          onPressed: () async {
            final result = await Navigator.push<RegisterableAccount>(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const MethodsListScreen();
                },
              ),
            );

            if (!context.mounted || result == null) return;
            await context.ar.registerAccount(result);

            if (mounted) await reload();
          },

          icon: HugeIconsSolid.add02,
          label: context.l10n.addAnAccount,
        ),
      ),

      body: buildRefreshIndicator(
        child: Padding(
          padding: const .only(left: 12, right: 12, bottom: 70),

          child: CustomScrollView(
            slivers: [
              ListWidget(
                items: _accounts,
                itemBuilder: (context, account, borderRadius) {
                  return TileWidget(
                    onPressed: () => _onAccountPressed(account),
                    borderRadius: borderRadius,

                    trailing: Skeleton.ignore(
                      child: IconButton(
                        onPressed: () async {
                          await openAccountModal(context, account);
                        },
                        tooltip: context.l10n.openAccountSettings,
                        icon: Icon(
                          HugeIconsSolid.settings01,
                          color: context.c.outline,
                        ),
                      ),
                    ),

                    onLongPress: () async {
                      await openAccountModal(context, account);
                    },

                    title: Row(
                      spacing: 6,

                      children: [
                        Flexible(
                          child: Text(
                            account.name,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),

                        if (account.invalid)
                          Icon(
                            HugeIconsSolid.cancel02,
                            size: 20,
                            color: context.c.error,
                          ),

                        if (account.storeSecurely)
                          Icon(
                            HugeIconsSolid.biometricAccess,
                            size: 20,
                            color: context.c.primary,
                          ),

                        if (_defaultUid == account.uid)
                          Icon(
                            HugeIconsSolid.star,
                            size: 20,
                            color: context.c.secondary,
                          ),

                        if (account.isDemo)
                          Icon(
                            HugeIconsSolid.testTube02,
                            size: 20,
                            color: context.c.tertiary,
                          ),
                      ],
                    ),

                    subtitle: Column(
                      crossAxisAlignment: .start,

                      children: [
                        if (account.establishmentName.trim().isNotEmpty)
                          Text(account.establishmentName),

                        if (account.workspaceName.trim().isNotEmpty)
                          Text(account.workspaceName),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
