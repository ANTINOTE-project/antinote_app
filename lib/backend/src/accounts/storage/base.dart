import "package:antinote_app/backend/src/accounts/storage/widget.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/material.dart";

abstract class AccountStorage {
  const AccountStorage();

  static AccountStorage of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AccountStorageWidget>();
    assert(result != null, "No AccountStorage found in context.");

    return result!.storage;
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

  Future<AntinoteAccount> getCredentials(AntinoteAccount account);
}
