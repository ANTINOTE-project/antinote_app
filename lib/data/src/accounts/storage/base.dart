import 'package:antinote_app/data/src/accounts/storage/native.dart';
import 'package:antinote_app/data/src/accounts/storage/preferences.dart';
import 'package:antinote_app/data/protos/account.pb.dart';
import 'package:flutter/material.dart';

abstract class AccountStorage {
  const AccountStorage();

  factory AccountStorage.create(
    ValueNotifier<SerializedAccountRegistry?> registryNotifier,
  ) {
    return PreferencesAccountStorage.isActive
        ? PreferencesAccountStorage(
            getRegistry: () async {
              registryNotifier.value ??=
                  await PreferencesAccountStorage.readOrCreateRegistry();
              return registryNotifier.value!;
            },
          )
        : const NativeAccountStorage();
  }

  Future<List<AntinoteAccount>> listAccounts();

  /// This makes implementation mark an account as "borrowed": nobody else can
  /// access the credentials until new ones are set.
  /// TODO: Implement it like that.
  Future<AntinoteAccount?> borrowAccountWithCredentials(String uid);

  Future<AntinoteAccount?> getDefaultAccount();

  Future<void> setDefault(String? uid);

  Future<void> addAccount(AntinoteAccount account);

  Future<void> updateAccount(AntinoteAccount newAccount, String uid);

  Future<void> deleteAccount(String uid);

  Future<void> deleteAllAccounts();
}
