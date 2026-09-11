import 'dart:async';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/account_type.dart';
import 'package:antinote_app/ui/screens/settings/sync_screen.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/field.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/foundation.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with WidgetsBindingObserver, PageMixin<AccountsScreen> {
  late List<AntinoteAccount> _accounts;

  String? _defaultUid;
  String? _loggingUid;

  @override
  Future<void> loadPage() async {
    final ar = context.ar;

    _defaultUid = (await ar.storage.getDefaultAccount())?.uid;

    _accounts = await ar.storage.listAccounts();
    _accounts.sort((a, b) => a.uid == _defaultUid ? -1 : 1);

    if (_accounts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pushAccountTypeScreen(context);
      });
    }
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

  Future<void> _openAccountModal(
    BuildContext context,
    AntinoteAccount account,
  ) async {
    await showModalBottomSheet(
      backgroundColor: context.c.surfaceContainerLowest,
      isScrollControlled: true,
      showDragHandle: true,
      context: context,

      builder: (context) {
        return _AccountModal(
          account: account,
          defaultUid: _defaultUid,
          reload: reload,
        );
      },
    );
  }

  Future<void> _pushAccountTypeScreen(BuildContext context) async {
    final result = await Navigator.push<RegisterableAccount>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const AccountTypeLoginScreen();
        },
      ),
    );

    if (!context.mounted || result == null) return;
    await context.ar.registerAccount(result);

    if (mounted) await reload();
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
      floatingActionButtonAnimator: .noAnimation,
      floatingActionButton: Padding(
        padding: const .only(left: 12, right: 12),

        child: ButtonWidget(
          onPressed: () => _pushAccountTypeScreen(context),
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
                gap: 4,

                itemBuilder: (context, account, _) {
                  return TileWidget(
                    onPressed: () => _onAccountPressed(account),
                    borderRadius: const .all(ListWidget.radius),

                    padding: const .only(
                      left: 16,
                      right: 6,
                      top: 10,
                      bottom: 10,
                    ),

                    trailing: Skeleton.ignore(
                      child: IconButton(
                        onPressed: () async {
                          await _openAccountModal(context, account);
                        },
                        tooltip: context.l10n.openAccountSettings,
                        visualDensity: .comfortable,
                        icon: Icon(
                          HugeIconsSolid.settings01,
                          color: context.c.outline,
                          size: 21,
                        ),
                      ),
                    ),

                    title: Row(
                      spacing: 8,

                      children: [
                        Flexible(
                          child: Text(
                            account.name,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),

                        Row(
                          spacing: 2,

                          children: [
                            if (account.invalid)
                              Icon(
                                HugeIconsSolid.cancel02,
                                size: 17,
                                color: context.c.error,
                              ),

                            if (account.storeSecurely)
                              Icon(
                                HugeIconsSolid.biometricAccess,
                                size: 17,
                                color: context.c.primary,
                              ),

                            if (_defaultUid == account.uid)
                              Icon(
                                HugeIconsSolid.star,
                                size: 17,
                                color: context.c.secondary,
                              ),

                            if (account.isDemo)
                              Icon(
                                HugeIconsSolid.testTube02,
                                size: 17,
                                color: context.c.tertiary,
                              ),
                          ],
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

class _AccountModal extends StatefulWidget {
  final AntinoteAccount account;
  final String? defaultUid;
  final Future<void> Function() reload;

  const _AccountModal({
    required this.account,
    required this.defaultUid,
    required this.reload,
  });

  @override
  State<_AccountModal> createState() => _AccountModalState();
}

class _AccountModalState extends State<_AccountModal> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: .only(
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          right: 12,
          left: 12,
        ),

        child: Column(
          mainAxisAlignment: .spaceBetween,
          mainAxisSize: .min,
          spacing: 12,

          children: [
            Row(
              children: [
                Expanded(
                  child: FieldWidget(
                    controller: _nameController,
                    hintText: context.l10n.renameAccount,
                  ),
                ),

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, child) {
                    final show = value.text.trim() != widget.account.name;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,

                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },

                      child: show
                          ? Padding(
                              padding: const .only(left: 8),

                              child: IconButton.filledTonal(
                                key: const ValueKey('confirm'),

                                icon: const Icon(HugeIconsSolid.tick03),
                                iconSize: 20,

                                onPressed: () async {
                                  await context.ar.storage.updateAccount(
                                    widget.account.rebuild((acc) {
                                      acc.name = _nameController.text;
                                    }),
                                    widget.account.uid,
                                  );

                                  await widget.reload();

                                  if (context.mounted) Navigator.pop(context);
                                },
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    );
                  },
                ),
              ],
            ),

            ListWidget.list(
              items: [
                .new(
                  title: Text(context.l10n.autoLogin),
                  subtitle: Text(context.l10n.autoLoginSubtitle),
                  switchValue: widget.defaultUid == widget.account.uid,
                  onSwitchChanged: (value) async {
                    await context.ar.storage.setDefault(
                      value ? widget.account.uid : null,
                    );
                    await widget.reload();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),

                .new(
                  title: Text(context.l10n.secureStore),
                  subtitle: Text(context.l10n.secureStoreSubtitle),
                  switchValue: widget.account.storeSecurely,
                  onSwitchChanged: (value) async {
                    if (value == widget.account.storeSecurely) {
                      return;
                    }

                    await context.ar.storage.updateAccount(
                      widget.account.rebuild((acc) {
                        acc.storeSecurely = value;
                      }),
                      widget.account.uid,
                    );

                    await widget.reload();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),

                if (kDebugMode)
                  .new(
                    title: Text(context.l10n.accountSyncSettings),
                    trailing: const Icon(HugeIconsSolid.arrowRight01),
                    onPressed: widget.account.storeSecurely
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsSyncScreen(
                                  accountUid: widget.account.uid,
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
                await context.ar.storage.deleteAccount(widget.account.uid);
                await widget.reload();
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
  }
}
