import "dart:io";

import "package:antinote/antinote.dart";
import "package:antinote_app/protos/account.pb.dart";

import "../../pigeon_posts/native_login.g.dart";
import "base.dart";

class NativeAccountStorage implements AccountStorage {
  static final _receiver = NativeLoginManager();
  static final isActive = Platform.isAndroid;

  const NativeAccountStorage();

  @override
  Future<List<AntinoteAccount>> listAccounts() async =>
      (await _receiver.listAccounts()).mapL((e) => AntinoteAccount.fromBuffer(e));

  @override
  Future<AntinoteAccount?> borrowAccountWithCredentials(String uid) async {
    final res = await _receiver.getAccountWithCredentials(uid);
    if (res == null) return null;
    return AntinoteAccount.fromBuffer(res);
  }

  @override
  Future<AntinoteAccount?> getDefaultAccount() async {
    final res = await _receiver.getDefaultAccount();
    if (res == null) return null;
    return AntinoteAccount.fromBuffer(res);
  }

  @override
  Future<void> setDefault(String? uid) => _receiver.setDefaultAccount(uid);

  @override
  Future<void> addAccount(AntinoteAccount account) => _receiver.addAccount(account.writeToBuffer());

  @override
  Future<void> deleteAccount(String uid) => _receiver.deleteAccount(uid);

  @override
  Future<void> deleteAllAccounts() => _receiver.deleteAllAccounts();

  @override
  Future<void> updateAccount(AntinoteAccount newAccount, String uid) =>
      _receiver.updateAccount(newAccount.writeToBuffer(), uid);

  @override
  Future<AntinoteAccount> getCredentials(AntinoteAccount account) async =>
      AntinoteAccount.fromBuffer(await _receiver.getCredentials(account.writeToBuffer()));
}
