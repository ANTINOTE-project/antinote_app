part of '../sync_manager.dart';

typedef _NotificationTypeFetchResult<T extends VisualIdMixin> =
    Map<UserResource, List<T>>;

typedef _NotificationFetchResult =
    Map<SyncTaskData_Notification_EntryType, _NotificationTypeFetchResult>;

typedef _NotificationExistingEntryData =
    Map<SyncTaskData_Notification_EntryType, Map<List<int>, List<List<int>>>>;

extension EntryTypeAvailability on SyncTaskData_Notification_EntryType {
  bool available(RemoteSession session) {
    return switch (this) {
      .INFORMATION => session.user.hasAccessToTab(NewsPageAccessor.pageId),
      .DISCUSSION => session.user.hasAccessToTab(DiscussionPageAccessor.pageId),
      .HOMEWORK => session.user.hasAccessToTab(NotebookSection.homework.pageId),
      .GRADE => session.user.hasAccessToTab(LatestGradesPageAccessor.pageId),
      .MENU => session.user.hasAccessToTab(MenuPageAccessor.pageId),

      _ => throw UnimplementedError('Unknown entry type: $name ($value)'),
    };
  }
}

Future<TaskReturnData> _syncNotifications(
  AccountRegistry registry,
  SessionWrapper wrapper,
  SyncTaskData_Notification rawData,
) async {
  final data = rawData.deepCopy();

  final errorResp = await checkPermission(
    () => Permission.notification.status,
    Permission.notification.request,
    .missingCalendarPermission,
  );
  if (errorResp != null) return .new(response: errorResp);

  final (
    _NotificationFetchResult entries,
    List<UserResource> resources,
  ) = await wrapper.runTask(
    callback: (session) async {
      _NotificationFetchResult result = {};

      final enabledEntries = data.enabledTypes.toSet();
      for (final entryType in enabledEntries) {
        if (!entryType.available(session)) {
          data.enabledTypes.removeWhere((element) => element == entryType);
          continue;
        }

        final _NotificationTypeFetchResult entryResult = {
          for (final resource in session.user.resources) resource: [],
        };
        switch (entryType) {
          case SyncTaskData_Notification_EntryType.DISCUSSION:
            for (int i = 0; i < session.user.resources.length; i++) {
              session.currentUserResourceId = i;
              final page = await session.access(
                const DiscussionPageAccessor(
                  showRead: true,
                  withMessages: false,
                ),
              );

              entryResult[session.userResource]!.addAll(page.discussions);
            }
            break;
          case SyncTaskData_Notification_EntryType.GRADE:
            for (int i = 0; i < session.user.resources.length; i++) {
              session.currentUserResourceId = i;
              final page = await session.access(
                LatestGradesPageAccessor(
                  period:
                      session.userResource.tabsForPeriods
                          .firstWhere(
                            (element) =>
                                element.location ==
                                LatestGradesPageAccessor.pageId,
                          )
                          .defaultPeriod ??
                      session.instance.defaultPeriod(
                        DateTime.now().toDay(true),
                      ),
                ),
              );

              entryResult[session.userResource]!.addAll(page.exams);
            }
            break;
          case SyncTaskData_Notification_EntryType.HOMEWORK:
            for (int i = 0; i < session.user.resources.length; i++) {
              session.currentUserResourceId = i;
              final startDay = (session.instance.demoDateTime ?? DateTime.now())
                  .toDay(true);
              final endDay = startDay.add(const .new(days: 14)).toDay();
              final range = DateRange(start: startDay, end: endDay);
              final baseWeekNumber = session.instance.getWeekNumberForDate(
                startDay,
              );
              final endWeekNumber = session.instance.getWeekNumberForDate(
                endDay,
              );

              final page = await session.access(
                NotebookPageAccessor(
                  section: .homework,
                  weeks: {
                    for (int i = baseWeekNumber; i <= endWeekNumber; i++)
                      max(
                        min(
                          i,
                          session.instance.getWeekNumberForDate(
                            session.instance.lastDate,
                          ),
                        ),
                        session.instance.firstWeekNumber,
                      ),
                  },
                ),
              );

              entryResult[session.userResource]!.addAll(
                (page.homeworkSet?.homeworks ?? []).where(
                  (element) => range.contains(element.deadlineDate),
                ),
              );
            }
            break;
          case SyncTaskData_Notification_EntryType.INFORMATION:
            for (int i = 0; i < session.user.resources.length; i++) {
              session.currentUserResourceId = i;
              final page = await session.access(
                const NewsPageAccessor.defaultMode(),
              );

              for (final collection in page.collections) {
                entryResult[session.userResource]!.addAll(collection.news);
              }
            }
            break;
          case SyncTaskData_Notification_EntryType.MENU:
            session.currentUserResourceId = 0;
            final page = await session.access(
              MenuPageAccessor(date: DateTime.now().toDay(true)),
            );

            for (final resource in session.user.resources) {
              entryResult[resource]!.add(page);
            }
            break;
        }

        result[entryType] = entryResult;
      }

      return (result, session.user.resources);
    },
    storage: registry.storage,
    options: registry.settings.sessionOptions,
    debugLabel: 'Run sync notification task',
    retry: true,
  );

  final cachedResources = {
    for (final resource in resources) resource.visualIdBytes: resource,
  };

  final _NotificationExistingEntryData existingEntries = {};
  for (final existingEntry in data.entries) {
    if (!existingEntries.containsKey(existingEntry.type)) {
      existingEntries[existingEntry.type] = {};
    }

    final resource = cachedResources[existingEntry.resourceVisualId];
    if (resource == null) continue;

    if (!existingEntries[existingEntry.type]!.containsKey(
      existingEntry.resourceVisualId,
    )) {
      existingEntries[existingEntry.type]![existingEntry.resourceVisualId] = [];
    }

    existingEntries[existingEntry.type]![existingEntry.resourceVisualId]!.add(
      existingEntry.visualId,
    );
  }

  for (final MapEntry(key: entryType, value: values) in entries.entries) {
    final existingValues = existingEntries[entryType];

    for (final MapEntry(key: resource, value: curEntries) in values.entries) {
      final resourceVisualId = resource.visualIdBytes;

      final alreadyFetched =
          existingValues != null &&
          existingValues.containsKey(resourceVisualId);
      if (!alreadyFetched) {
        logger.info(
          'Values were never fetched for resource ${resourceVisualId.toHex()}/$entryType',
        );
      }
      final existingIds = existingValues?[resourceVisualId] ?? <String>[];

      // We do not save actual data about the old entries, so we can't have a
      // useful list of deleted entries for now...
      final rawNewEntries = curEntries.where(
        (element) => !existingIds.contains(element.visualId),
      );

      for (final newEntry in rawNewEntries) {
        data.entries.add(
          .new(
            type: entryType,
            resourceVisualId: resourceVisualId,
            visualId: newEntry.visualIdBytes,
          ),
        );
      }

      // We skip to not blast the user with notifications for things they
      // probably already saw.
      if (!alreadyFetched) continue;

      switch (entryType) {
        case .DISCUSSION:
          // TODO: Handle this case.
          break;
        case .GRADE:
          // TODO: Handle this case.
          break;
        case .HOMEWORK:
          final newEntries = rawNewEntries.cast<Homework>().toList(
            growable: false,
          );

          logger.info('Posting ${newEntries.length} for homeworks');

          await _notifyHomeworks(newEntries);

          break;
        case .INFORMATION:
          // TODO: Handle this case.
          break;
        case .MENU:
          // TODO: Handle this case.
          break;
      }
    }
  }

  return .new(
    response: .new(result: .success),
    newData: Any.pack(data, typeUrlPrefix: typePrefix),
  );
}

