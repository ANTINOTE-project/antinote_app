import "package:antinote_app/backend/src/accounts/storage/base.dart";
import "package:antinote_app/backend/src/accounts/storage/widget.dart";
import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/material.dart";

void loginEntrypoint() {
  runApp(const LoginApp());
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  AccountRegistry? _registry;

  @override
  Widget build(BuildContext context) {
    return AccountStorageWidget(
      storage: AccountStorage.getInstance(ValueNotifier(_registry)),
      child: App(initialLocation: Routes.auth.pick),
    );
  }
}
