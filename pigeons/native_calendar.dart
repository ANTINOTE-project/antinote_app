import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/backend/src/pigeon_posts/native_calendar.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/fr/helomri/antinote_ui/pigeon_posts/NativeCalendar.g.kt',
    kotlinOptions: KotlinOptions(
      errorClassName: 'CalendarManagerError',
      package: 'fr.helomri.studies_management.antinote_ui.pigeon_posts',
    ),
    dartPackageName: 'antinote_ui',
  ),
)
//
//
enum CalendarEventEntryType { clazz }

enum AttendeeType { teacher, group, classroom, helper }

final class AttendeeEntry {
  final String name;
  final String instanceDomain;
  final String visualId;
  final AttendeeType type;

  const AttendeeEntry({
    required this.name,
    required this.instanceDomain,
    required this.visualId,
    required this.type,
  });
}

final class ExistingCalendarEventEntry {
  final String accountUid;
  final int calendarId;
  final int id;
  final String? originalVisualId;
  final String visualId;
  final String rrule;
  final int startTime;
  final List<int> exceptions;
  final CalendarEventEntryType entryType;

  const ExistingCalendarEventEntry({
    required this.accountUid,
    required this.calendarId,
    required this.id,
    required this.originalVisualId,
    required this.visualId,
    required this.rrule,
    required this.startTime,
    required this.exceptions,
    required this.entryType,
  });
}

final class NewExceptionCalendarEventEntry {
  final int start;
  final int end;
  final String title;
  final String descriptions;
  final String? location;
  final int color;
  final String visualId;
  final bool canceled;

  final List<AttendeeEntry> attendees;

  const NewExceptionCalendarEventEntry({
    required this.start,
    required this.end,
    required this.title,
    required this.descriptions,
    required this.location,
    required this.color,
    required this.visualId,
    required this.canceled,
    required this.attendees,
  });
}

final class NewRecurringCalendarEventEntry {
  final String accountUid;
  final int mockStart;
  final String duration;
  final String? rrule;
  final String? rdate;
  final String exdate;
  final int calendarId;
  final String title;
  final String descriptions;
  final String? location;
  final int color;
  final bool allDay;
  final String visualId;
  final CalendarEventEntryType entryType;
  final bool canceled;

  final List<NewExceptionCalendarEventEntry> exceptions;

  final List<AttendeeEntry> attendees;

  const NewRecurringCalendarEventEntry({
    required this.accountUid,
    required this.mockStart,
    required this.duration,
    required this.rrule,
    required this.rdate,
    required this.exdate,
    required this.calendarId,
    required this.title,
    required this.descriptions,
    required this.location,
    required this.color,
    required this.allDay,
    required this.visualId,
    required this.entryType,
    required this.canceled,
    required this.exceptions,
    required this.attendees,
  });
}

final class ExistingCalendarEntry {
  final String accountUid;
  final String resourceVisualId;
  final int id;
  final String displayName;
  final int color;

  const ExistingCalendarEntry({
    required this.accountUid,
    required this.resourceVisualId,
    required this.id,
    required this.displayName,
    required this.color,
  });
}

final class NewCalendarEntry {
  final String displayName;
  final String accountUid;
  final String resourceVisualId;
  final int color;

  const NewCalendarEntry({
    required this.displayName,
    required this.accountUid,
    required this.resourceVisualId,
    required this.color,
  });
}

@HostApi()
abstract class NativeCalendarManager {
  List<ExistingCalendarEventEntry> listExisting(
    String accountUid,
    int calendarId,
  );

  List<ExistingCalendarEntry> listCalendars(String accountUid);

  void deleteCalendar(String accountUid, int calendarId);

  void insertNew(List<NewRecurringCalendarEventEntry> entries);

  void deleteExisting(List<ExistingCalendarEventEntry> entries);

  ExistingCalendarEntry insertNewCalendar(NewCalendarEntry calendar);
}
