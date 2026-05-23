import "package:antinote_app/frontend/extensions/account_storage.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/extensions/session_manager.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/account.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/main.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<AntinoteAccount>? _accounts;

  String? _defaultUid;
  String? _loggingUid;

  bool _loaded = false;

  Future<void> _load() async {
    final accounts = await context.as.listAccounts();

    if (mounted) {
      final defaultAccount = await context.as.getDefaultAccount();

      setState(() {
        _accounts = accounts;
        _defaultUid = defaultAccount?.uid;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _popLoad() async {
    context.pop();
    await _load();
  }

  Future<void> _onAccountPressed(AntinoteAccount account) async {
    if (_loggingUid != null) return;

    setState(() {
      _loggingUid = account.uid;
    });

    final sm = context.sm;
    final beforeUid = sm.state.lastSeenAccountUid;

    try {
      sm.state.lastSeenAccountUid = _loggingUid;

      await sm.runTask(
        context: context,

        bypassStateLock: true,
        channels: const [],

        callback: (session) {
          talker.info("Logged in with session ID ${session.stack.sessionId}!");
        },
      );

      if (mounted) await _popLoad();
    } catch (e, st) {
      talker.error("Something happened during login", e, st);

      sm.state.lastSeenAccountUid = beforeUid;

      setState(() {
        _loggingUid = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.choseAnAccount, backButton: false),

      body: _buildBody(),

      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: .centerFloat,
    );
  }

  Widget _buildBody() {
    return _accounts == null ? _buildLoading() : _buildList();
  }

  Widget _buildLoading() {
    return const Center(child: LoadingWidget(size: 30));
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 70),

      child: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemCount: _accounts?.length,
            itemBuilder: (context, index) {
              final account = _accounts?[index];
              if (account == null) return null;

              return AccountWidget(
                account: account,

                isLoggingIn: _loggingUid == account.uid,
                isDefault: _defaultUid == account.uid,

                onPressed: () => _onAccountPressed(account),

                onRemoveDefault: () async {
                  await context.as.setDefault(null);
                  await _popLoad();
                },

                onSetDefault: () async {
                  await context.as.setDefault(account.uid);
                  await _popLoad();
                },

                onDelete: () async {
                  await context.as.deleteAccount(account.uid);
                  await _popLoad();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Align(
      alignment: Alignment.bottomCenter,

      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),

          child: ButtonWidget(
            onPressed: () async {
              final result = await context.push(Routes.auth.pick);

              if (result != null && mounted) {
                await _load();
              }
            },

            icon: HugeIconsSolid.add02,
            label: context.l10n.addAnAccount,
          ),
        ),
      ),
    );
  }
}
