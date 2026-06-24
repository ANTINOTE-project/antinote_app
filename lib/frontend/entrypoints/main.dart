import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/backend/src/accounts/storage/widget.dart";
import "package:antinote_app/backend/src/settings/registry.dart";
import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/material.dart";

Future<void> mainEntrypoint() async {
  WidgetsFlutterBinding.ensureInitialized();

  final registry = SettingsRegistry();
  await registry.initialize();
  runApp(MainApp(settingsRegistry: registry));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.settingsRegistry});

  final SettingsRegistry settingsRegistry;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final SessionDataHolder _state;
  final ValueNotifier<AccountRegistry?> _accountsRegistry = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _state = SessionDataHolder.create(
      settings: widget.settingsRegistry.networking,
    );

    final polling = SessionPollingManager(state: _state);
    PollingManager.setUp(polling);
  }

  @override
  Widget build(BuildContext context) {
    return AccountScope(
      storage: AccountStorage.create(_accountsRegistry),
      child: SessionManager(
        state: _state,
        child: App(
          initialLocation: Routes.appShell,
          registry: widget.settingsRegistry,
        ),
      ),
    );
  }
}
