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
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

part 'tasks/calendar.dart';
part 'tasks/notifications.dart';

Future<void> syncEntrypoint() async {
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

  await SyncRequestManager().initialize();
}

final NativeCalendarManager _calendarManager = NativeCalendarManager();

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
      libLog.severe('Failed to initialize sync manager', e, st);
      _initializer?.complete(false);

      return false;
    }
  }

  Future<bool> _doInitialization() async {
    WidgetsFlutterBinding.ensureInitialized();

    var settings = NetworkingSettings();
    if (!(await settings.initialize())) {
      libLog.warning('Failed to initialize settings, recreating.');
      await settings.clear();

      settings = NetworkingSettings();
      final result = await settings.initialize();
      if (!result) {
        libLog.severe(
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
        task: account.syncData.indexed.firstWhere(
          (element) => element.$2.type == task,
          orElse: () =>
              (-1, SyncTaskData(type: task, enabled: false)..freeze()),
        ),
    };

    if (tasks.isEmpty) return .new(result: .failure);

    final result = await registry.pickAccount(account.uid);
    if (!result) return .new(result: .failure);

    final wrapper = registry.specificSession(account.uid)!;

    try {
      final taskResults = await Future.wait(
        associatedEntries.entries.map((entry) async {
          final MapEntry(key: task, value: (index, data)) = entry;

          try {
            return await runTask(wrapper, task, data.specializedData);
          } on IOException {
            return SyncResponse(result: .retry);
          } on SessionException {
            return SyncResponse(result: .failure);
          } finally {
            final newData = data.rebuild(
              (oldData) => oldData.lastSynced = Timestamp.fromDateTime(
                DateTime.timestamp(),
              ),
            );
            if (index != -1) {
              account = account.rebuild(
                (acc) => acc..syncData[index] = newData,
              );
            } else {
              account = account.rebuild((acc) => acc..syncData.add(newData));
            }
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
    } finally {
      // TODO: Refetch the account here as maybe data is outdated.
      await registry.storage.updateAccount(account, account.uid);
    }
  }

  T _tryUnpack<T extends GeneratedMessage>(Any data, T defaultInstance) =>
      data.canUnpackInto(defaultInstance)
      ? data.unpackInto(defaultInstance)
      : defaultInstance;

  Future<SyncResponse> runTask(
    SessionWrapper wrapper,
    SyncTaskType type,
    Any data,
  ) {
    return switch (type) {
      .CALENDAR => _syncCalendar(registry, wrapper),
      .NOTIFICATIONS => _syncNotifications(
        registry,
        wrapper,
        _tryUnpack(data, SyncTaskData_Notification.getDefault()),
      ),
      _ => throw UnimplementedError('Unknown sync task: $type'),
    };
  }
}
