import "dart:math";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/accounts/storage/native.dart";
import "package:antinote_app/backend/src/calendar/to_event.dart";
import "package:antinote_app/backend/src/pigeon_posts/native_calendar.g.dart";
import "package:antinote_app/backend/src/pigeon_posts/native_session.g.dart";
import "package:antinote_app/backend/src/pigeon_posts/native_sync.g.dart";
import "package:antinote_app/backend/src/session/holder.dart";
import "package:antinote_app/backend/src/sync/polling_manager.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

const _accountStorage = NativeAccountStorage();
final _calendarManager = NativeCalendarManager();

typedef FetchResult = ({
  Map<UserResource, List<RecurringClass<Class>>> timetables,
  UserParameters user,
  String instanceDomain,
  String address,
});

Future<SyncResult> syncTask(String accountUid) async {
  final account = await _accountStorage.borrowAccountWithCredentials(
    accountUid,
  );

  final state = SessionDataHolder.create(account);

  PollingManager.setUp(SyncPollingManager(state: state));

  late final SyncResult syncResult;

  final fetchResult = await state
      .runTask<FetchResult?>(
        sessionEnsurer: () => state.ensureSession(storage: _accountStorage),
        callback: (session) async {
          await session.ensurePage(16);

          final map = <UserResource, List<RecurringClass<Class>>>{};

          for (final resource in session.user.resources) {
            final recurringTimetable = (await session.access(
              TimetableAccessor.forYear(
                resource: session.userResource,
                session: session,
              ),
            )).asRecurringTimetable(session);

            if (recurringTimetable.recurringClasses == null) continue;

            map[resource] = recurringTimetable.recurringClasses!;
          }

          return (
            timetables: map,
            user: session.user,
            instanceDomain: session.stack.baseUrl.authority,
            address: session.instance.establishmentName,
          );
        },
      )
      .onError<AuthException>((error, stackTrace) {
        syncResult = SyncResult(
          result: .auth,
          totalEntries: 0,
          addedEntries: 0,
          removedEntries: 0,
          updatedEntries: 0,
          dbIssue: false,
        );

        return null;
      })
      .onError<SessionException>((error, stackTrace) {
        syncResult = SyncResult(
          result: .parsing,
          totalEntries: 0,
          addedEntries: 0,
          removedEntries: 0,
          updatedEntries: 0,
          dbIssue: false,
        );

        return null;
      });

  if (fetchResult == null) {
    return syncResult;
  }

  final (
    timetables: timetables,
    user: user,
    instanceDomain: instanceDomain,
    address: address,
  ) = fetchResult;

  int added = 0;
  int updated = 0;
  int removed = 0;

  final existingCalendars = await _calendarManager.listCalendars(accountUid);

  for (final MapEntry(key: resource, value: timetable) in timetables.entries) {
    final resourceVisualId = resource.visualId;

    var calendar = existingCalendars.cast<ExistingCalendarEntry?>().firstWhere(
      (element) => element!.resourceVisualId == resourceVisualId,
      orElse: () => null,
    );

    if (calendar == null) {
      final colorId = Random().nextInt(Colors.accents.length);

      calendar = await _calendarManager.insertNewCalendar(
        NewCalendarEntry(
          displayName:
              'Cours${user.name == resource.name ? '' : ' (${resource.name})'}',
          accountUid: accountUid,
          resourceVisualId: resourceVisualId,
          color: Colors.accents[colorId].toARGB32(),
        ),
      );
    }

    final localEntriesMap = <String, List<ExistingCalendarEventEntry>>{};
    final rawCalendarEntries = await _calendarManager.listExisting(
      accountUid,
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
        accountUid,
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
        added++;
        toInsert.add(remoteEntry);
        continue;
      }

      final remoteIds = {
        remoteEntry.visualId,
        ...remoteEntry.exceptions.map((e) => e.visualId),
      };
      final localIds = localGroup.map((e) => e.visualId).toSet();

      if (!setEquals(remoteIds, localIds)) {
        updated++;
        toDelete.addAll(localGroup);
        toInsert.add(remoteEntry);
      }
    }

    for (final leftoverLocalGroup in localEntriesMap.values) {
      removed++;
      toDelete.addAll(leftoverLocalGroup);
    }

    try {
      if (toDelete.isNotEmpty) {
        await _calendarManager.deleteExisting(toDelete);
      }
      if (toInsert.isNotEmpty) {
        await _calendarManager.insertNew(toInsert);
      }
    } catch (_) {
      // TODO: Add logging here for debug purposes.
      return SyncResult(
        result: .parsing,
        totalEntries: added + removed + updated,
        addedEntries: added,
        removedEntries: removed,
        updatedEntries: updated,
        dbIssue: true,
      );
    }
  }

  return SyncResult(
    result: .success,
    totalEntries: added + removed + updated,
    addedEntries: added,
    removedEntries: removed,
    updatedEntries: updated,
    dbIssue: false,
  );
}
