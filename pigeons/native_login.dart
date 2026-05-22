import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/backend/src/pigeon_posts/native_login.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/fr/helomri/antinote_ui/pigeon_posts/NativeLogin.g.kt',
    kotlinOptions: KotlinOptions(
      errorClassName: 'NativeLoginError',
      package: 'fr.helomri.antinote_ui.pigeon_posts',
    ),
    dartPackageName: 'antinote_ui',
  ),
)
//
//
@HostApi()
abstract class NativeLoginManager {
  List<Uint8List> listAccounts();

  Uint8List? getAccountWithCredentials(String uid);

  Uint8List? getDefaultAccount();

  void setDefaultAccount(String? uid);

  void addAccount(Uint8List rawAccount);

  void deleteAccount(String uid);

  void deleteAllAccounts();

  void updateAccount(Uint8List newRawAccount, String uid);

  Uint8List getCredentials(Uint8List rawAccount);
}
