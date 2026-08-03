import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with WidgetsBindingObserver {
  static final List<AntinoteAccount> _fakeAccounts = List.filled(
    5,
    AntinoteAccount(
      name: 'fake account name',
      establishmentName: 'fake establishment',
      workspaceName: 'fake workspace',
    ),
  );

  List<AntinoteAccount>? _accounts;

  String? _defaultUid;
  String? _loggingUid;

  bool _loaded = false;

  Future<void> _load() async {
    final accounts = await context.ar.storage.listAccounts();

    if (mounted) {
      final defaultAccount = await context.ar.storage.getDefaultAccount();

      setState(() {
        _accounts = accounts;
        _defaultUid = defaultAccount?.uid;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _onAccountPressed(AntinoteAccount account) async {
    if (_loggingUid != null) return;

    setState(() {
      _loggingUid = account.uid;
    });

    final result = await context.ar.pickAccount(account.uid);

    if (!result && context.mounted) {
      setState(() {
        _loggingUid = null;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.ar.accountPicked,

      child: Scaffold(
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
                  final result = await context.push(Routes.auth.methods);

                  if (result != null && mounted) {
                    await _load();
                  }
                },

                icon: HugeIconsSolid.add02,
                label: context.l10n.addAnAccount,
              ),
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 70),

          child: CustomScrollView(
            slivers: [
              ListWidget(
                items: _accounts == null ? _fakeAccounts : _accounts!,
                isLoading: _accounts == null,

                itemBuilder: (context, account, borderRadius) {
                  return ItemWidget(
                    borderRadius: borderRadius,

                    onPressed: () => _onAccountPressed(account),

                    onLongPress: () async {
                      await showModalBottomSheet(
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
                                  spacing: 8,

                                  children: [
                                    if (_defaultUid == account.uid)
                                      ButtonWidget(
                                        onPressed: () async {
                                          await context.ar.storage.setDefault(
                                            null,
                                          );
                                          await _load();

                                          if (context.mounted) {
                                            context.pop();
                                          }
                                        },

                                        label: context.l10n.disableAutoLogin,
                                      )
                                    else
                                      ButtonWidget(
                                        onPressed: () async {
                                          await context.ar.storage.setDefault(
                                            account.uid,
                                          );
                                          await _load();

                                          if (context.mounted) {
                                            context.pop();
                                          }
                                        },

                                        label: context.l10n.enableAutoLogin,
                                      ),

                                    ButtonWidget(
                                      onPressed: () async {
                                        await context.ar.storage.deleteAccount(
                                          account.uid,
                                        );
                                        await _load();

                                        if (context.mounted) {
                                          context.pop();
                                        }
                                      },

                                      isDangerous: true,
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

                        if (_defaultUid == account.uid)
                          Icon(
                            HugeIconsSolid.star,
                            size: 18,
                            color: context.c.primary,
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
