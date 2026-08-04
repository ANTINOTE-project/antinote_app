import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_sync.g.dart';
import 'package:antinote_app/ui/entrypoints/login.dart';
import 'package:antinote_app/ui/entrypoints/main.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:talker/talker.dart';

final talker = Talker();

@pragma('vm:entry-point')
void main() => mainEntrypoint();

@pragma('vm:entry-point')
void loginMain() => loginEntrypoint();

@pragma('vm:entry-point')
Future<void> syncMain(List<String> args) async {
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

  SyncResponse? response;

  try {
    // response = await syncTask(args.first);
  } finally {
    await NativeSyncManager().syncFinished(
      response ?? SyncResponse(result: .failure),
    );
  }
}
