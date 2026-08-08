import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/lists/methods_list.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
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

    _accounts = await ar.storage.listAccounts();
    _defaultUid = (await ar.storage.getDefaultAccount())?.uid;
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

    final result = await ar.pickAccount(account.uid);

    if (!result && context.mounted) {
      libLog.warning('Failed to pick account...');

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.ar.accountPicked,
      onPopInvokedWithResult: (didPop, result) =>
          libLog.info('Salut $didPop ${context.ar.curAccountUid}'),
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
        title: Text(context.l10n.choseAnAccount),
        backButton: false,
      ),

      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,

        child: SafeArea(
          child: Padding(
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
        ),
      ),

      body: buildRefreshIndicator(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 70),

          child: CustomScrollView(
            slivers: [
              ListWidget(
                items: _accounts,
                itemBuilder: (context, account, borderRadius) {
                  return ItemWidget(
                    onPressed: () => _onAccountPressed(account),
                    borderRadius: borderRadius,

                    onLongPress: () async {
                      await showModalBottomSheet(
                        showDragHandle: true,
                        context: context,

                        builder: (context) {
                          return SafeArea(
                            child: Padding(
                              padding: MediaQuery.viewInsetsOf(context),

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),

                                child: Column(
                                  mainAxisSize: .min,
                                  spacing: 4,

                                  children: [
                                    ButtonWidget(
                                      onPressed: () async {
                                        await context.ar.storage.setDefault(
                                          _defaultUid == account.uid
                                              ? null
                                              : account.uid,
                                        );
                                        await reload();

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },

                                      label: _defaultUid == account.uid
                                          ? context.l10n.disableAutoLogin
                                          : context.l10n.enableAutoLogin,
                                      icon: _defaultUid == account.uid
                                          ? HugeIconsSolid.starOff
                                          : HugeIconsSolid.star,
                                    ),

                                    ButtonWidget(
                                      onPressed: () async {
                                        await context.ar.storage.updateAccount(
                                          account.rebuild((acc) {
                                            acc.storeSecurely =
                                                !acc.storeSecurely;
                                          }),
                                          account.uid,
                                        );
                                        await reload();

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },

                                      icon: HugeIconsSolid.biometricAccess,
                                      label: account.storeSecurely
                                          ? context.l10n.disableSecureStore
                                          : context.l10n.enableSecureStore,
                                      variant: .secondary,
                                    ),

                                    ButtonWidget(
                                      onPressed: () async {
                                        await context.ar.storage.deleteAccount(
                                          account.uid,
                                        );
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
                            ),
                          );
                        },
                      );
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
                            size: 18,
                            color: context.c.secondary,
                          ),
                      ],
                    ),

                    subtitle: Column(
                      crossAxisAlignment: .start,

                      children: [
                        Text(
                          account.establishmentName,
                          style: const TextStyle(fontSize: 14),
                        ),

                        Text(
                          account.workspaceName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),

                    trailing: Skeleton.ignore(
                      child: Icon(
                        HugeIconsSolid.arrowRight01,
                        color: context.c.outline,
                      ),
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
