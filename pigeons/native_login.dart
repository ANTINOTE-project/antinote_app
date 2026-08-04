import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/data/src/pigeon_posts/native_login.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/app/src/main/kotlin/fr/antinote/antinote_app/pigeon_posts/NativeLogin.g.kt',
    kotlinOptions: KotlinOptions(
      errorClassName: 'NativeLoginError',
      package: 'fr.antinote.antinote_app.pigeon_posts',
    ),
    dartPackageName: 'antinote_app',
  ),
)
//
//
@HostApi()
abstract class NativeLoginManager {
  @async
  List<Uint8List> listAccounts();

  @async
  Uint8List? getAccountWithCredentials(String uid);

  @async
  Uint8List? getDefaultAccount();

  @async
  void setDefaultAccount(String? uid);

  @async
  bool addAccount(Uint8List rawAccount);

  @async
  void deleteAccount(String uid);

  @async
  void deleteAllAccounts();

  @async
  bool updateAccount(Uint8List newRawAccount, String uid);
}
