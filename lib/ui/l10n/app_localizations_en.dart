// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get theme => 'Theme';

  @override
  String get themePrimary => 'Primary';

  @override
  String get themeSecondary => 'Secondary';

  @override
  String get themeTertiary => 'Tertiary';

  @override
  String get themeSurface => 'Surface';

  @override
  String get themeError => 'Error';

  @override
  String get themeCoral => 'Coral';

  @override
  String get themeIndigo => 'Indigo';

  @override
  String get themeGreen => 'Green';

  @override
  String get themeTeal => 'Teal';

  @override
  String get themePurple => 'Purple';

  @override
  String get themeBlue => 'Blue';

  @override
  String get themeAmber => 'Amber';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get cancel => 'Cancel';

  @override
  String get validate => 'Confirm';

  @override
  String get retry => 'Try again';

  @override
  String get home => 'Home';

  @override
  String get timetable => 'Timetable';

  @override
  String get grades => 'Grades';

  @override
  String get homeworks => 'Homework';

  @override
  String get communication => 'Inbox';

  @override
  String get autoLogin => 'Auto-login';

  @override
  String get autoLoginSubtitle =>
      'Marks this account to open upon the start of the app';

  @override
  String get secureStore => 'Secure store';

  @override
  String get secureStoreSubtitle =>
      'Asks for biometrics each time a new connection to this account is made';

  @override
  String get chooseAnAccount => 'Pick account';

  @override
  String get chooseAnAccountSubtitle => 'Change account or add one';

  @override
  String get addAnAccount => 'Add account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get accounts => 'Accounts';

  @override
  String get loginQrCode => 'QR Code';

  @override
  String get loginQrCodeSubtitle =>
      'Scan a QR Code from your computer that\'s already logged into PRONOTE';

  @override
  String get loginQrCodeFromGallery => 'Pick from gallery';

  @override
  String get loginCity => 'Find your city';

  @override
  String get loginCitySubtitle =>
      'Enter the name of your city and pick your school';

  @override
  String get loginUrl => 'School PRONOTE URL';

  @override
  String get loginUrlSubtitle =>
      'Enter the URL to your PRONOTE instance to login';

  @override
  String get loginButton => 'Login';

  @override
  String get loginSchool => 'Pick your school';

  @override
  String get loginSelect => 'Pick your workspace';

  @override
  String get activateCas => 'Connect via your DW';

  @override
  String get loginCredentials => 'Enter your credentials';

  @override
  String get loginToAccount => 'Connect to your account';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginPinCode => 'PIN code';

  @override
  String get loginPinCodeSubtitle =>
      'Please enter your PIN code to connect to your PRONOTE account';

  @override
  String get loginDemo => 'Demo account';

  @override
  String get loginDemoSubtitle =>
      'Login to a test account to explore the app and its features';

  @override
  String get homeShowMore => 'Show more';

  @override
  String get homeAttendance => 'School Life';

  @override
  String get homeNews => 'News';

  @override
  String get homeExams => 'Exams';

  @override
  String homeHiName(Object name) {
    return 'Hi $name!';
  }

  @override
  String get absenceNotJustified => 'Unjustified absence';

  @override
  String get absenceJustified => 'Justified absence';

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

    return '$dateString from $startTimeString to $endTimeString';
  }

  @override
  String get fieldNotFilled => 'Not specified';

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
  String get latestGrades => 'Latest grades';

  @override
  String get services => 'Services';

  @override
  String gradeOf(Object service) {
    return '$service grade';
  }

  @override
  String get averageSelf => 'General avg.';

  @override
  String get selfServiceAverage => 'Service avg.';

  @override
  String get averageClass => 'Class avg.';

  @override
  String get gradesHistory => 'Grades history';

  @override
  String get coefficient => 'Coefficient';

  @override
  String get gradeCount => 'Grade count';

  @override
  String get youGot => 'You got';

  @override
  String get bestGrade => 'Best grade';

  @override
  String get worstGrade => 'Worst grade';

  @override
  String get gradeAbsent => 'Abs';

  @override
  String get gradeAbsentZero => 'Abs (0)';

  @override
  String get gradeNotHanded => 'NH';

  @override
  String get gradeNotHandedZero => 'NH (0)';

  @override
  String get gradeExemption => 'Exmpt';

  @override
  String get gradeNotGraded => 'Not graded';

  @override
  String get gradeInapt => 'Inapt';

  @override
  String get gradeCongratulations => 'Congratulations';

  @override
  String get gradesReport => 'Report';

  @override
  String get classGradesReport => 'Class report';

  @override
  String get reportUnpublished => 'Report not yet published';

  @override
  String get reportComment => 'Comments';

  @override
  String get reportOtherSubjects => 'Other subjects';

  @override
  String reportCoefficient(Object value) {
    return 'Coef. $value';
  }

  @override
  String get gradeMin => 'Min.';

  @override
  String get gradeMax => 'Max.';

  @override
  String get noCourseToday => 'You don\'t have any class,\nenjoy!';

  @override
  String get holidayDay => 'It\'s a holiday,\nhave fun!';

  @override
  String get weekend => 'It\'s the weekend,\nrest well!';

  @override
  String get lunch => 'Bon appetit!';

  @override
  String gap(Object duration) {
    return '$duration of free time';
  }

  @override
  String get cancelled => 'CANCELED';

  @override
  String get detention => 'Detention';

  @override
  String get pedagogicalActivity => 'Pedagogical activity';

  @override
  String get noSubject => 'Unknown subject';

  @override
  String get noRoom => 'Undefined room';

  @override
  String get contentTeachers => 'Teachers';

  @override
  String get contentPersonal => 'Personal';

  @override
  String get contentClassrooms => 'Classrooms';

  @override
  String get contentVirtualClassrooms => 'Virtual classrooms';

  @override
  String get contentClassGroups => 'Groups';

  @override
  String get contentClasses => 'Classes';

  @override
  String get contentUnknowns => 'Unknowns';

  @override
  String recipient(Object recipient) {
    return 'To $recipient';
  }

  @override
  String get self => 'me';

  @override
  String get nominativePoll => 'nominative poll';

  @override
  String get anonymousPoll => 'anonymous poll';

  @override
  String get raMessage => 'I have taken note of this information';

  @override
  String get couldNotLoad => 'The instance could not be loaded...';

  @override
  String get instanceName => 'Instance name';

  @override
  String instanceNameValue(Object loginName, Object mainName) {
    return '$mainName ($loginName when disconnected)';
  }

  @override
  String get remoteVersion => 'Instance version';

  @override
  String get remoteYear => 'Year';

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
  String get remotePeriods => 'Periods';

  @override
  String get virtualClassroom => 'Conf. call';

  @override
  String get homeworkSetDone => 'I finished';

  @override
  String get homeworkSetNotDone => 'I did not finish';

  @override
  String weekNumber(Object weekNumber) {
    return 'Week $weekNumber';
  }

  @override
  String get homeworkDescription => 'Description';

  @override
  String get homeworkAttachments => 'Attachments';

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

    return 'Given on $givenString for $deadlineString';
  }

  @override
  String get homeworkDifficulty => 'Difficulty';

  @override
  String get homeworkState => 'State';

  @override
  String get homeworkRenderPronote => 'To be submitted online';

  @override
  String get homeworkRenderNone => 'Nothing to submit';

  @override
  String get homeworkRenderPaper => 'To be submitted by hand';

  @override
  String get homeworkRenderKiosque => 'To be submitted at the kiosk';

  @override
  String get homeworkRenderPronoteAudio =>
      'Audio recording to be submitted online';

  @override
  String get noHomeworkForWeek => 'No homework for this week!';

  @override
  String get appSettings => 'App settings';

  @override
  String get goToAppSettings => 'Go to app settings';

  @override
  String get deviceTheme => 'Use the device theme';

  @override
  String get deviceThemeDescription =>
      'The theme will change according to your wallpaper';

  @override
  String get displayProfilePicture => 'Show the profile picture';

  @override
  String get network => 'Network';

  @override
  String get reconnectAccount => 'Reconnect the account';

  @override
  String get sendNavigationRequests => 'Send navigation requests';

  @override
  String get sendNavigationRequestsSubtitle =>
      'When disabled, speed gains may be observed (this differs from the official app\'s behavior)';

  @override
  String get noMenuForToday => 'No menu for today!';

  @override
  String get menu => 'Menu';

  @override
  String lunchFor(DateTime day) {
    final intl.DateFormat dayDateFormat = intl.DateFormat('dd/MM', localeName);
    final String dayString = dayDateFormat.format(day);

    return 'Lunch for $dayString';
  }

  @override
  String dinnerFor(DateTime day) {
    final intl.DateFormat dayDateFormat = intl.DateFormat('dd/MM', localeName);
    final String dayString = dayDateFormat.format(day);

    return 'Dinner for $dayString';
  }

  @override
  String get defaultConfig => 'Default configuration';

  @override
  String get breakConfig => 'Break';

  @override
  String get transferConfig => 'Transfer';

  @override
  String get afterClassConfig => 'After class';

  @override
  String get beforeClassConfig => 'Before class';

  @override
  String get lunchConfig => 'Lunch';

  @override
  String get pauseConfig => 'Study time';

  @override
  String get classConfig => 'Class';

  @override
  String explainCurrentConfig(String mode) {
    return 'You are in more \"$mode\"';
  }

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get veryFavorable => 'Highly favorable';

  @override
  String get veryFavorableAbbr => 'H. fav.';

  @override
  String get favorable => 'Favorable';

  @override
  String get favorableAbbr => 'Fav.';

  @override
  String get reserved => 'Reservations';

  @override
  String get reservedAbbr => 'Rsvn.';

  @override
  String get unfavorable => 'Unfavorable';

  @override
  String get unfavorableAbbr => 'Unfav.';

  @override
  String get none => 'None';

  @override
  String get boardOpinion => 'Board opinion';

  @override
  String shortDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'EEEE dd MMMM',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String shortWeekday(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.EEEE(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String monthDay(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get communicationUnavailable =>
      'The communication page will be available in an upcoming update, stay tuned!';

  @override
  String get application => 'Application';

  @override
  String get about => 'About';

  @override
  String get appName => 'ANTINOTE';

  @override
  String get appLegalese =>
      'The ANTINOTE app is free and open-source, available under the MIT license. We offer new functionnality using a connection to your PRONOTE account. We are not affiliated with Index-Education, and we do not offer guaranties in any way, shape, of form regarding the use of this software. Made with ❤ by the ANTINOTE team';

  @override
  String get openAccountSettings => 'Open account settings…';

  @override
  String get homeworksNotificationDescription =>
      'Notification when a new homework is published';

  @override
  String newHomework(String subject, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$subject → $dateString';
  }

  @override
  String get accountSyncSettings => 'Background sync';

  @override
  String get accountSyncSettingsSubtitle =>
      'Choose what you want to sync in the background';

  @override
  String get accountNotFound => 'Account not found…';

  @override
  String get calendarSync => 'Calendar';

  @override
  String get calendarSyncSubtitle =>
      'Syncs your timetable with your phone\'s calendar and updates it in the backgorund';

  @override
  String get newsSync => 'News';

  @override
  String get newsSyncSubtitle =>
      'Upon the reception of a new discussion message';

  @override
  String get discussionSync => 'Direct Messages';

  @override
  String get discussionSyncSubtitle => 'When a DM is received';

  @override
  String get homeworkSync => 'Homeworks';

  @override
  String get homeworkSyncSubtitle => 'When new homework is published';

  @override
  String get gradeSync => 'Grades';

  @override
  String get gradeSyncSubtitle => 'When a new grade is published';

  @override
  String get menuSync => 'Menus';

  @override
  String get menuSyncSubtitle =>
      'Sent before lunch to tell you what the menu is';

  @override
  String get sync => 'Sync';

  @override
  String get syncing => 'Syncing…';

  @override
  String get syncSuccessful => 'Sync successful!';

  @override
  String get syncFailed => 'Sync failed…';

  @override
  String get markedThreadRead => 'The thread was marked as read';
}
