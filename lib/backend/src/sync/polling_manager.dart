import 'dart:convert';

import 'package:antinote_ui/backend/src/pigeon_posts/native_session.g.dart';
import 'package:antinote_ui/backend/src/session/holder.dart';

class SyncPollingManager extends PollingManager {
  SyncPollingManager({required this.state});

  final SessionDataHolder state;

  @override
  bool askToTakePolling(String accountUid) => false;

  @override
  void serverSignatureChanged(String accountUid, String newServerSignature) {
    if (state.lastSeenAccountUid == accountUid) {
      state.lastSeenSession?.stack.updateServerSignature(
        jsonDecode(newServerSignature),
      );
    }
  }

  @override
  void startPolling(String accountUid) {
    throw UnimplementedError();
  }
}
