import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_session.g.dart';
import 'package:antinote_app/main.dart';
import 'package:flutter/foundation.dart';

final NativeSessionManager _sessionManager = NativeSessionManager();

// TODO: Sometimes, the signature is sent through communication request, we
//  don't propagate those yet.
class SessionPollingManager extends PollingManager {
  SessionPollingManager({required this.registry});

  final AccountRegistry registry;
  final Random jitterRandom = Random();

  @override
  bool askToTakePolling(String accountUid) {
    final answer = registry.curAccountUid == accountUid;
    talker.info('Got asked whether to take polling job... Answered $answer');
    return answer;
  }

  static const _baseDelay = Duration(milliseconds: 400);
  static const maxJitterMilliseconds = 100;
  static const _maxRetries =
      11; // This is the max as the session closes after 2 minutes.

  @override
  void startPolling(String accountUid) {
    talker.info('Starting polling...');

    Future.microtask(() async {
      var wrapper = registry.specificSession(accountUid);
      if (wrapper == null) {
        final result = await registry.pickAccount(accountUid);

        if (!result) {
          await _sessionManager.updatePollingState(accountUid, .dead, null);
          return;
        }

        wrapper = registry.specificSession(accountUid)!;
      }

      await wrapper.runTask(
        options: registry.settings.sessionOptions,
        storage: registry.storage,
        sendSession: false,
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

              await _sessionManager.updatePollingState(
                accountUid,
                .alive,
                mapEquals(lastPoll, newPoll) ? null : jsonEncode(newPoll),
              );

              lastPoll = newPoll;
            } on SessionException {
              await _sessionManager.updatePollingState(accountUid, .dead, null);
              break;
            } on IOException {
              restartCount += 1;
              talker.info('Polling just failed for the ${restartCount}th time');

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
        channels: {'polling'},
        debugLabel: 'Run polling client',
      );
    });
  }

  @override
  void serverSignatureChanged(String accountUid, String newServerSignature) {
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
