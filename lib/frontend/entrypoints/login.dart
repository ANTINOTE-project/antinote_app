import 'package:antinote_app/backend/src/accounts/storage/base.dart';
import 'package:antinote_app/backend/src/accounts/storage/widget.dart';
import 'package:antinote_app/backend/src/settings/registry.dart';
import 'package:antinote_app/frontend/app.dart';
import 'package:antinote_app/frontend/routing/routes.dart';
import 'package:antinote_app/protos/account.pb.dart';
import 'package:flutter/material.dart';

Future<void> loginEntrypoint() async {
  WidgetsFlutterBinding.ensureInitialized();

  final registry = SettingsRegistry();
  await registry.initialize();
  runApp(LoginApp(settingsRegistry: registry));
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key, required this.settingsRegistry});

  final SettingsRegistry settingsRegistry;

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final ValueNotifier<AccountRegistry?> _accountsRegistry = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return AccountScope(
      storage: AccountStorage.create(_accountsRegistry),
      child: App(
        initialLocation: Routes.auth.methods,
        registry: widget.settingsRegistry,
      ),
    );
  }
}
