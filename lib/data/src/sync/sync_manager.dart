import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/data.dart';
import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/calendar/to_event.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_calendar.g.dart';
import 'package:antinote_app/data/src/pigeon_posts/native_sync.g.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/data/src/settings/networking.dart';
import 'package:antinote_app/data/src/sync/polling_manager.dart';
import 'package:antinote_app/ui/l10n/app_localizations.dart';
import 'package:antinote_app/ui/utils/src/date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart' hide Element;
import 'package:permission_handler/permission_handler.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

part 'tasks/calendar.dart';
part 'tasks/notifications.dart';

final _logger = Logger('SyncManager');

Future<void> syncEntrypoint() async {
  hierarchicalLoggingEnabled = true;
  _logger.level = .ALL;
  _logger.onRecord.listen((event) {
    debugPrint('[${event.level.name}] ${event.message}');
    if (event.error != null) {
      debugPrintStack(
        stackTrace: event.stackTrace,
        label: event.error.toString(),
      );
    }
  });
  _logger.level = .ALL;
  _logger.onRecord.listen((event) {
    debugPrint('SYNC: [${event.level.name}] ${event.message}');
    if (event.error != null) {
      debugPrintStack(
        stackTrace: event.stackTrace,
        label: event.error.toString(),
      );
    }
  });

  await SyncRequestManager().initialize();
}

final NativeCalendarManager _calendarManager = NativeCalendarManager();
final FlutterLocalNotificationsPlugin _notificationPlugin =
    FlutterLocalNotificationsPlugin();

Future<SyncResponse?> checkPermission(
  Future<PermissionStatus> Function() getStatus,
  Future<PermissionStatus> Function() request,
  SyncMessageType missingMessage,
) async {
  final status = await getStatus();

  if (!status.isGranted) {
    final newStatus = status.isPermanentlyDenied ? status : await request();

    if (!newStatus.isGranted) {
      await SyncRequestManager.nativeSync.displayMessage(missingMessage);
      return SyncResponse(result: .failure);
    }
  }

  return null;
}

final class const TaskReturnData({
  required final SyncResponse response,
  final Any? newData,
});

final class SyncRequestManager extends SyncManager {
  static final nativeSync = NativeSyncManager();

  late final AccountRegistry registry;
  late final SyncPollingManager pollingManager;

  Completer<bool>? _initializer;

  bool get initialized => _initializer?.isCompleted == true;

  Future<bool> initialize() async {
    if (_initializer != null) return await _initializer!.future;
    _initializer = Completer();

    try {
      final result = await _doInitialization();
      _initializer!.complete(result);

      return result;
    } catch (e, st) {
      _logger.severe('Failed to initialize sync manager', e, st);
      _initializer?.complete(false);

      return false;
    }
  }

  Future<bool> _doInitialization() async {
    WidgetsFlutterBinding.ensureInitialized();

    var settings = NetworkingSettings();
    if (!(await settings.initialize())) {
      _logger.warning('Failed to initialize settings, recreating.');
      await settings.clear();

      settings = NetworkingSettings();
      final result = await settings.initialize();
      if (!result) {
        _logger.severe(
          'Failed to initialize settings a second time. Aborting...',
        );
        return false;
      }
    }

    registry = AccountRegistry(
      storage: AccountStorage.create(ValueNotifier(null)),
      settings: settings,
    );

    pollingManager = SyncPollingManager(registry: registry);

    SyncManager.setUp(this);

    return true;
  }

  List<SyncTaskType> determineAvailableTaskTypes(AntinoteAccount account) {
    return account.syncData
        .where((element) => element.enabled)
        .map((e) => e.type)
        .toList(growable: false);
  }

  @override
  Future<SyncResponse> syncAccount(SyncRequest request) async {
    if (_initializer != null) {
      await _initializer!.future;
    }

    if (!initialized) {
      throw UnimplementedError(
        'Tried to sync account but initialization failed.',
      );
    }

    var account = AntinoteAccount.fromBuffer(request.account)..freeze();

    final tasks = request.forcedScope != null
        ? request.forcedScope!.map((e) => SyncTaskType.valueOf(e)!).toSet()
        : determineAvailableTaskTypes(account).toSet();

    final associatedEntries = {
      for (final task in tasks)
        task: account.syncData.firstWhere(
          (element) => element.type == task,
          orElse: () => SyncTaskData(type: task, enabled: false)..freeze(),
        ),
    };

    if (tasks.isEmpty) return .new(result: .failure);

    final result = await registry.loadAccount(account.uid, pick: false);
    if (!result) return .new(result: .failure);

    final wrapper = registry.specificSession(account.uid)!;

    final taskResults = await Future.wait(
      associatedEntries.entries.map((entry) async {
        final MapEntry(key: task, value: data) = entry;

        var tempData = data.deepCopy();

        try {
          final taskResult = await runTask(
            wrapper,
            task,
            tempData.specializedData,
          );

          if (taskResult.newData != null) {
            tempData.specializedData = taskResult.newData!;
          }

          return taskResult.response;
        } on IOException {
          return SyncResponse(result: .retry);
        } on SessionException {
          return SyncResponse(result: .failure);
        } finally {
          tempData.lastSynced = Timestamp.fromDateTime(DateTime.timestamp());

          account = (await registry.storage.getAccount(account.uid)) ?? account;

          account = account.rebuild((acc) {
            switch (task) {
              case SyncTaskType.CALENDAR:
                acc.calendarData = tempData;
                break;
              case SyncTaskType.NOTIFICATIONS:
                acc.notificationData = tempData;
                break;
            }
          });

          await registry.storage.updateAccount(account, account.uid);
        }
      }),
    );

    // I am making up those rules, this probably isn't right.
    if (taskResults.any((element) => element.result == .retry)) {
      return SyncResponse(result: .retry);
    }

    if (taskResults.every((element) => element.result == .failure)) {
      return SyncResponse(result: .failure);
    }

    return SyncResponse(result: .success);
  }

  T _tryUnpack<T extends GeneratedMessage>(Any data, T defaultInstance) =>
      data.canUnpackInto(defaultInstance)
      ? data.unpackInto(defaultInstance)
      : defaultInstance;

  Future<TaskReturnData> runTask(
    SessionWrapper wrapper,
    SyncTaskType type,
    Any data,
  ) {
    return switch (type) {
      .CALENDAR => _syncCalendar(registry, wrapper),
      .NOTIFICATIONS => _syncNotifications(
        registry,
        wrapper,
        _tryUnpack(data, SyncTaskData_Notification.create()),
      ),
      _ => throw UnimplementedError('Unknown sync task: $type'),
    };
  }
}
