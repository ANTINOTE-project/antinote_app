import 'dart:convert';

import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_session.g.dart';

class SyncPollingManager extends PollingManager {
  SyncPollingManager({required this.registry});

  final AccountRegistry registry;

  @override
  bool askToTakePolling(String accountUid) => false;

  @override
  void serverSignatureChanged(String accountUid, String newServerSignature) {
    if (registry.managesAccount(accountUid)) {
      Future.microtask(() async {
        await registry.pickAccount(accountUid);
        registry.runRawTask(
          callback: (session) {
            session.stack.updateServerSignature(jsonDecode(newServerSignature));
          },
          debugLabel: 'Updating server signature',
        );
      });
    }
  }

  @override
  void startPolling(String accountUid) {
    throw UnimplementedError();
  }
}
