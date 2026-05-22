import "package:antinote_app/frontend/extensions/account_storage.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/account.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<AntinoteAccount>? _accounts;

  String? _defaultAccountUid;
  String? _loggingAccountUid;

  final bool _finishedLogin = false;
  bool _loaded = false;

  Future<void> _load() async {
    final accounts = await context.AS.listAccounts();

    if (mounted) {
      final defaultAccount = await context.AS.getDefaultAccount();

      setState(() {
        _accounts = accounts;
        _defaultAccountUid = defaultAccount?.uid;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.choseAnAccount)),
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: accounts.length,

      itemBuilder: (_, index) {
        final account = accounts[index];

        return AccountWidget(
          account: account,

          isLoggingIn: _loggingAccountUid == account.uid,
          isDefault: _defaultAccountUid == account.uid,

          onRemoveDefault: () async {
            await context.AS.setDefault(null);

            if (mounted) {
              context.pop();
              _load();
            }
          },

          onSetDefault: () async {
            await context.AS.setDefault(account.uid);

            if (mounted) {
              context.pop();
              _load();
            }
          },

          onDelete: () async {
            await context.AS.deleteAccount(account.uid);

            if (mounted) {
              context.pop();
              _load();
            }
          },
        );
      },
    );
  }
}
