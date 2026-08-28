// This is a generated file - do not edit.
//
// Generated from protos/account.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SyncTaskType extends $pb.ProtobufEnum {
  /// Sync the calendar between the remote and the client (timetable and agenda). This can only be
  /// done when [AntinoteAccount.store_securely] is [false].
  static const SyncTaskType CALENDAR =
      SyncTaskType._(0, _omitEnumNames ? '' : 'CALENDAR');

  /// Sync notifications between the remote and the client (homework, grades, cancellation,
  /// communication...). This can only be done when [AntinoteAccount.store_securely] is [false].
  static const SyncTaskType NOTIFICATIONS =
      SyncTaskType._(1, _omitEnumNames ? '' : 'NOTIFICATIONS');

  static const $core.List<SyncTaskType> values = <SyncTaskType>[
    CALENDAR,
    NOTIFICATIONS,
  ];

  static final $core.List<SyncTaskType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SyncTaskType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SyncTaskType._(super.value, super.name);
}

class SyncTaskData_Notification_EntryType extends $pb.ProtobufEnum {
  static const SyncTaskData_Notification_EntryType INFORMATION =
      SyncTaskData_Notification_EntryType._(
          0, _omitEnumNames ? '' : 'INFORMATION');
  static const SyncTaskData_Notification_EntryType DISCUSSION =
      SyncTaskData_Notification_EntryType._(
          1, _omitEnumNames ? '' : 'DISCUSSION');
  static const SyncTaskData_Notification_EntryType HOMEWORK =
      SyncTaskData_Notification_EntryType._(
          2, _omitEnumNames ? '' : 'HOMEWORK');
  static const SyncTaskData_Notification_EntryType GRADE =
      SyncTaskData_Notification_EntryType._(3, _omitEnumNames ? '' : 'GRADE');
  static const SyncTaskData_Notification_EntryType MENU =
      SyncTaskData_Notification_EntryType._(4, _omitEnumNames ? '' : 'MENU');

  static const $core.List<SyncTaskData_Notification_EntryType> values =
      <SyncTaskData_Notification_EntryType>[
    INFORMATION,
    DISCUSSION,
    HOMEWORK,
    GRADE,
    MENU,
  ];

  static final $core.List<SyncTaskData_Notification_EntryType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SyncTaskData_Notification_EntryType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SyncTaskData_Notification_EntryType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
