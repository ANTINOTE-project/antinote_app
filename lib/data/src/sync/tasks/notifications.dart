part of '../sync_manager.dart';

typedef _NotificationTypeFetchResult<T extends VisualIdMixin> =
    Map<UserResource, List<T>>;

typedef _NotificationFetchResult =
    Map<SyncTaskData_Notification_EntryType, _NotificationTypeFetchResult>;

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

Future<SyncResponse> _syncNotifications(
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
  if (errorResp != null) return errorResp;

  final _NotificationFetchResult entries = await wrapper.runTask(
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
              final page = await session.access(
                NotebookPageAccessor.upcoming(
                  section: .homework,
                  date: DateTime.now().toDay(true),
                ),
              );

              entryResult[session.userResource]!.addAll(page.entries);
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
      }

      return result;
    },
    storage: registry.storage,
    options: registry.settings.sessionOptions,
    debugLabel: 'Run sync notification task',
    retry: true,
  );

  // TODO: Compare entries to previous version to determine which notifications
  // TODO: to send. Add a flag so that less data is loaded when on measured
  // TODO: network. Save the data to the account once finished.

  return SyncResponse(result: .success);
}
