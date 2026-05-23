// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ANTINOTE';

  @override
  String get choseAnAccount => 'Choisir un compte';

  @override
  String get addAnAccount => 'Ajouter un compte';

  @override
  String get delete => 'Supprimer';

  @override
  String get disableAutoLogin => 'Désactiver la connexion automatique';

  @override
  String get enableAutoLogin => 'Activer la connexion automatique';

  @override
  String get loginQrCode => 'QR Code';

  @override
  String get loginQrCodeSubtitle =>
      'Scanne un QR code depuis un ordinateur déjà connecté à PRONOTE';

  @override
  String get loginSearch => 'Recherche ton établissement';

  @override
  String get loginSearchSubtitle =>
      'Entre le nom de ta ville et choisis ton établissement';
}
