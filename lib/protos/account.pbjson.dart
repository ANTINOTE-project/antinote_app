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

import "dart:convert" as $convert;
import "dart:core" as $core;
import "dart:typed_data" as $typed_data;

@$core.Deprecated("Use antinoteAccountDescriptor instead")
const AntinoteAccount$json = {
  "1": "AntinoteAccount",
  "2": [
    {"1": "uid", "3": 1, "4": 1, "5": 9, "10": "uid"},
    {"1": "name", "3": 2, "4": 1, "5": 9, "10": "name"},
    {"1": "username", "3": 3, "4": 1, "5": 9, "10": "username"},
    {"1": "establishment_name", "3": 4, "4": 1, "5": 9, "10": "establishmentName"},
    {"1": "base_url", "3": 5, "4": 1, "5": 9, "10": "baseUrl"},
    {"1": "workspace_name", "3": 6, "4": 1, "5": 9, "10": "workspaceName"},
    {
      "1": "token_credentials",
      "3": 7,
      "4": 1,
      "5": 11,
      "6": ".google.protobuf.Any",
      "10": "tokenCredentials"
    },
  ],
};

/// Descriptor for `AntinoteAccount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List antinoteAccountDescriptor =
    $convert.base64Decode("Cg9BbnRpbm90ZUFjY291bnQSEAoDdWlkGAEgASgJUgN1aWQSEgoEbmFtZRgCIAEoCVIEbmFtZR"
        "IaCgh1c2VybmFtZRgDIAEoCVIIdXNlcm5hbWUSLQoSZXN0YWJsaXNobWVudF9uYW1lGAQgASgJ"
        "UhFlc3RhYmxpc2htZW50TmFtZRIZCghiYXNlX3VybBgFIAEoCVIHYmFzZVVybBIlCg53b3Jrc3"
        "BhY2VfbmFtZRgGIAEoCVINd29ya3NwYWNlTmFtZRJBChF0b2tlbl9jcmVkZW50aWFscxgHIAEo"
        "CzIULmdvb2dsZS5wcm90b2J1Zi5BbnlSEHRva2VuQ3JlZGVudGlhbHM=");

@$core.Deprecated("Use accountRegistryDescriptor instead")
const AccountRegistry$json = {
  "1": "AccountRegistry",
  "2": [
    {"1": "accounts", "3": 1, "4": 3, "5": 11, "6": ".antinote_app.AntinoteAccount", "10": "accounts"},
    {"1": "default_account_id", "3": 2, "4": 1, "5": 9, "9": 0, "10": "defaultAccountId", "17": true},
  ],
  "8": [
    {"1": "_default_account_id"},
  ],
};

/// Descriptor for `AccountRegistry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountRegistryDescriptor =
    $convert.base64Decode("Cg9BY2NvdW50UmVnaXN0cnkSOQoIYWNjb3VudHMYASADKAsyHS5hbnRpbm90ZV9hcHAuQW50aW"
        "5vdGVBY2NvdW50UghhY2NvdW50cxIxChJkZWZhdWx0X2FjY291bnRfaWQYAiABKAlIAFIQZGVm"
        "YXVsdEFjY291bnRJZIgBAUIVChNfZGVmYXVsdF9hY2NvdW50X2lk");
