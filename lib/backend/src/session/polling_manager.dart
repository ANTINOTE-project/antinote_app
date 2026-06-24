import "dart:convert";
import "dart:io";
import "dart:math";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/pigeon_posts/native_session.g.dart";
import "package:antinote_app/backend/src/session/holder.dart";
import "package:antinote_app/main.dart";
import "package:flutter/foundation.dart";

final NativeSessionManager _sessionManager = NativeSessionManager();

// TODO: Sometimes, the signature is sent through communication request, we
//  don't propagate those yet.
class SessionPollingManager extends PollingManager {
  SessionPollingManager({required this.state});

  final SessionDataHolder state;
  final Random jitterRandom = Random();

  @override
  bool askToTakePolling(String accountUid) {
    final answer =
        state.lastSeenAccountUid == accountUid && state.lastSeenSession != null;
    talker.info("Got asked whether to take polling job... Answered $answer");
    return answer;
  }

  static const _baseDelay = Duration(milliseconds: 400);
  static const maxJitterMilliseconds = 100;
  static const _maxRetries =
      11; // This is the max as the session closes after 2 minutes.

  @override
  void startPolling(String accountUid) {
    talker.info("Starting polling...");
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
              if (restartCount > 0) {
                final backoffTime = _baseDelay * (1 << (restartCount - 1));

                await Future.pause(
                  Duration(
                    milliseconds: jitterRandom.nextInt(
                      backoffTime.inMilliseconds,
                    ),
                  ),
                );
              }

              if (restartCount > 0) {
                await Future.delayed(
                  Duration(
                    milliseconds: Random().nextInt(maxJitterMilliseconds),
                  ),
                );
              }

              final newPoll = await session.access(const PollingAccessor());

              restartCount = 0;

              if (mapEquals(lastPoll, newPoll)) continue;

              lastPoll = newPoll;

              await _sessionManager.updatePollingState(
                accountUid,
                .alive,
                jsonEncode(newPoll),
              );
            } on SessionException {
              await _sessionManager.updatePollingState(accountUid, .dead, null);
              break;
            } on IOException {
              restartCount += 1;
              talker.info("Polling just failed for the ${restartCount}th time");

              if (restartCount >= _maxRetries) {
                await _sessionManager.updatePollingState(
                  accountUid,
                  .dead,
                  null,
                );
                break;
              } else {
                await _sessionManager.updatePollingState(
                  accountUid,
                  .paused,
                  null,
                );
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
    state.lastSeenSession?.stack.updateServerSignature(
      jsonDecode(newServerSignature),
    );
  }
}
