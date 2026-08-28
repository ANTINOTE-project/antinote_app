import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @themePrimary.
  ///
  /// In fr, this message translates to:
  /// **'Primaire'**
  String get themePrimary;

  /// No description provided for @themeSecondary.
  ///
  /// In fr, this message translates to:
  /// **'Secondaire'**
  String get themeSecondary;

  /// No description provided for @themeTertiary.
  ///
  /// In fr, this message translates to:
  /// **'Tertiaire'**
  String get themeTertiary;

  /// No description provided for @themeSurface.
  ///
  /// In fr, this message translates to:
  /// **'Surface'**
  String get themeSurface;

  /// No description provided for @themeError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get themeError;

  /// No description provided for @themeCoral.
  ///
  /// In fr, this message translates to:
  /// **'Corail'**
  String get themeCoral;

  /// No description provided for @themeIndigo.
  ///
  /// In fr, this message translates to:
  /// **'Indigo'**
  String get themeIndigo;

  /// No description provided for @themeGreen.
  ///
  /// In fr, this message translates to:
  /// **'Vert'**
  String get themeGreen;

  /// No description provided for @themeTeal.
  ///
  /// In fr, this message translates to:
  /// **'Sarcelle'**
  String get themeTeal;

  /// No description provided for @themePurple.
  ///
  /// In fr, this message translates to:
  /// **'Violet'**
  String get themePurple;

  /// No description provided for @themeBlue.
  ///
  /// In fr, this message translates to:
  /// **'Bleu'**
  String get themeBlue;

  /// No description provided for @themeAmber.
  ///
  /// In fr, this message translates to:
  /// **'Ambre'**
  String get themeAmber;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @anErrorOccurred.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite'**
  String get anErrorOccurred;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @timetable.
  ///
  /// In fr, this message translates to:
  /// **'Cours'**
  String get timetable;

  /// No description provided for @grades.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get grades;

  /// No description provided for @homeworks.
  ///
  /// In fr, this message translates to:
  /// **'Devoirs'**
  String get homeworks;

  /// No description provided for @communication.
  ///
  /// In fr, this message translates to:
  /// **'Réception'**
  String get communication;

  /// No description provided for @autoLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion automatique'**
  String get autoLogin;

  /// No description provided for @autoLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne ce compte dès l\'ouverture de l\'application'**
  String get autoLoginSubtitle;

  /// No description provided for @secureStore.
  ///
  /// In fr, this message translates to:
  /// **'Chiffrage du compte'**
  String get secureStore;

  /// No description provided for @secureStoreSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Demande votre biométrie pour se connecter au compte'**
  String get secureStoreSubtitle;

  /// No description provided for @chooseAnAccount.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un compte'**
  String get chooseAnAccount;

  /// No description provided for @chooseAnAccountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir quel compte consulter, changer différentes propriétés des comptes, ajouter des comptes'**
  String get chooseAnAccountSubtitle;

  /// No description provided for @addAnAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un compte'**
  String get addAnAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteAccount;

  /// No description provided for @accounts.
  ///
  /// In fr, this message translates to:
  /// **'Comptes'**
  String get accounts;

  /// No description provided for @loginQrCode.
  ///
  /// In fr, this message translates to:
  /// **'QR Code'**
  String get loginQrCode;

  /// No description provided for @loginQrCodeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanne un QR code depuis un ordinateur déjà connecté à PRONOTE'**
  String get loginQrCodeSubtitle;

  /// No description provided for @loginQrCodeFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Scanner depuis une image'**
  String get loginQrCodeFromGallery;

  /// No description provided for @loginCity.
  ///
  /// In fr, this message translates to:
  /// **'Recherche ta ville'**
  String get loginCity;

  /// No description provided for @loginCitySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entre le nom de ta ville et choisis ton établissement'**
  String get loginCitySubtitle;

  /// No description provided for @loginUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL de ton établissement'**
  String get loginUrl;

  /// No description provided for @loginUrlSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne l\'URL de ton espace PRONOTE pour t\'y connecter'**
  String get loginUrlSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @loginSchool.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton établissement'**
  String get loginSchool;

  /// No description provided for @loginSelect.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton espace'**
  String get loginSelect;

  /// No description provided for @activateCas.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter via ENT'**
  String get activateCas;

  /// No description provided for @loginCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne tes identifiants'**
  String get loginCredentials;

  /// No description provided for @loginToAccount.
  ///
  /// In fr, this message translates to:
  /// **'Connecte toi à ton compte'**
  String get loginToAccount;

  /// No description provided for @loginUsername.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPassword;

  /// No description provided for @loginPinCode.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN'**
  String get loginPinCode;

  /// No description provided for @loginPinCodeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez rentrer votre code PIN vous connecter à votre compte PRONOTE'**
  String get loginPinCodeSubtitle;

  /// No description provided for @loginDemo.
  ///
  /// In fr, this message translates to:
  /// **'Compte de démonstration'**
  String get loginDemo;

  /// No description provided for @loginDemoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connecte toi à un compte de test pour explorer l\'application et ses fonctionnalités'**
  String get loginDemoSubtitle;

  /// No description provided for @homeShowMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get homeShowMore;

  /// No description provided for @homeAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Vie Scolaire'**
  String get homeAttendance;

  /// No description provided for @homeNews.
  ///
  /// In fr, this message translates to:
  /// **'Actualités'**
  String get homeNews;

  /// No description provided for @homeExams.
  ///
  /// In fr, this message translates to:
  /// **'Évaluations'**
  String get homeExams;

  /// No description provided for @homeHiName.
  ///
  /// In fr, this message translates to:
  /// **'Salut, {name} !'**
  String homeHiName(Object name);

  /// No description provided for @absenceNotJustified.
  ///
  /// In fr, this message translates to:
  /// **'Absence non justifiée'**
  String get absenceNotJustified;

  /// No description provided for @absenceJustified.
  ///
  /// In fr, this message translates to:
  /// **'Absence justifiée'**
  String get absenceJustified;

  /// No description provided for @absenceDuration.
  ///
  /// In fr, this message translates to:
  /// **'{date} de {startTime} à {endTime}'**
  String absenceDuration(DateTime date, DateTime startTime, DateTime endTime);

  /// No description provided for @fieldNotFilled.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get fieldNotFilled;

  /// No description provided for @classTiming.
  ///
  /// In fr, this message translates to:
  /// **'{startTime} - {endTime}'**
  String classTiming(DateTime startTime, DateTime endTime);

  /// No description provided for @classTimingDuration.
  ///
  /// In fr, this message translates to:
  /// **'{startTime} - {endTime} ({duration})'**
  String classTimingDuration(
    DateTime startTime,
    DateTime endTime,
    String duration,
  );

  /// No description provided for @latestGrades.
  ///
  /// In fr, this message translates to:
  /// **'Dernières notes'**
  String get latestGrades;

  /// No description provided for @services.
  ///
  /// In fr, this message translates to:
  /// **'Matières'**
  String get services;

  /// No description provided for @gradeOf.
  ///
  /// In fr, this message translates to:
  /// **'Note de {service}'**
  String gradeOf(Object service);

  /// No description provided for @averageSelf.
  ///
  /// In fr, this message translates to:
  /// **'Moy. générale'**
  String get averageSelf;

  /// No description provided for @selfServiceAverage.
  ///
  /// In fr, this message translates to:
  /// **'Moy. de la matière'**
  String get selfServiceAverage;

  /// No description provided for @averageClass.
  ///
  /// In fr, this message translates to:
  /// **'Moy. classe'**
  String get averageClass;

  /// No description provided for @gradesHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique de tes notes'**
  String get gradesHistory;

  /// No description provided for @coefficient.
  ///
  /// In fr, this message translates to:
  /// **'Coefficient'**
  String get coefficient;

  /// No description provided for @gradeCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de notes'**
  String get gradeCount;

  /// No description provided for @youGot.
  ///
  /// In fr, this message translates to:
  /// **'Tu as eu'**
  String get youGot;

  /// No description provided for @bestGrade.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure note'**
  String get bestGrade;

  /// No description provided for @worstGrade.
  ///
  /// In fr, this message translates to:
  /// **'Note la plus basse'**
  String get worstGrade;

  /// No description provided for @gradeAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Abs'**
  String get gradeAbsent;

  /// No description provided for @gradeAbsentZero.
  ///
  /// In fr, this message translates to:
  /// **'Abs (0)'**
  String get gradeAbsentZero;

  /// No description provided for @gradeNotHanded.
  ///
  /// In fr, this message translates to:
  /// **'NR'**
  String get gradeNotHanded;

  /// No description provided for @gradeNotHandedZero.
  ///
  /// In fr, this message translates to:
  /// **'NR (0)'**
  String get gradeNotHandedZero;

  /// No description provided for @gradeExemption.
  ///
  /// In fr, this message translates to:
  /// **'Disp'**
  String get gradeExemption;

  /// No description provided for @gradeNotGraded.
  ///
  /// In fr, this message translates to:
  /// **'Non noté'**
  String get gradeNotGraded;

  /// No description provided for @gradeInapt.
  ///
  /// In fr, this message translates to:
  /// **'Inapte'**
  String get gradeInapt;

  /// No description provided for @gradeCongratulations.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations'**
  String get gradeCongratulations;

  /// No description provided for @gradesReport.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin'**
  String get gradesReport;

  /// No description provided for @classGradesReport.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin de classe'**
  String get classGradesReport;

  /// No description provided for @reportUnpublished.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin non publié'**
  String get reportUnpublished;

  /// No description provided for @reportComment.
  ///
  /// In fr, this message translates to:
  /// **'Appréciations'**
  String get reportComment;

  /// No description provided for @reportOtherSubjects.
  ///
  /// In fr, this message translates to:
  /// **'Autres matières'**
  String get reportOtherSubjects;

  /// No description provided for @reportCoefficient.
  ///
  /// In fr, this message translates to:
  /// **'Coeff. {value}'**
  String reportCoefficient(Object value);

  /// No description provided for @gradeMin.
  ///
  /// In fr, this message translates to:
  /// **'Min.'**
  String get gradeMin;

  /// No description provided for @gradeMax.
  ///
  /// In fr, this message translates to:
  /// **'Max.'**
  String get gradeMax;

  /// No description provided for @noCourseToday.
  ///
  /// In fr, this message translates to:
  /// **'Tu n\'as pas de cours,\nprofite bien !'**
  String get noCourseToday;

  /// No description provided for @holidayDay.
  ///
  /// In fr, this message translates to:
  /// **'C\'est les vacances,\namuse toi bien !'**
  String get holidayDay;

  /// No description provided for @weekend.
  ///
  /// In fr, this message translates to:
  /// **'C\'est le weekend !'**
  String get weekend;

  /// No description provided for @lunch.
  ///
  /// In fr, this message translates to:
  /// **'Bon appétit !'**
  String get lunch;

  /// No description provided for @gap.
  ///
  /// In fr, this message translates to:
  /// **'{duration} de libre'**
  String gap(Object duration);

  /// No description provided for @cancelled.
  ///
  /// In fr, this message translates to:
  /// **'ANNULÉ'**
  String get cancelled;

  /// No description provided for @detention.
  ///
  /// In fr, this message translates to:
  /// **'Retenue'**
  String get detention;

  /// No description provided for @pedagogicalActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité pédagogique'**
  String get pedagogicalActivity;

  /// No description provided for @noSubject.
  ///
  /// In fr, this message translates to:
  /// **'Matière inconnue'**
  String get noSubject;

  /// No description provided for @noRoom.
  ///
  /// In fr, this message translates to:
  /// **'Salle non définie'**
  String get noRoom;

  /// No description provided for @contentTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Enseignants'**
  String get contentTeachers;

  /// No description provided for @contentPersonal.
  ///
  /// In fr, this message translates to:
  /// **'Personnels'**
  String get contentPersonal;

  /// No description provided for @contentClassrooms.
  ///
  /// In fr, this message translates to:
  /// **'Salles de classe'**
  String get contentClassrooms;

  /// No description provided for @contentVirtualClassrooms.
  ///
  /// In fr, this message translates to:
  /// **'Classes virtuelles'**
  String get contentVirtualClassrooms;

  /// No description provided for @contentClassGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get contentClassGroups;

  /// No description provided for @contentClasses.
  ///
  /// In fr, this message translates to:
  /// **'Classes'**
  String get contentClasses;

  /// No description provided for @contentUnknowns.
  ///
  /// In fr, this message translates to:
  /// **'Inconnus'**
  String get contentUnknowns;

  /// No description provided for @recipient.
  ///
  /// In fr, this message translates to:
  /// **'À {recipient}'**
  String recipient(Object recipient);

  /// No description provided for @self.
  ///
  /// In fr, this message translates to:
  /// **'moi'**
  String get self;

  /// No description provided for @nominativePoll.
  ///
  /// In fr, this message translates to:
  /// **'sondage nominatif'**
  String get nominativePoll;

  /// No description provided for @anonymousPoll.
  ///
  /// In fr, this message translates to:
  /// **'sondage anonyme'**
  String get anonymousPoll;

  /// No description provided for @raMessage.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai pris connaissance de cette information'**
  String get raMessage;

  /// No description provided for @couldNotLoad.
  ///
  /// In fr, this message translates to:
  /// **'L\'instance m\'a pas pu être chargée…'**
  String get couldNotLoad;

  /// No description provided for @instanceName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'instance'**
  String get instanceName;

  /// No description provided for @instanceNameValue.
  ///
  /// In fr, this message translates to:
  /// **'{mainName} ({loginName} quand déconnecté)'**
  String instanceNameValue(Object loginName, Object mainName);

  /// No description provided for @remoteVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version de l\'instance'**
  String get remoteVersion;

  /// No description provided for @remoteYear.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get remoteYear;

  /// No description provided for @remoteYearSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{start} ➔ {end}'**
  String remoteYearSubtitle(DateTime start, DateTime end);

  /// No description provided for @remotePeriods.
  ///
  /// In fr, this message translates to:
  /// **'Périodes'**
  String get remotePeriods;

  /// No description provided for @virtualClassroom.
  ///
  /// In fr, this message translates to:
  /// **'Visio'**
  String get virtualClassroom;

  /// No description provided for @homeworkSetDone.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai terminé'**
  String get homeworkSetDone;

  /// No description provided for @homeworkSetNotDone.
  ///
  /// In fr, this message translates to:
  /// **'Je n\'ai pas terminé'**
  String get homeworkSetNotDone;

  /// No description provided for @weekNumber.
  ///
  /// In fr, this message translates to:
  /// **'Semaine {weekNumber}'**
  String weekNumber(Object weekNumber);

  /// No description provided for @homeworkDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get homeworkDescription;

  /// No description provided for @homeworkAttachments.
  ///
  /// In fr, this message translates to:
  /// **'Pièces jointes'**
  String get homeworkAttachments;

  /// No description provided for @givenTheForThe.
  ///
  /// In fr, this message translates to:
  /// **'Donné le {given} pour le {deadline}'**
  String givenTheForThe(DateTime given, DateTime deadline);

  /// No description provided for @homeworkDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get homeworkDifficulty;

  /// No description provided for @homeworkState.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get homeworkState;

  /// No description provided for @homeworkRenderPronote.
  ///
  /// In fr, this message translates to:
  /// **'À rendre en ligne'**
  String get homeworkRenderPronote;

  /// No description provided for @homeworkRenderNone.
  ///
  /// In fr, this message translates to:
  /// **'Rien à rendre'**
  String get homeworkRenderNone;

  /// No description provided for @homeworkRenderPaper.
  ///
  /// In fr, this message translates to:
  /// **'À rendre en main propre'**
  String get homeworkRenderPaper;

  /// No description provided for @homeworkRenderKiosque.
  ///
  /// In fr, this message translates to:
  /// **'À rendre au kiosque'**
  String get homeworkRenderKiosque;

  /// No description provided for @homeworkRenderPronoteAudio.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement audio à rendre en ligne'**
  String get homeworkRenderPronoteAudio;

  /// No description provided for @noHomeworkForWeek.
  ///
  /// In fr, this message translates to:
  /// **'Pas de travaux à faire pour cette semaine !'**
  String get noHomeworkForWeek;

  /// No description provided for @appSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de l\'application'**
  String get appSettings;

  /// No description provided for @goToAppSettings.
  ///
  /// In fr, this message translates to:
  /// **'Naviguer vers les paramètres de l\'application'**
  String get goToAppSettings;

  /// No description provided for @deviceTheme.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser le thème de l\'appareil'**
  String get deviceTheme;

  /// No description provided for @deviceThemeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Le thème utilisé dans l\'application changera selon le fond d\'écran.'**
  String get deviceThemeDescription;

  /// No description provided for @displayProfilePicture.
  ///
  /// In fr, this message translates to:
  /// **'Afficher la photo de profile'**
  String get displayProfilePicture;

  /// No description provided for @network.
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get network;

  /// No description provided for @reconnectAccount.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecter le compte'**
  String get reconnectAccount;

  /// No description provided for @sendNavigationRequests.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer les requêtes de navigation'**
  String get sendNavigationRequests;

  /// No description provided for @sendNavigationRequestsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Quand cette option est désactivée, des gains en latence et en données transférées peuvent être observés. Cependant, cela fait diverger le fonctionnement de l\'application de celle de PRONOTE.'**
  String get sendNavigationRequestsSubtitle;

  /// No description provided for @noMenuForToday.
  ///
  /// In fr, this message translates to:
  /// **'Pas de menu pour aujourd\'hui !'**
  String get noMenuForToday;

  /// No description provided for @menu.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @lunchFor.
  ///
  /// In fr, this message translates to:
  /// **'Déjeuner du {day}'**
  String lunchFor(DateTime day);

  /// No description provided for @dinnerFor.
  ///
  /// In fr, this message translates to:
  /// **'Dinner du {day}'**
  String dinnerFor(DateTime day);

  /// No description provided for @defaultConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration par défaut'**
  String get defaultConfig;

  /// No description provided for @breakConfig.
  ///
  /// In fr, this message translates to:
  /// **'Récréation'**
  String get breakConfig;

  /// No description provided for @transferConfig.
  ///
  /// In fr, this message translates to:
  /// **'Interclasse'**
  String get transferConfig;

  /// No description provided for @afterClassConfig.
  ///
  /// In fr, this message translates to:
  /// **'Après les cours'**
  String get afterClassConfig;

  /// No description provided for @beforeClassConfig.
  ///
  /// In fr, this message translates to:
  /// **'Avant les cours'**
  String get beforeClassConfig;

  /// No description provided for @lunchConfig.
  ///
  /// In fr, this message translates to:
  /// **'Demi-pension'**
  String get lunchConfig;

  /// No description provided for @pauseConfig.
  ///
  /// In fr, this message translates to:
  /// **'Étude'**
  String get pauseConfig;

  /// No description provided for @classConfig.
  ///
  /// In fr, this message translates to:
  /// **'Cours'**
  String get classConfig;

  /// No description provided for @explainCurrentConfig.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes en mode \"{mode}\"'**
  String explainCurrentConfig(String mode);

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @veryFavorable.
  ///
  /// In fr, this message translates to:
  /// **'Très favorable'**
  String get veryFavorable;

  /// No description provided for @veryFavorableAbbr.
  ///
  /// In fr, this message translates to:
  /// **'T. fav.'**
  String get veryFavorableAbbr;

  /// No description provided for @favorable.
  ///
  /// In fr, this message translates to:
  /// **'Favorable'**
  String get favorable;

  /// No description provided for @favorableAbbr.
  ///
  /// In fr, this message translates to:
  /// **'Fav.'**
  String get favorableAbbr;

  /// No description provided for @reserved.
  ///
  /// In fr, this message translates to:
  /// **'Réservé'**
  String get reserved;

  /// No description provided for @reservedAbbr.
  ///
  /// In fr, this message translates to:
  /// **'Rés.'**
  String get reservedAbbr;

  /// No description provided for @unfavorable.
  ///
  /// In fr, this message translates to:
  /// **'Défavorable'**
  String get unfavorable;

  /// No description provided for @unfavorableAbbr.
  ///
  /// In fr, this message translates to:
  /// **'Déf.'**
  String get unfavorableAbbr;

  /// No description provided for @none.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get none;

  /// No description provided for @boardOpinion.
  ///
  /// In fr, this message translates to:
  /// **'Avis du conseil de classe'**
  String get boardOpinion;

  /// No description provided for @shortDate.
  ///
  /// In fr, this message translates to:
  /// **'{date}'**
  String shortDate(DateTime date);

  /// No description provided for @shortWeekday.
  ///
  /// In fr, this message translates to:
  /// **'{date}'**
  String shortWeekday(DateTime date);

  /// No description provided for @monthDay.
  ///
  /// In fr, this message translates to:
  /// **'{date}'**
  String monthDay(DateTime date);

  /// No description provided for @communicationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'La page de communication sera disponible dans une prochaine mise à jour'**
  String get communicationUnavailable;

  /// No description provided for @application.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'ANTINOTE'**
  String get appName;

  /// No description provided for @appLegalese.
  ///
  /// In fr, this message translates to:
  /// **'L\'application ANTINOTE est libre et gratuite, disponible sous la license MIT. Nous rendons disponibles de nouvelles fonctionnalité grâce à une connection à votre compte PRONOTE. Nous ne sommes en aucun cas lié à Index-Education et nous ne proposons aucune garantie d\'aucune sorte quant à l\'utilisation du logiciel. Fait avec ❤ par l\'équipe ANTINOTE'**
  String get appLegalese;

  /// No description provided for @openAccountSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les paramètres de compte…'**
  String get openAccountSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
