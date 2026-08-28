import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/data/src/pigeon_posts/native_sync.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/app/src/main/kotlin/fr/antinote/antinote_app/pigeon_posts/NativeSync.g.kt',
    kotlinOptions: KotlinOptions(
      errorClassName: 'SyncManagerError',
      package: 'fr.antinote.studies_management.antinote_app.pigeon_posts',
    ),
    dartPackageName: 'antinote_app',
  ),
)
//
//
enum SyncResultType {
  /// When the sync completes successfully.
  success,

  /// When we can't access the remote or have temporary issues.
  retry,

  /// When the credentials are invalid or the feature is unavailable.
  failure,
}

enum SyncMessageType {
  missingCalendarPermission,
  missingNotificationPermission,
}

final class SyncRequest {
  /// The account protobuf (without credentials) to perform the task.
  final Uint8List account;

  /// The ID of the sync request type that may be forced (although it is may be
  /// disabled).
  final List<int>? forcedScope;

  const SyncRequest({required this.account, required this.forcedScope});
}

final class SyncResponse {
  /// The result for the sync task.
  final SyncResultType result;

  const SyncResponse({required this.result});
}

@FlutterApi()
abstract class SyncManager {
  @async
  SyncResponse syncAccount(SyncRequest request);
}

@HostApi()
abstract class NativeSyncManager {
  /// We use this as we can't easily know the locale in a non-Flutter
  /// environment.
  void displayMessage(SyncMessageType messageType);
}
