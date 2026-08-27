import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/data.dart';
import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/accounts/storage/widget.dart';
import 'package:antinote_app/data/src/settings/registry.dart';
import 'package:antinote_app/ui/app.dart';
import 'package:antinote_app/ui/screens/shell/shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';

Future<void> mainEntrypoint() async {
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

  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'SN Pro',
    ], await rootBundle.loadString('assets/fonts/OFL.txt', cache: false));
  });

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
      child: App(home: const AppShell(), registry: widget.settingsRegistry),
    );
  }
}
