// This is a generated file - do not edit.
//
// Generated from protos/account.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use syncTaskTypeDescriptor instead')
const SyncTaskType$json = {
  '1': 'SyncTaskType',
  '2': [
    {'1': 'CALENDAR', '2': 0},
    {'1': 'NOTIFICATIONS', '2': 1},
  ],
};

/// Descriptor for `SyncTaskType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List syncTaskTypeDescriptor = $convert.base64Decode(
    'CgxTeW5jVGFza1R5cGUSDAoIQ0FMRU5EQVIQABIRCg1OT1RJRklDQVRJT05TEAE=');

@$core.Deprecated('Use syncTaskDataDescriptor instead')
const SyncTaskData$json = {
  '1': 'SyncTaskData',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.antinote_app.SyncTaskType',
      '10': 'type'
    },
    {
      '1': 'last_synced',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastSynced'
    },
    {'1': 'enabled', '3': 3, '4': 1, '5': 8, '10': 'enabled'},
    {
      '1': 'specialized_data',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '9': 0,
      '10': 'specializedData',
      '17': true
    },
  ],
  '3': [SyncTaskData_Notification$json],
  '8': [
    {'1': '_specialized_data'},
  ],
};

@$core.Deprecated('Use syncTaskDataDescriptor instead')
const SyncTaskData_Notification$json = {
  '1': 'Notification',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.antinote_app.SyncTaskData.Notification.Entry',
      '10': 'entries'
    },
    {
      '1': 'enabled_types',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.antinote_app.SyncTaskData.Notification.EntryType',
      '10': 'enabledTypes'
    },
  ],
  '3': [SyncTaskData_Notification_Entry$json],
  '4': [SyncTaskData_Notification_EntryType$json],
};

@$core.Deprecated('Use syncTaskDataDescriptor instead')
const SyncTaskData_Notification_Entry$json = {
  '1': 'Entry',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.antinote_app.SyncTaskData.Notification.EntryType',
      '10': 'type'
    },
    {'1': 'visual_id', '3': 2, '4': 1, '5': 9, '10': 'visualId'},
  ],
};

@$core.Deprecated('Use syncTaskDataDescriptor instead')
const SyncTaskData_Notification_EntryType$json = {
  '1': 'EntryType',
  '2': [
    {'1': 'INFORMATION', '2': 0},
    {'1': 'DISCUSSION', '2': 1},
    {'1': 'HOMEWORK', '2': 2},
    {'1': 'GRADE', '2': 3},
    {'1': 'MENU', '2': 4},
  ],
};

/// Descriptor for `SyncTaskData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncTaskDataDescriptor = $convert.base64Decode(
    'CgxTeW5jVGFza0RhdGESLgoEdHlwZRgBIAEoDjIaLmFudGlub3RlX2FwcC5TeW5jVGFza1R5cG'
    'VSBHR5cGUSOwoLbGFzdF9zeW5jZWQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1w'
    'UgpsYXN0U3luY2VkEhgKB2VuYWJsZWQYAyABKAhSB2VuYWJsZWQSRAoQc3BlY2lhbGl6ZWRfZG'
    'F0YRgEIAEoCzIULmdvb2dsZS5wcm90b2J1Zi5BbnlIAFIPc3BlY2lhbGl6ZWREYXRhiAEBGu0C'
    'CgxOb3RpZmljYXRpb24SRwoHZW50cmllcxgBIAMoCzItLmFudGlub3RlX2FwcC5TeW5jVGFza0'
    'RhdGEuTm90aWZpY2F0aW9uLkVudHJ5UgdlbnRyaWVzElYKDWVuYWJsZWRfdHlwZXMYAiADKA4y'
    'MS5hbnRpbm90ZV9hcHAuU3luY1Rhc2tEYXRhLk5vdGlmaWNhdGlvbi5FbnRyeVR5cGVSDGVuYW'
    'JsZWRUeXBlcxprCgVFbnRyeRJFCgR0eXBlGAEgASgOMjEuYW50aW5vdGVfYXBwLlN5bmNUYXNr'
    'RGF0YS5Ob3RpZmljYXRpb24uRW50cnlUeXBlUgR0eXBlEhsKCXZpc3VhbF9pZBgCIAEoCVIIdm'
    'lzdWFsSWQiTwoJRW50cnlUeXBlEg8KC0lORk9STUFUSU9OEAASDgoKRElTQ1VTU0lPThABEgwK'
    'CEhPTUVXT1JLEAISCQoFR1JBREUQAxIICgRNRU5VEARCEwoRX3NwZWNpYWxpemVkX2RhdGE=');

