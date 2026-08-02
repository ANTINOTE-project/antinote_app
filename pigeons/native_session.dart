import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/backend/src/pigeon_posts/native_session.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/app/src/main/kotlin/fr/antinote/antinote_app/pigeon_posts/NativeSession.g.kt',
    kotlinOptions: KotlinOptions(
      errorClassName: 'SessionManagerError',
      package: 'fr.antinote.studies_management.antinote_app.pigeon_posts',
    ),
    dartPackageName: 'antinote_app',
  ),
)
//
//
enum PollingState {
  /// When the instance disables polling (deprecated afaik) or no client has
  /// offered to do the polling.
  unavailable,

  /// When the session is actually dead and we haven't reconnected yet.
  dead,

  /// When the client responsible for polling has temporarily lost its ability
  /// to do polling.
  paused,

  /// When polling works.
  alive,
}

final class ScheduledTask {
  final Uint8List? session;
  final int sessionVersion;
  final int taskId;

  const ScheduledTask({
    required this.session,
    required this.sessionVersion,
    required this.taskId,
  });
}

/// It is the responsibility of the native side to manage everything going on
/// with the client registration.
@HostApi()
abstract class NativeSessionManager {
  void setCurrentAccountsListener(List<String> accountUid);

  @async
  ScheduledTask scheduleTask(
    String accountUid,
    List<String> channels,
    int? lastSessionVersion,
    String? debugLabel,
  );

  @async
  int? finishTask(String accountUid, int taskId, Uint8List? newSession);

  @async
  int registerSession(String accountUid, Uint8List session);

  @async
  PollingState getPollingState(String accountUid);

  void updatePollingState(
    String accountUid,
    PollingState newState,
    String? newServerSignature,
  );
}

@FlutterApi()
abstract class PollingManager {
  /// Used to ask the client whether it can send polling requests and report
  /// back the state to the service.
  ///
  /// The return value is whether the client takes the job.
  bool askToTakePolling(String accountUid);

  void startPolling(String accountUid);

  void serverSignatureChanged(String accountUid, String newServerSignature);
}
