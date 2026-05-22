// This is a generated file - do not edit.
//
// Generated from protos/account.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import "dart:core" as $core;

import "package:protobuf/protobuf.dart" as $pb;
import "package:protobuf/well_known_types/google/protobuf/any.pb.dart" as $0;

export "package:protobuf/protobuf.dart" show GeneratedMessageGenericExtensions;

class AntinoteAccount extends $pb.GeneratedMessage {
  factory AntinoteAccount({
    $core.String? uid,
    $core.String? name,
    $core.String? username,
    $core.String? establishmentName,
    $core.String? baseUrl,
    $core.String? workspaceName,
    $0.Any? tokenCredentials,
  }) {
    final result = create();
    if (uid != null) result.uid = uid;
    if (name != null) result.name = name;
    if (username != null) result.username = username;
    if (establishmentName != null) result.establishmentName = establishmentName;
    if (baseUrl != null) result.baseUrl = baseUrl;
    if (workspaceName != null) result.workspaceName = workspaceName;
    if (tokenCredentials != null) result.tokenCredentials = tokenCredentials;
    return result;
  }

  AntinoteAccount._();

  factory AntinoteAccount.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AntinoteAccount.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? "" : "AntinoteAccount",
      package: const $pb.PackageName(_omitMessageNames ? "" : "antinote_app"), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? "" : "uid")
    ..aOS(2, _omitFieldNames ? "" : "name")
    ..aOS(3, _omitFieldNames ? "" : "username")
    ..aOS(4, _omitFieldNames ? "" : "establishmentName")
    ..aOS(5, _omitFieldNames ? "" : "baseUrl")
    ..aOS(6, _omitFieldNames ? "" : "workspaceName")
    ..aOM<$0.Any>(7, _omitFieldNames ? "" : "tokenCredentials", subBuilder: $0.Any.create)
    ..hasRequiredFields = false;

  @$core.Deprecated("See https://github.com/google/protobuf.dart/issues/998.")
  AntinoteAccount clone() => deepCopy();
  @$core.Deprecated("See https://github.com/google/protobuf.dart/issues/998.")
  AntinoteAccount copyWith(void Function(AntinoteAccount) updates) =>
      super.copyWith((message) => updates(message as AntinoteAccount)) as AntinoteAccount;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma("dart2js:noInline")
  static AntinoteAccount create() => AntinoteAccount._();
  @$core.override
  AntinoteAccount createEmptyInstance() => create();
  @$core.pragma("dart2js:noInline")
  static AntinoteAccount getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AntinoteAccount>(create);
  static AntinoteAccount? _defaultInstance;

  /// An internal Unique IDentifier used as a primary key to reference accounts
  /// throughout the app.
  @$pb.TagNumber(1)
  $core.String get uid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  /// The full name of the account holder.
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// The username of the account.
  @$pb.TagNumber(3)
  $core.String get username => $_getSZ(2);
  @$pb.TagNumber(3)
  set username($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUsername() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsername() => $_clearField(3);

  /// The name of the establishment for the account.
  @$pb.TagNumber(4)
  $core.String get establishmentName => $_getSZ(3);
  @$pb.TagNumber(4)
  set establishmentName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEstablishmentName() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstablishmentName() => $_clearField(4);

  /// The base URL of the instance this points to.
  @$pb.TagNumber(5)
  $core.String get baseUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set baseUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBaseUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearBaseUrl() => $_clearField(5);

  /// The display name of the workspace this account is linked to.
  @$pb.TagNumber(6)
  $core.String get workspaceName => $_getSZ(5);
  @$pb.TagNumber(6)
  set workspaceName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWorkspaceName() => $_has(5);
  @$pb.TagNumber(6)
  void clearWorkspaceName() => $_clearField(6);

  /// The actual identifiers for the account. Some informations within it may be
  /// duplicated.
  @$pb.TagNumber(7)
  $0.Any get tokenCredentials => $_getN(6);
  @$pb.TagNumber(7)
  set tokenCredentials($0.Any value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTokenCredentials() => $_has(6);
  @$pb.TagNumber(7)
  void clearTokenCredentials() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Any ensureTokenCredentials() => $_ensure(6);
}

class AccountRegistry extends $pb.GeneratedMessage {
  factory AccountRegistry({
    $core.Iterable<AntinoteAccount>? accounts,
    $core.String? defaultAccountId,
  }) {
    final result = create();
    if (accounts != null) result.accounts.addAll(accounts);
    if (defaultAccountId != null) result.defaultAccountId = defaultAccountId;
    return result;
  }

  AccountRegistry._();

  factory AccountRegistry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountRegistry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? "" : "AccountRegistry",
      package: const $pb.PackageName(_omitMessageNames ? "" : "antinote_app"), createEmptyInstance: create)
    ..pPM<AntinoteAccount>(1, _omitFieldNames ? "" : "accounts", subBuilder: AntinoteAccount.create)
    ..aOS(2, _omitFieldNames ? "" : "defaultAccountId")
    ..hasRequiredFields = false;

  @$core.Deprecated("See https://github.com/google/protobuf.dart/issues/998.")
  AccountRegistry clone() => deepCopy();
  @$core.Deprecated("See https://github.com/google/protobuf.dart/issues/998.")
  AccountRegistry copyWith(void Function(AccountRegistry) updates) =>
      super.copyWith((message) => updates(message as AccountRegistry)) as AccountRegistry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma("dart2js:noInline")
  static AccountRegistry create() => AccountRegistry._();
  @$core.override
  AccountRegistry createEmptyInstance() => create();
  @$core.pragma("dart2js:noInline")
  static AccountRegistry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccountRegistry>(create);
  static AccountRegistry? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AntinoteAccount> get accounts => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get defaultAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set defaultAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDefaultAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDefaultAccountId() => $_clearField(2);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment("protobuf.omit_field_names");
const $core.bool _omitMessageNames = $core.bool.fromEnvironment("protobuf.omit_message_names");
