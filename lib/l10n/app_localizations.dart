import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'ANTINOTE'**
  String get appTitle;

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

  /// No description provided for @choseAnAccount.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un compte'**
  String get choseAnAccount;

  /// No description provided for @addAnAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un compte'**
  String get addAnAccount;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @disableAutoLogin.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver la connexion automatique'**
  String get disableAutoLogin;

  /// No description provided for @enableAutoLogin.
  ///
  /// In fr, this message translates to:
  /// **'Activer la connexion automatique'**
  String get enableAutoLogin;

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
  /// **'Rentre l\'adresse du PRONOTE de ton établissement'**
  String get loginUrl;

  /// No description provided for @loginUrlSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne l\'URL de ton espace PRONOTE pour t\'y connecter directement'**
  String get loginUrlSubtitle;

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

  /// No description provided for @loginWebview.
  ///
  /// In fr, this message translates to:
  /// **'Connecte toi à ton compte'**
  String get loginWebview;

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
  /// **'Infos'**
  String get communication;

  /// No description provided for @report.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin'**
  String get report;

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

  /// No description provided for @gradeFelicitations.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations'**
  String get gradeFelicitations;

  /// No description provided for @noCourseToday.
  ///
  /// In fr, this message translates to:
  /// **'Tu n\'as pas de cours,\nprofite bien !'**
  String get noCourseToday;

  /// No description provided for @holidayDay.
  ///
  /// In fr, this message translates to:
  /// **'C\'est les vacances,\n amuse toi bien !'**
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
  /// **'Sondage nominatif'**
  String get nominativePoll;

  /// No description provided for @anonymousPoll.
  ///
  /// In fr, this message translates to:
  /// **'Sondage anonyme'**
  String get anonymousPoll;

  /// No description provided for @raMessage.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai pris connaissance de cette information'**
  String get raMessage;

  /// No description provided for @couldNotLoad.
  ///
  /// In fr, this message translates to:
  /// **'L\'instance m\'a pas pu être chargée...'**
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
  String remoteYearSubtitle(Object end, Object start);

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
  String givenTheForThe(Object deadline, Object given);

  /// No description provided for @homeworkDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté'**
  String get homeworkDifficulty;
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
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
