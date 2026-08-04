import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/accounts/storage/base.dart';
import 'package:antinote_app/data/src/accounts/storage/widget.dart';
import 'package:antinote_app/data/src/settings/registry.dart';
import 'package:antinote_app/ui/app.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Future<void> loginEntrypoint() async {
  hierarchicalLoggingEnabled = true;
  libLog.level = .ALL;
  libLog.onRecord.listen((event) {
    debugPrint('[${event.level.name}] ${event.message}');
    if (event.error != null) {
      debugPrintStack(
        stackTrace: event.stackTrace,
        label: event.error.toString(),
      );
    }
  });

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
  final ValueNotifier<SerializedAccountRegistry?> _accountsRegistry =
      ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return AccountScope(
      registry: AccountRegistry(
        storage: AccountStorage.create(_accountsRegistry),
        settings: widget.settingsRegistry.networking,
      ),
      child: App(
        initialLocation: Routes.auth.methods,
        registry: widget.settingsRegistry,
      ),
    );
  }
}
