import "dart:convert";
import "dart:io";
import "dart:math";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/pigeon_posts/native_session.g.dart";
import "package:antinote_app/backend/src/session/holder.dart";
import "package:flutter/foundation.dart";

final NativeSessionManager _sessionManager = NativeSessionManager();

// TODO: Sometimes, the signature is sent through communication request, we
//  don't propagate those yet.
class SessionPollingManager extends PollingManager {
  SessionPollingManager({required this.state});

  final SessionDataHolder state;

  @override
  bool askToTakePolling(String accountUid) {
    print(
      "Got asked whether to take polling job... Answered ${state.lastSeenAccountUid == accountUid && state.lastSeenSession != null}",
    );
    return state.lastSeenAccountUid == accountUid && state.lastSeenSession != null;
  }

  static const _baseDelay = Duration(milliseconds: 500);
  static const maxJitterMilliseconds = 100;
  static const _maxRetries = 8; // This is the max as the session closes after 2 minutes.

  @override
  void startPolling(String accountUid) {
    print("Starting polling...");
    Future.microtask(() async {
      await state.runTask(
        sessionEnsurer: () => throw UnimplementedError(
          "Being asked to do "
          "polling normally implies already listening to the account.",
        ),
        callback: (session) async {
          var lastPoll = <String, dynamic>{};
          var restartCount = 0;
          while (true) {
            try {
              await Future.delayed(_baseDelay * (2 ^ restartCount));

              if (restartCount > 0) {
                await Future.delayed(Duration(milliseconds: Random().nextInt(maxJitterMilliseconds)));
              }

              final newPoll = await session.access(const PollingAccessor());

              restartCount = 0;

              if (mapEquals(lastPoll, newPoll)) continue;

              lastPoll = newPoll;

              await _sessionManager.updatePollingState(accountUid, .alive, jsonEncode(newPoll));
            } on SessionException {
              await _sessionManager.updatePollingState(accountUid, .dead, null);
              break;
            } on IOException {
              restartCount += 1;
              print("Polling just failed for the ${restartCount}th time");

              if (restartCount >= _maxRetries) {
                await _sessionManager.updatePollingState(accountUid, .dead, null);
                break;
              } else {
                await _sessionManager.updatePollingState(accountUid, .paused, null);
              }
            }
          }
        },
        channels: ["polling"],
      );
    });
  }

  @override
  void serverSignatureChanged(String accountUid, String newServerSignature) {
    state.lastSeenSession?.stack.updateServerSignature(jsonDecode(newServerSignature));
  }
}
