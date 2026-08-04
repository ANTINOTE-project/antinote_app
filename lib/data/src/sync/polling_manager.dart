import 'dart:convert';

import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_session.g.dart';

class SyncPollingManager extends PollingManager {
  SyncPollingManager({required this.registry});

  final AccountRegistry registry;

  @override
  bool askToTakePolling(String accountUid) => false;

  @override
  void startPolling(String accountUid) {
    throw UnimplementedError();
  }

  @override
  void serverSignatureChanged(String accountUid, String newServerSignature) {
    if (registry.managesAccount(accountUid)) {
      Future.microtask(() async {
        final result = registry.specificSession(accountUid);
        if (result == null) return;

        await result.runTask(
          storage: registry.storage,
          options: registry.settings.sessionOptions,
          callback: (session) {
            session.stack.updateServerSignature(jsonDecode(newServerSignature));
          },
          channels: const {},
          debugLabel: 'Updating server signature',
          // We can sometimes send the polling session after the communication
          // session and the old communication order is the one ending up in
          // storage...
          sendSession: false,
        );
      });
    }
  }

  @override
  void pollingUpdated(String accountUid, PollingState newState) {
    if (registry.managesAccount(accountUid)) {
      Future.microtask(() async {
        final result = registry.specificSession(accountUid);
        if (result == null) return;

        result.updatePollingState(newState);
      });
    }
  }
}
