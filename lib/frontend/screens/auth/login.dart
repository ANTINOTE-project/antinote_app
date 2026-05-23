import "package:antinote_app/frontend/extensions/account_storage.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/extensions/session_manager.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/account.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/main.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
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
    final accounts = await context.AS.listAccounts();

    if (mounted) {
      final defaultAccount = await context.AS.getDefaultAccount();

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

    final sm = context.SM;
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

      // catch
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
      appBar: AppBar(
        title: Text(context.l10n.choseAnAccount, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _accounts == null ? _buildLoading() : _buildList();
  }

  Widget _buildLoading() {
    return const Center(child: LoadingWidget(size: 30));
  }

  Widget _buildList() {
    final accounts = Utils.guard(_accounts);

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 70),

          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,

          scrollCacheExtent: const ScrollCacheExtent.pixels(500),

          itemCount: accounts.length,
          itemExtent: 98,

          itemBuilder: (_, index) {
            final account = accounts[index];

            return AccountWidget(
              key: ValueKey(account.uid),
              account: account,

              isLoggingIn: _loggingUid == account.uid,
              isDefault: _defaultUid == account.uid,

              onPressed: () => _onAccountPressed(account),

              onRemoveDefault: () async {
                await context.AS.setDefault(null);
                if (mounted) await _popLoad();
              },

              onSetDefault: () async {
                await context.AS.setDefault(account.uid);
                if (mounted) await _popLoad();
              },

              onDelete: () async {
                await context.AS.deleteAccount(account.uid);
                if (mounted) await _popLoad();
              },
            );
          },
        ),

        Align(
          alignment: Alignment.bottomCenter,

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),

              child: ButtonWidget(
                onPressed: () async {
                  final result = await context.push(Routes.auth.pick);

                  if (result != null && mounted) {
                    await _popLoad();
                  }
                },

                icon: HugeIconsSolid.add02,
                label: context.l10n.addAnAccount,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
