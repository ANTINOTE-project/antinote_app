import "package:antinote_app/backend/src/pigeon_posts/native_sync.g.dart";
import "package:antinote_app/backend/src/sync/task.dart";
import "package:antinote_app/frontend/entrypoints/login.dart";
import "package:antinote_app/frontend/entrypoints/main.dart";
import "package:flutter/material.dart";

@pragma("vm:entry-point")
void main() => mainEntrypoint();

@pragma("vm:entry-point")
void loginMain() => loginEntrypoint();

@pragma("vm:entry-point")
Future<void> syncMain(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  SyncResult? result;

  try {
    result = await syncTask(args.first);
  } finally {
    await NativeSyncManager().syncFinished(
      result ??
          SyncResult(
            result: .availability,
            totalEntries: 0,
            addedEntries: 0,
            removedEntries: 0,
            updatedEntries: 0,
            dbIssue: false,
          ),
    );
  }
}
