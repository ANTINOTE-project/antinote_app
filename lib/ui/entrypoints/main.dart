import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/backend.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/accounts/storage/widget.dart';
import 'package:antinote_app/data/src/settings/registry.dart';
import 'package:antinote_app/ui/app.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Future<void> mainEntrypoint() async {
  hierarchicalLoggingEnabled = true;
  libLog.onRecord.listen((event) {
    print('[${event.level.name}] ${event.message}');
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
  runApp(MainApp(settingsRegistry: registry));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.settingsRegistry});

  final SettingsRegistry settingsRegistry;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AccountRegistry registry;
  final ValueNotifier<SerializedAccountRegistry?> _accountsRegistry =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    registry = AccountRegistry(
      storage: AccountStorage.create(_accountsRegistry),
      settings: widget.settingsRegistry.networking,
    );

    final polling = SessionPollingManager(registry: registry);
    PollingManager.setUp(polling);
  }

  @override
  Widget build(BuildContext context) {
    return AccountScope(
      registry: registry,
      child: App(
        initialLocation: Routes.appShell,
        registry: widget.settingsRegistry,
      ),
    );
  }
}
