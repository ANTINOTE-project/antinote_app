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
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

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

final class SyncRequestManager extends SyncManager {
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
          orElse: () => (-1, SyncTaskData(type: task, enabled: false)),
        ),
    };

    if (tasks.isEmpty) return .new(result: .failure);

    final result = await registry.pickAccount(account.uid);
    if (!result) return .new(result: .failure);

    final wrapper = registry.specificSession(account.uid)!;

    try {
      for (final MapEntry(key: task, value: (index, data))
          in associatedEntries.entries) {
        try {
          final res = await runTask(wrapper, task, data.specializedData);

          if (res.result != .success) {
            return res;
          }
        } on IOException {
          return SyncResponse(result: .retry);
        } on SessionException {
          return SyncResponse(result: .failure);
        } finally {
          final newData = data
            ..lastSynced = Timestamp.fromDateTime(DateTime.timestamp())
            ..freeze();
          if (index != -1) {
            account = account.rebuild((acc) => acc..syncData[index] = newData);
          } else {
            account = account.rebuild((acc) => acc..syncData.add(newData));
          }
        }
      }

      return SyncResponse(result: .success);
    } finally {
      // TODO: Refetch the account here as maybe data is outdated.
      await registry.storage.updateAccount(account, account.uid);
    }
  }

  Future<SyncResponse> runTask(
    SessionWrapper wrapper,
    SyncTaskType type,
    Any data,
  ) {
    return switch (type) {
      .CALENDAR => syncCalendar(wrapper),
      .NOTIFICATIONS => syncNotifications(wrapper),
      _ => throw UnimplementedError('Unknown sync task: $type'),
    };
  }

  static final NativeCalendarManager _calendarManager = NativeCalendarManager();

  Future<SyncResponse> syncCalendar(SessionWrapper wrapper) async {
    final (timetables, user, instanceDomain, address) = await wrapper.runTask(
      callback: (session) async {
        final timetables = <UserResource, List<RecurringClass<Class>>>{};
        for (final resource in session.user.resources) {
          final recurringTimetable = (await session.access(
            TimetableAccessor.forYear(
              resource: session.userResource,
              session: session,
            ),
          )).asRecurringTimetable(session);
          if (recurringTimetable.recurringClasses == null) continue;
          timetables[resource] = recurringTimetable.recurringClasses!;
        }

        return (
          timetables,
          session.user,
          session.stack.baseUrl.authority,
          session.instance.establishmentName,
        );
      },
      storage: registry.storage,
      options: registry.settings.sessionOptions,
      debugLabel: 'Run sync calendar task',
      retry: true,
    );

    final existingCalendars = await _calendarManager.listCalendars(
      wrapper.accountUid,
    );
    for (final MapEntry(key: resource, value: timetable)
        in timetables.entries) {
      final resourceVisualId = resource.visualId;
      var calendar = existingCalendars
          .cast<ExistingCalendarEntry?>()
          .firstWhere(
            (element) => element!.resourceVisualId == resourceVisualId,
            orElse: () => null,
          );
      if (calendar == null) {
        final colorId = Random().nextInt(Colors.accents.length);
        calendar = await _calendarManager.insertNewCalendar(
          NewCalendarEntry(
            displayName:
                'Cours${user.name == resource.name ? '' : ' (${resource.name})'}',
            accountUid: wrapper.accountUid,
            resourceVisualId: resourceVisualId,
            color: Colors.accents[colorId].toARGB32(),
          ),
        );
      }
      final localEntriesMap = <String, List<ExistingCalendarEventEntry>>{};
      final rawCalendarEntries = await _calendarManager.listExisting(
        wrapper.accountUid,
        calendar.id,
      );
      for (final entry in rawCalendarEntries) {
        final groupId = entry.originalVisualId ?? entry.visualId;
        localEntriesMap.putIfAbsent(groupId, () => []).add(entry);
      }
      final toDelete = <ExistingCalendarEventEntry>[];
      final toInsert = <NewRecurringCalendarEventEntry>[];
      final timetableEntries = timetable.mapL(
        (e) => e.toNewRecurringCalendarEventEntry(
          wrapper.accountUid,
          calendar!.id,
          instanceDomain,
          address,
        ),
        true,
      );
      for (final remoteEntry in timetableEntries) {
        final baseId = remoteEntry.visualId;
        final localGroup = localEntriesMap.remove(baseId);
        if (localGroup == null) {
          toInsert.add(remoteEntry);
          continue;
        }
        final remoteIds = {
          remoteEntry.visualId,
          ...remoteEntry.exceptions.map((e) => e.visualId),
        };
        final localIds = localGroup.map((e) => e.visualId).toSet();
        if (!setEquals(remoteIds, localIds)) {
          toDelete.addAll(localGroup);
          toInsert.add(remoteEntry);
        }
      }
      for (final leftoverLocalGroup in localEntriesMap.values) {
        toDelete.addAll(leftoverLocalGroup);
      }
      try {
        if (toDelete.isNotEmpty) {
          await _calendarManager.deleteExisting(toDelete);
        }
        if (toInsert.isNotEmpty) {
          await _calendarManager.insertNew(toInsert);
        }
      } catch (e, st) {
        libLog.severe('Failed to update calendar', e, st);

        rethrow;
      }
    }

    return SyncResponse(result: .success);
  }

  Future<SyncResponse> syncNotifications(SessionWrapper wrapper) async {
    // TODO
    return SyncResponse(result: .success);
  }
}
