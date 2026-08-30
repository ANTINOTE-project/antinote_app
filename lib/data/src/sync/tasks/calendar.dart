part of '../sync_manager.dart';

Future<TaskReturnData> _syncCalendar(
  AccountRegistry registry,
  SessionWrapper wrapper,
) async {
  final errorResp = await checkPermission(
    () => Permission.calendarFullAccess.status,
    Permission.calendarFullAccess.request,
    .missingCalendarPermission,
  );
  if (errorResp != null) return .new(response: errorResp);

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
      logger.severe('Failed to update calendar', e, st);

      rethrow;
    }
  }

  return .new(response: .new(result: .success));
}
