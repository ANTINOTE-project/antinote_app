import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/backend/src/accounts/storage/widget.dart";
import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/material.dart";

void mainEntrypoint() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final SessionDataHolder _state;
  AccountRegistry? _registry;

  @override
  void initState() {
    super.initState();
    _state = SessionDataHolder.create();

    final polling = SessionPollingManager(state: _state);
    PollingManager.setUp(polling);
  }

  @override
  Widget build(BuildContext context) {
    return AccountStorageWidget(
      storage: AccountStorage.getInstance(ValueNotifier(_registry)),

      child: SessionManager(
        state: _state,

        onNewSessionSet: () {
          // Never can be too sure... Although TODO Sometimes onNewSessionSet is
          // called on multiple frames at once
          if (mounted) {
            setState(() {
              /* Updates the whole app so that widgets subscribed to any
          listener/stream from the previous session subscribe to the new one */
            });
          }
        },

        child: App(initialLocation: Routes.auth.login),
      ),
    );
  }
}
