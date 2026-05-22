import "package:antinote_app/backend/src/accounts/storage/base.dart";
import "package:antinote_app/frontend/extensions/account_storage.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/material.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<AntinoteAccount>? accounts;
  String? defaultAccountUid;

  String? loggingAccountUid;
  bool finishedLogin = false;

  Future<void> reloadList() async {
    final accounts = await context.AS.listAccounts();

    if (!mounted) return;

    final defaultAccount = await AccountStorage.of(context).getDefaultAccount();
    if (mounted) {
      setState(() {
        this.accounts = accounts;
        defaultAccountUid = defaultAccount?.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(context.l10n.choseAnAccount)));
  }
}
