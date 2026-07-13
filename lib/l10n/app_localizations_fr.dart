// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get theme => 'Thème';

  @override
  String get themePrimary => 'Primaire';

  @override
  String get themeSecondary => 'Secondaire';

  @override
  String get themeTertiary => 'Tertiaire';

  @override
  String get themeSurface => 'Surface';

  @override
  String get themeError => 'Erreur';

  @override
  String get themeCoral => 'Corail';

  @override
  String get themeIndigo => 'Indigo';

  @override
  String get themeGreen => 'Vert';

  @override
  String get themeTeal => 'Sarcelle';

  @override
  String get themePurple => 'Violet';

  @override
  String get themeBlue => 'Bleu';

  @override
  String get themeAmber => 'Ambre';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get yesterday => 'Hier';

  @override
  String get anErrorOccurred => 'Une erreur s\'est produite';

  @override
  String get cancel => 'Annuler';

  @override
  String get validate => 'Valider';

  @override
  String get retry => 'Réessayer';

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
  String get disableAutoLogin => 'Désactiver la connexion automatique';

  @override
  String get enableAutoLogin => 'Activer la connexion automatique';

  @override
  String get choseAnAccount => 'Choisir un compte';

  @override
  String get addAnAccount => 'Ajouter un compte';

  @override
  String get deleteAccount => 'Supprimer';

  @override
  String get accounts => 'Comptes';

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
  String get loginUrl => 'URL de ton établissement';

  @override
  String get loginUrlSubtitle =>
      'Renseigne l\'URL de ton espace PRONOTE pour t\'y connecter';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginSchool => 'Choisis ton établissement';

  @override
  String get loginSelect => 'Choisis ton espace';

  @override
  String get activateCas => 'Se connecter via ENT';

  @override
  String get loginCredentials => 'Renseigne tes identifiants';

  @override
  String get loginToAccount => 'Connecte toi à ton compte';

  @override
  String get loginUsername => 'Identifiant';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginPinCode => 'Code PIN';

  @override
  String get loginPinCodeSubtitle =>
      'Veuillez rentrer votre code PIN vous connecter à votre compte PRONOTE';

  @override
  String get homeShowMore => 'Voir plus';

  @override
  String get homeAttendance => 'Vie scolaire';

  @override
  String get homeNews => 'Actualités';

  @override
  String get homeExams => 'Évaluations';

  @override
  String get absenceNotJustified => 'Absence non justifiée';

  @override
  String get absenceJustified => 'Absence justifiée';

  @override
  String absenceDuration(DateTime date, DateTime startTime, DateTime endTime) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat startTimeDateFormat = intl.DateFormat(
      'HH\'h\'mm',
      localeName,
    );
    final String startTimeString = startTimeDateFormat.format(startTime);
    final intl.DateFormat endTimeDateFormat = intl.DateFormat(
      'HH\'h\'mm',
      localeName,
    );
    final String endTimeString = endTimeDateFormat.format(endTime);

    return '$dateString de $startTimeString à $endTimeString';
  }

  @override
  String classTiming(DateTime startTime, DateTime endTime) {
    final intl.DateFormat startTimeDateFormat = intl.DateFormat(
      'HH\'h\'mm',
      localeName,
    );
    final String startTimeString = startTimeDateFormat.format(startTime);
    final intl.DateFormat endTimeDateFormat = intl.DateFormat(
      'HH\'h\'mm',
      localeName,
    );
    final String endTimeString = endTimeDateFormat.format(endTime);

    return '$startTimeString - $endTimeString';
  }

  @override
  String classTimingDuration(
    DateTime startTime,
    DateTime endTime,
    String duration,
  ) {
    final intl.DateFormat startTimeDateFormat = intl.DateFormat(
      'HH\'h\'mm',
      localeName,
    );
    final String startTimeString = startTimeDateFormat.format(startTime);
    final intl.DateFormat endTimeDateFormat = intl.DateFormat(
      'HH\'h\'mm',
      localeName,
    );
    final String endTimeString = endTimeDateFormat.format(endTime);

    return '$startTimeString - $endTimeString ($duration)';
  }

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
  String get selfServiceAverage => 'Moy. de la matière';

  @override
  String get averageClass => 'Moy. classe';

  @override
  String get gradesHistory => 'Historique de tes notes';

  @override
  String get coefficient => 'Coefficient';

  @override
  String get gradeCount => 'Nombre de notes';

  @override
  String get youGot => 'Tu as eu';

  @override
  String get bestGrade => 'Meilleure note';

  @override
  String get worstGrade => 'Note la plus basse';

  @override
  String get gradeAbsent => 'Abs';

  @override
  String get gradeAbsentZero => 'Abs (0)';

  @override
  String get gradeNotHanded => 'NR';

  @override
  String get gradeNotHandedZero => 'NR (0)';

  @override
  String get gradeExemption => 'Disp';

  @override
  String get gradeNotGraded => 'Non noté';

  @override
  String get gradeInapt => 'Inapte';

  @override
  String get gradeFelicitations => 'Félicitations';

  @override
  String get gradesReport => 'Bulletin';

  @override
  String get classGradesReport => 'Bulletin de classe';

  @override
  String get reportUnpublished => 'Bulletin non publié';

  @override
  String get reportComment => 'Appréciations';

  @override
  String get reportOtherSubjects => 'Autres matières';

  @override
  String reportCoefficient(Object value) {
    return 'Coeff. $value';
  }

  @override
  String get gradeMin => 'Min.';

  @override
  String get gradeMax => 'Max.';

  @override
  String get noCourseToday => 'Tu n\'as pas de cours,\nprofite bien !';

  @override
  String get holidayDay => 'C\'est les vacances,\n amuse toi bien !';

  @override
  String get weekend => 'C\'est le weekend !';

  @override
  String get lunch => 'Bon appétit !';

  @override
  String gap(Object duration) {
    return '$duration de libre';
  }

  @override
  String get cancelled => 'ANNULÉ';

  @override
  String get detention => 'Retenue';

  @override
  String get pedagogicalActivity => 'Activité pédagogique';

  @override
  String get noSubject => 'Matière inconnue';

  @override
  String get noRoom => 'Salle non définie';

  @override
  String get contentTeachers => 'Enseignants';

  @override
  String get contentPersonal => 'Personnels';

  @override
  String get contentClassrooms => 'Salles de classe';

  @override
  String get contentVirtualClassrooms => 'Classes virtuelles';

  @override
  String get contentClassGroups => 'Groupes';

  @override
  String get contentClasses => 'Classes';

  @override
  String get contentUnknowns => 'Inconnus';

  @override
  String recipient(Object recipient) {
    return 'À $recipient';
  }

  @override
  String get self => 'moi';

  @override
  String get nominativePoll => 'sondage nominatif';

  @override
  String get anonymousPoll => 'sondage anonyme';

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
  String remoteYearSubtitle(DateTime start, DateTime end) {
    final intl.DateFormat startDateFormat = intl.DateFormat(
      'dd/MM/yy',
      localeName,
    );
    final String startString = startDateFormat.format(start);
    final intl.DateFormat endDateFormat = intl.DateFormat(
      'dd/MM/yy',
      localeName,
    );
    final String endString = endDateFormat.format(end);

    return '$startString ➔ $endString';
  }

  @override
  String get remotePeriods => 'Périodes';

  @override
  String get virtualClassroom => 'Visio';

  @override
  String get homeworkSetDone => 'J\'ai terminé';

  @override
  String get homeworkSetNotDone => 'Je n\'ai pas terminé';

  @override
  String weekNumber(Object weekNumber) {
    return 'Semaine $weekNumber';
  }

  @override
  String get homeworkDescription => 'Description';

  @override
  String get homeworkAttachments => 'Pièces jointes';

  @override
  String givenTheForThe(DateTime given, DateTime deadline) {
    final intl.DateFormat givenDateFormat = intl.DateFormat(
      'dd/MM',
      localeName,
    );
    final String givenString = givenDateFormat.format(given);
    final intl.DateFormat deadlineDateFormat = intl.DateFormat(
      'dd/MM',
      localeName,
    );
    final String deadlineString = deadlineDateFormat.format(deadline);

    return 'Donné le $givenString pour le $deadlineString';
  }

  @override
  String get homeworkDifficulty => 'Difficulté';

  @override
  String get homeworkState => 'État';

  @override
  String get homeworkRenderPronote => 'À rendre en ligne';

  @override
  String get homeworkRenderNone => 'Rien à rendre';

  @override
  String get homeworkRenderPaper => 'À rendre en main propre';

  @override
  String get homeworkRenderKiosque => 'À rendre au kiosque';

  @override
  String get homeworkRenderPronoteAudio =>
      'Enregistrement audio à rendre en ligne';

  @override
  String get noHomeworkForWeek => 'Pas de travaux à faire pour cette semaine !';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get deviceTheme => 'Utiliser le thème de l\'appareil';

  @override
  String get deviceThemeDescription =>
      'Le thème utilisé dans l\'application changera selon le fond d\'écran.';

  @override
  String get displayProfilePicture => 'Afficher la photo de profile';

  @override
  String get network => 'Réseau';

  @override
  String get reconnectAccount => 'Reconnecter le compte';

  @override
  String get sendNavigationRequests => 'Envoyer les requêtes de navigation';

  @override
  String get sendNavigationRequestsSubtitle =>
      'Quand cette option est désactivée, des gains en latence et en données transférées peuvent être observés. Cependant, cela fait diverger le fonctionnement de l\'application de celle de PRONOTE.';

  @override
  String get noMenuForToday => 'Pas de menu pour aujourd\'hui !';

  @override
  String get menu => 'Menu';

  @override
  String lunchFor(DateTime day) {
    final intl.DateFormat dayDateFormat = intl.DateFormat('dd/MM', localeName);
    final String dayString = dayDateFormat.format(day);

    return 'Déjeuner du $dayString';
  }

  @override
  String dinnerFor(DateTime day) {
    final intl.DateFormat dayDateFormat = intl.DateFormat('dd/MM', localeName);
    final String dayString = dayDateFormat.format(day);

    return 'Dinner du $dayString';
  }
}
