import "package:pigeon/pigeon.dart";

@ConfigurePigeon(
  PigeonOptions(
    dartOut: "lib/backend/src/pigeon_posts/native_sync.g.dart",
    dartOptions: DartOptions(),
    kotlinOut: "android/app/src/main/kotlin/fr/helomri/antinote_app/pigeon_posts/NativeSync.g.kt",
    kotlinOptions: KotlinOptions(
      errorClassName: "SyncManagerError",
      package: "fr.helomri.studies_management.antinote_app.pigeon_posts",
    ),
    dartPackageName: "antinote_app",
  ),
)
//
//
@HostApi()
abstract class NativeSyncManager {
  void syncFinished(SyncResult result);
}

enum SyncResultType {
  /// When the sync completes successfully.
  success,

  /// When we get an invalid login exception.
  auth,

  /// When we lose or never get to contact the PRONOTE instance.
  availability,

  /// When we have trouble actually parsing the different elements or writing
  /// them to system.
  parsing,
}

final class SyncResult {
  final SyncResultType result;

  final int totalEntries;
  final int addedEntries;
  final int removedEntries;
  final int updatedEntries;

  final bool dbIssue;

  const SyncResult({
    required this.result,
    required this.totalEntries,
    required this.addedEntries,
    required this.removedEntries,
    required this.updatedEntries,
    required this.dbIssue,
  });
}
