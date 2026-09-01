import 'package:antinote_app/data/data.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';

class SettingsSyncScreen extends StatefulWidget {
  const SettingsSyncScreen({super.key, required this.accountUid});

  final String accountUid;

  @override
  State<SettingsSyncScreen> createState() => _SettingsSyncScreenState();
}

class _SettingsSyncScreenState extends State<SettingsSyncScreen>
    with PageMixin<SettingsSyncScreen> {
  bool accountFound = false;

  late SyncTaskData calendarData;
  late SyncTaskData notificationData;

  late Map<SyncTaskData_Notification_EntryType, bool> availableTypes;

  bool accountValid(AntinoteAccount? account) =>
      account != null && !account.storeSecurely;

  Future<void> saveCalendarData() async {
    final ar = context.ar;

    final account = await context.ar.storage.getAccount(widget.accountUid);

    if (!accountValid(account)) {
      accountFound = false;
      return;
    }

    await ar.storage.updateAccount(
      account!.rebuild((acc) => acc..calendarData = calendarData),
      widget.accountUid,
    );

    calendarData = calendarData.deepCopy();
  }

  Future<void> saveNotificationData() async {
    final ar = context.ar;

    final account = await context.ar.storage.getAccount(widget.accountUid);

    if (!accountValid(account)) {
      accountFound = false;
      return;
    }

    await ar.storage.updateAccount(
      account!.rebuild((acc) => acc..notificationData = notificationData),
      widget.accountUid,
    );

    notificationData = notificationData.deepCopy();
  }

  Future<bool>? runningSync;

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    final appBar = AppBarWidget(title: Text(context.l10n.accountSyncSettings));

    if (!accountFound) {
      return Scaffold(
        appBar: appBar,
        body: buildRefreshIndicator(
          child: Center(child: Text(context.l10n.accountNotFound)),
        ),
      );
    }

    return FutureBuilder(
      future: runningSync,
      builder: (context, snapshot) {
        final syncing = <ConnectionState>[
          .active,
          .waiting,
        ].contains(snapshot.connectionState);

        return Scaffold(
          appBar: appBar,
          floatingActionButtonLocation: .centerFloat,
          floatingActionButton: Padding(
            padding: const .symmetric(horizontal: 12),
            child: Builder(
              builder: (context) {
                if (syncing) {
                  return ButtonWidget(
                    enabled: false,
                    onPressed: () {
                      context.ar.storage.cancelManualSync(widget.accountUid);
                    },
                    icon: HugeIconsSolid.stop,
                    label: context.l10n.syncing,
                    variant: .dangerous,
                  );
                }

                if (snapshot.data == null) {
                  return ButtonWidget(
                    onPressed: () {
                      setState(() {
                        runningSync = context.ar.storage.manuallySync(
                          widget.accountUid,
                        );
                      });
                    },
                    label: context.l10n.syncAll,
                    variant: .secondary,
                  );
                } else if (snapshot.data == true) {
                  return ButtonWidget(
                    onPressed: () {
                      setState(() {
                        runningSync = context.ar.storage.manuallySync(
                          widget.accountUid,
                        );
                      });
                    },
                    label: context.l10n.syncSuccessful,
                    variant: .tertiary,
                  );
                } else {
                  return ButtonWidget(
                    onPressed: () {
                      setState(() {
                        runningSync = context.ar.storage.manuallySync(
                          widget.accountUid,
                        );
                      });
                    },
                    label: context.l10n.syncFailed,
                  );
                }
              },
            ),
          ),
          body: buildRefreshIndicator(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomScrollView(
                slivers: [
                  ListWidget.list(
                    items: [
                      .new(
                        title: Text(context.l10n.calendarSync),
                        subtitle: Text(context.l10n.calendarSyncSubtitle),

                        trailing: Switch(
                          value: calendarData.enabled,
                          onChanged: syncing
                              ? null
                              : (value) async {
                                  if (!(await Permission
                                      .calendarFullAccess
                                      .isGranted)) {
                                    await Permission.calendarFullAccess
                                        .request();
                                  }

                                  if (!(await Permission
                                      .calendarFullAccess
                                      .isGranted)) {
                                    value = false;
                                  }

                                  calendarData.enabled = value;
                                  await saveCalendarData();
                                  if (mounted) setState(() {});
                                },
                        ),
                      ),
                    ],
                  ),

                  const SliverPadding(padding: .only(top: 12)),

                  Builder(
                    builder: (context) {
                      final notificationSettings = notificationData
                          .specializedData
                          .unpackInto(SyncTaskData_Notification.create());

                      Widget createSwitch(
                        SyncTaskData_Notification_EntryType type,
                      ) {
                        return Switch(
                          value: notificationSettings.enabledTypes.contains(
                            type,
                          ),
                          onChanged: availableTypes[type]! && !syncing
                              ? (value) async {
                                  if (!(await Permission
                                      .notification
                                      .isGranted)) {
                                    await Permission.notification.request();
                                  }

                                  if (!(await Permission
                                      .notification
                                      .isGranted)) {
                                    value = false;
                                  }

                                  if (value) {
                                    notificationData.enabled = true;
                                    notificationSettings.enabledTypes.add(type);
                                  } else {
                                    notificationSettings.enabledTypes.remove(
                                      type,
                                    );

                                    if (notificationSettings
                                        .enabledTypes
                                        .isEmpty) {
                                      notificationData.enabled = false;
                                    }
                                  }

                                  notificationData.specializedData = Any.pack(
                                    notificationSettings,
                                    typeUrlPrefix: typePrefix,
                                  );
                                  await saveNotificationData();
                                  if (mounted) setState(() {});
                                }
                              : null,
                        );
                      }

                      return ListWidget.list(
                        items: [
                          .new(
                            title: Text(context.l10n.newsSync),
                            subtitle: Text(context.l10n.newsSyncSubtitle),

                            trailing: createSwitch(.INFORMATION),
                          ),
                          .new(
                            title: Text(context.l10n.discussionSync),
                            subtitle: Text(context.l10n.discussionSyncSubtitle),

                            trailing: createSwitch(.DISCUSSION),
                          ),
                          .new(
                            title: Text(context.l10n.homeworkSync),
                            subtitle: Text(context.l10n.homeworkSyncSubtitle),

                            trailing: createSwitch(.HOMEWORK),
                          ),
                          .new(
                            title: Text(context.l10n.gradeSync),
                            subtitle: Text(context.l10n.gradeSyncSubtitle),

                            trailing: createSwitch(.GRADE),
                          ),
                          .new(
                            title: Text(context.l10n.menuSync),
                            subtitle: Text(context.l10n.menuSyncSubtitle),

                            trailing: createSwitch(.MENU),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Future<void> loadPage() async {
    final ar = context.ar;
    final account = await ar.storage.getAccount(widget.accountUid);

    if (!accountValid(account)) {
      accountFound = false;
      return;
    }

    accountFound = true;

    calendarData = account!.hasCalendarData()
        ? account.calendarData.deepCopy()
        : SyncTaskData(type: .CALENDAR);
    notificationData = account.hasNotificationData()
        ? account.notificationData.deepCopy()
        : SyncTaskData(
            type: .NOTIFICATIONS,
            specializedData: Any.pack(
              SyncTaskData_Notification.create(),
              typeUrlPrefix: typePrefix,
            ),
          );

    if (!ar.managesAccount(widget.accountUid)) {
      await ar.loadAccount(widget.accountUid, pick: false);
    }
    await ar.runRawTask(
      callback: (session) {
        availableTypes = {
          for (final type in SyncTaskData_Notification_EntryType.values)
            type: type.available(session),
        };
      },
      channels: {},
      forceAccountId: widget.accountUid,
      debugLabel: 'Check which notification types can be fetched',
    );
  }
}