@$core.Deprecated('Use encryptedCredentialsDescriptor instead')
const EncryptedCredentials$json = {
  '1': 'EncryptedCredentials',
  '2': [
    {'1': 'credential_data', '3': 1, '4': 1, '5': 12, '10': 'credentialData'},
    {'1': 'credential_iv', '3': 2, '4': 1, '5': 12, '10': 'credentialIv'},
    {'1': 'dek_data', '3': 3, '4': 1, '5': 12, '10': 'dekData'},
    {'1': 'dek_iv', '3': 4, '4': 1, '5': 12, '10': 'dekIv'},
  ],
};

/// Descriptor for `EncryptedCredentials`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedCredentialsDescriptor = $convert.base64Decode(
    'ChRFbmNyeXB0ZWRDcmVkZW50aWFscxInCg9jcmVkZW50aWFsX2RhdGEYASABKAxSDmNyZWRlbn'
    'RpYWxEYXRhEiMKDWNyZWRlbnRpYWxfaXYYAiABKAxSDGNyZWRlbnRpYWxJdhIZCghkZWtfZGF0'
    'YRgDIAEoDFIHZGVrRGF0YRIVCgZkZWtfaXYYBCABKAxSBWRla0l2');

@$core.Deprecated('Use antinoteAccountDescriptor instead')
const AntinoteAccount$json = {
  '1': 'AntinoteAccount',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'username', '3': 3, '4': 1, '5': 9, '10': 'username'},
    {
      '1': 'establishment_name',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'establishmentName'
    },
    {'1': 'base_url', '3': 5, '4': 1, '5': 9, '10': 'baseUrl'},
    {'1': 'workspace_name', '3': 6, '4': 1, '5': 9, '10': 'workspaceName'},
    {
      '1': 'token_credentials',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'tokenCredentials'
    },
    {'1': 'invalid', '3': 8, '4': 1, '5': 8, '10': 'invalid'},
    {'1': 'store_securely', '3': 9, '4': 1, '5': 8, '10': 'storeSecurely'},
    {
      '1': 'sync_data',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.antinote_app.SyncTaskData',
      '10': 'syncData'
    },
  ],
};

/// Descriptor for `AntinoteAccount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List antinoteAccountDescriptor = $convert.base64Decode(
    'Cg9BbnRpbm90ZUFjY291bnQSEAoDdWlkGAEgASgJUgN1aWQSEgoEbmFtZRgCIAEoCVIEbmFtZR'
    'IaCgh1c2VybmFtZRgDIAEoCVIIdXNlcm5hbWUSLQoSZXN0YWJsaXNobWVudF9uYW1lGAQgASgJ'
    'UhFlc3RhYmxpc2htZW50TmFtZRIZCghiYXNlX3VybBgFIAEoCVIHYmFzZVVybBIlCg53b3Jrc3'
    'BhY2VfbmFtZRgGIAEoCVINd29ya3NwYWNlTmFtZRJBChF0b2tlbl9jcmVkZW50aWFscxgHIAEo'
    'CzIULmdvb2dsZS5wcm90b2J1Zi5BbnlSEHRva2VuQ3JlZGVudGlhbHMSGAoHaW52YWxpZBgIIA'
    'EoCFIHaW52YWxpZBIlCg5zdG9yZV9zZWN1cmVseRgJIAEoCFINc3RvcmVTZWN1cmVseRI3Cglz'
    'eW5jX2RhdGEYCiADKAsyGi5hbnRpbm90ZV9hcHAuU3luY1Rhc2tEYXRhUghzeW5jRGF0YQ==');

@$core.Deprecated('Use serializedAccountRegistryDescriptor instead')
const SerializedAccountRegistry$json = {
  '1': 'SerializedAccountRegistry',
  '2': [
    {
      '1': 'accounts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.antinote_app.AntinoteAccount',
      '10': 'accounts'
    },
    {
      '1': 'default_account_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'defaultAccountId',
      '17': true
    },
  ],
  '8': [
    {'1': '_default_account_id'},
  ],
};

/// Descriptor for `SerializedAccountRegistry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serializedAccountRegistryDescriptor = $convert.base64Decode(
    'ChlTZXJpYWxpemVkQWNjb3VudFJlZ2lzdHJ5EjkKCGFjY291bnRzGAEgAygLMh0uYW50aW5vdG'
    'VfYXBwLkFudGlub3RlQWNjb3VudFIIYWNjb3VudHMSMQoSZGVmYXVsdF9hY2NvdW50X2lkGAIg'
    'ASgJSABSEGRlZmF1bHRBY2NvdW50SWSIAQFCFQoTX2RlZmF1bHRfYWNjb3VudF9pZA==');
