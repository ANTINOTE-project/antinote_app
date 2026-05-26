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
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get yesterday => 'Hier';

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
  String get loginCity => 'Recherche ta ville';

  @override
  String get loginCitySubtitle =>
      'Entre le nom de ta ville et choisis ton établissement';

  @override
  String get loginUrl => 'Rentre l\'adresse du PRONOTE de ton établissement';

  @override
  String get loginUrlSubtitle =>
      'Renseigne l\'URL de ton espace PRONOTE pour t\'y connecter directement';

  @override
  String get loginSchool => 'Choisis ton établissement';

  @override
  String get loginSelect => 'Choisis ton espace';

  @override
  String get activateCas => 'Se connecter via ENT';

  @override
  String get loginCredentials => 'Renseigne tes identifiants';

  @override
  String get loginWebview => 'Connecte toi à ton compte';

  @override
  String get home => 'Accueil';

  @override
  String get timetable => 'Cours';

  @override
  String get grades => 'Notes';

  @override
  String get homeworks => 'Devoirs';

  @override
  String get communication => 'Infos';

  @override
  String get report => 'Bulletin';

  @override
  String get latestGrades => 'Dernières notes';

  @override
  String get services => 'Matières';

  @override
  String gradeOf(Object service) {
    return 'Note de $service';
  }

  @override
  String get averageSelf => 'Moy. générale';

  @override
  String get averageClass => 'Moy. classe';

  @override
  String get noCourseToday => 'Tu n\'as pas de cours,\nprofite bien !';

  @override
  String get holidayDay => 'C\'est les vacances,\n amuse toi bien !';

  @override
  String get weekend => 'C\'est le weekend !';

  @override
  String get cancelled => 'ANNULÉ';

  @override
  String get detention => 'Retenue';

  @override
  String get noSubject => 'Matière inconnue';

  @override
  String get noRoom => 'Salle non définie';

  @override
  String recipient(Object recipient) {
    return 'À $recipient';
  }

  @override
  String get self => 'moi';

  @override
  String get nominativePoll => 'Sondage nominatif';

  @override
  String get anonymousPoll => 'Sondage anonyme';

  @override
  String get raMessage => 'J\'ai pris connaissance de cette information';

  @override
  String get couldNotLoad => 'L\'instance m\'a pas pu être chargée...';

  @override
  String get instanceName => 'Nom d\'instance';

  @override
  String instanceNameValue(Object loginName, Object mainName) {
    return '$mainName ($loginName quand déconnecté)';
  }

  @override
  String get remoteVersion => 'Version de l\'instance';

  @override
  String get remoteYear => 'Année';

  @override
  String remoteYearSubtitle(Object end, Object start) {
    return '$start ➔ $end';
  }

  @override
  String get remotePeriods => 'Périodes';
}
