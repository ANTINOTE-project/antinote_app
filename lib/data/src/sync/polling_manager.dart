import 'dart:convert';

import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_session.g.dart';

class SyncPollingManager extends PollingManager {
  SyncPollingManager({required this.registry});

  final AccountRegistry registry;

  @override
  Future<bool> askToTakePolling(String accountUid) async => false;

  @override
  Future<void> startPolling(String accountUid) {
    throw UnimplementedError();
  }

  @override
  Future<void> serverSignatureChanged(
    String accountUid,
    String newServerSignature,
  ) async {
    if (registry.managesAccount(accountUid)) {
      Future.microtask(() async {
        final result = registry.specificSession(accountUid);
        if (result == null) return;

        result.unsafeSession?.stack.updateServerSignature(
          jsonDecode(newServerSignature),
        );
      });
    }
  }

  @override
  Future<void> pollingUpdated(String accountUid, PollingState newState) async {
    if (registry.managesAccount(accountUid)) {
      Future.microtask(() async {
        final result = registry.specificSession(accountUid);
        if (result == null) return;

        result.updatePollingState(newState);
      });
    }
  }
}