Future<void> _notifyHomeworks(List<Homework> homeworks) async {
  final [localeCode, countryCode] = Intl.canonicalizedLocale(
    Platform.localeName,
  ).split('_');
  final l10n = lookupAppLocalizations(Locale(localeCode, countryCode));
  await initializeDateFormatting(l10n.localeName);

  for (final homework in homeworks) {
    if (homework.isDone) continue;

    final id = homework.visualId;

    final homeworksChannel = AndroidNotificationDetails(
      'fr.antinote.app.homeworks',
      l10n.homeworks,
      subText: homework.publicName,
      channelDescription: l10n.homeworksNotificationDescription,
      tag: id,
      icon: 'rounded_task_24',
      color: Color(homework.backgroundColor),
      onlyAlertOnce: true,
      colorized: true,
      channelAction: .update,
      category: .reminder,

      when: kDebugMode ? null : homework.givenDate.millisecondsSinceEpoch,
      styleInformation: const DefaultStyleInformation(true, false),
    );
    final notificationDetails = NotificationDetails(android: homeworksChannel);

    await _notificationPlugin.show(
      id: 0,
      title: l10n.newHomework(homework.subject.name!, homework.deadlineDate),
      body: homework.description,
      notificationDetails: notificationDetails,
      payload: id,
    );
  }
}
