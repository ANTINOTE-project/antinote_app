import 'dart:convert';
import 'dart:io';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:antinote_app/data/src/accounts/storage/base.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is used as a fallback when occasionally testing the app for new
/// platforms. [AntinoteAccount.storeSecurely] is not supported.
class PreferencesAccountStorage implements AccountStorage {
  static const sessionAccountsPref = 'accounts';
  static final isActive = !Platform.isAndroid && kDebugMode;

  const PreferencesAccountStorage({required this.getRegistry});

  final Future<SerializedAccountRegistry> Function() getRegistry;

  Future<SerializedAccountRegistry> get registry => getRegistry();

  static Future<SerializedAccountRegistry> readOrCreateRegistry() async {
    final prefs = SharedPreferencesAsync();

    final registry = await prefs.getString(sessionAccountsPref);
    if (registry == null) return SerializedAccountRegistry.create();

    try {
      return SerializedAccountRegistry.fromBuffer(base64Decode(registry));
    } catch (e, st) {
      libLog.severe(
        'Failed to load account registry, creating a new one...',
        e,
        st,
      );
      return SerializedAccountRegistry.create();
    }
  }

  Future<void> writeRegistry() async {
    final prefs = SharedPreferencesAsync();
    await prefs.setString(
      sessionAccountsPref,
      base64Encode((await registry).writeToBuffer()),
    );
  }

  @override
  Future<List<AntinoteAccount>> listAccounts() async =>
      (await registry).accounts;

  @override
  Future<AntinoteAccount?> borrowAccountWithCredentials(String uid) async {
    for (final account in (await registry).accounts) {
      if (account.uid == uid) return account;
    }

    return null;
  }

  @override
  Future<AntinoteAccount?> getDefaultAccount() async {
    final defaultAccountUid = (await registry).defaultAccountId;

    return (await registry).accounts
        .where((element) => element.uid == defaultAccountUid)
        .firstOrNull;
  }

  @override
  Future<void> setDefault(String? uid) async {
    if (uid != null) {
      (await registry).defaultAccountId = uid;
    } else {
      (await registry).clearDefaultAccountId();
    }

    await writeRegistry();
  }

  @override
  Future<void> updateAccount(AntinoteAccount newAccount, String uid) async {
    final reg = await registry;
    final index = reg.accounts.indexWhere((element) => element.uid == uid);
    reg.accounts[index] = newAccount;

    await writeRegistry();
  }

  @override
  Future<void> deleteAccount(String uid) async {
    final reg = await registry;
    reg.accounts.removeWhere((element) => element.uid == uid);
    if (reg.defaultAccountId == uid) reg.clearDefaultAccountId();

    await writeRegistry();
  }

  @override
  Future<void> deleteAllAccounts() async {
    (await registry)
      ..clearDefaultAccountId()
      ..accounts.clear();

    await writeRegistry();
  }

  @override
  Future<void> addAccount(AntinoteAccount account) async {
    (await registry).accounts.add(account);

    await writeRegistry();
  }

  Future<void> disableDefaultAccount() async =>
      await setDefaultAccount(account: null);

  Future<void> setDefaultAccount({required String? account}) async {
    final reg = await registry;
    if (account != null) {
      reg.defaultAccountId = account;
    } else {
      reg.clearDefaultAccountId();
    }

    await writeRegistry();
  }
}
