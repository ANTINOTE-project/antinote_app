import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/backend/src/pigeon_posts/native_calendar.g.dart";
import "package:flutter/material.dart";
import "package:rrule/rrule.dart";

final class _ClassInstanceEvent {
  final int start;
  final int end;
  final String title;
  final String description;
  final String? location;
  final int color;
  final DateTime startTime;
  final DateTime endTime;
  final String visualId;
  final bool canceled;
  final List<AttendeeEntry> attendees;

  const _ClassInstanceEvent({
    required this.start,
    required this.end,
    required this.title,
    required this.description,
    required this.location,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.visualId,
    required this.canceled,
    required this.attendees,
  });

  factory _ClassInstanceEvent.fromClass(
    Class clazz,
    String instanceDomain,
    String address,
  ) {
    String className;
    final String? location;

    if (clazz is Lesson) {
      className = clazz.subject?.name ?? "Matière non désignée";
      if (clazz.status != null) {
        className = "[${clazz.status!.toUpperCase()}] $className";
      }

      location = address;
    } else if (clazz is Detention) {
      className = "Retenue";
      location = address;
    } else if (clazz is Activity) {
      className = "Activité pédagogique";
      location = null;
    } else {
      throw UnimplementedError();
    }

    final attendees = <AttendeeEntry>[];

    final descriptionBuilder = StringBuffer();

    if (clazz.notes != null) {
      descriptionBuilder.writeln("Notes : ${clazz.notes!}");
    }

    if (clazz is Lesson) {
      for (final teacher in clazz.teachers) {
        attendees.add(
          AttendeeEntry(
            name: teacher.name,
            instanceDomain: instanceDomain,
            visualId: teacher.visualIdUrl,
            type: .teacher,
          ),
        );
      }
      for (final group in clazz.groups) {
        attendees.add(
          AttendeeEntry(
            name: "${group.label} (groupe)",
            instanceDomain: instanceDomain,
            visualId: group.visualIdUrl,
            type: .group,
          ),
        );
      }
      for (final classroom in clazz.classrooms) {
        attendees.add(
          AttendeeEntry(
            name: classroom.label,
            instanceDomain: instanceDomain,
            visualId: classroom.visualIdUrl,
            type: .classroom,
          ),
        );
      }
      for (final personal in clazz.personals) {
        attendees.add(
          AttendeeEntry(
            name: personal.name,
            instanceDomain: instanceDomain,
            visualId: personal.visualIdUrl,
            type: .helper,
          ),
        );
      }

      if (clazz.virtualClassrooms.isNotEmpty) {
        descriptionBuilder.writeln("Classes virtuelles :");
        for (int i = 0; i < clazz.virtualClassrooms.length; i++) {
          descriptionBuilder.write(
            "- ${clazz.virtualClassrooms[i].toString()}",
          );

          if (i + 1 < clazz.virtualClassrooms.length) {
            descriptionBuilder.writeln();
          }
        }
      }
    } else if (clazz is Activity) {
      for (final personal in clazz.attendants) {
        attendees.add(
          AttendeeEntry(
            name: personal,
            instanceDomain: instanceDomain,
            visualId: personal.visualIdData().visualId,
            type: .helper,
          ),
        );
      }
    } else if (clazz is Detention) {
      for (final teacher in clazz.teachers) {
        attendees.add(
          AttendeeEntry(
            name: teacher.name,
            instanceDomain: instanceDomain,
            visualId: teacher.visualId,
            type: .teacher,
          ),
        );
      }
      for (final personal in clazz.personals) {
        attendees.add(
          AttendeeEntry(
            name: personal.name,
            instanceDomain: instanceDomain,
            visualId: personal.visualId,
            type: .helper,
          ),
        );
      }
    } else {
      throw UnimplementedError();
    }

    return _ClassInstanceEvent(
      start: clazz.startDate
          .copyWith(isUtc: false)
          .toUtc()
          .millisecondsSinceEpoch,
      end: clazz.endDate.copyWith(isUtc: false).toUtc().millisecondsSinceEpoch,
      title: className,
      description: descriptionBuilder.toString(),
      location: location,
      color: clazz.backgroundColor ?? Colors.white.toARGB32(),
      startTime: clazz.startDate,
      endTime: clazz.endDate,
      visualId: clazz.visualId,
      canceled: clazz is Lesson ? clazz.canceled : false,
      attendees: attendees,
    );
  }
}

extension ToNewRecurringCalendarEventEntry on RecurringClass {
  NewRecurringCalendarEventEntry toNewRecurringCalendarEventEntry(
    String accountUid,
    int calendarId,
    String instanceDomain,
    String address,
  ) {
    String? recurrenceRule;
    if (calendarPeriodicity != null) {
      recurrenceRule = RecurrenceRule(
        frequency: Frequency.weekly,
        interval: (calendarPeriodicity?.inDays ?? 7) ~/ 7,
        until: occurrences.last.startTime.copyWith(isUtc: false).toUtc(),
      ).toString(options: const RecurrenceRuleToStringOptions(isTimeUtc: true));

      if (recurrenceRule.startsWith("RRULE:")) {
        recurrenceRule = recurrenceRule.substring(6);
      }
    }

    final mainInstance = _ClassInstanceEvent.fromClass(
      mockClass,
      instanceDomain,
      address,
    );
    final exceptions = this.exceptions.values.map(
      (e) => _ClassInstanceEvent.fromClass(e, instanceDomain, address),
    );

    return NewRecurringCalendarEventEntry(
      accountUid: accountUid,
      mockStart: occurrences.first.startTime
          .copyWith(isUtc: false)
          .toUtc()
          .millisecondsSinceEpoch,
      duration:
          "P${mockClass.endDate.difference(mockClass.startDate).inSeconds}S",
      rrule: recurrenceRule,
      rdate: recurrenceRule != null
          ? null
          : occurrences
                .map(
                  (e) => icalUtcDateFormat.format(
                    e.startTime.copyWith(isUtc: false).toUtc(),
                  ),
                )
                .join(","),
      exdate: [
        ...calendarExceptions.map(
          (e) => icalUtcDateFormat.format(e.copyWith(isUtc: false).toUtc()),
        ),
        // ...exceptions.map(
        //   (e) => IcalUtcDateFormat.format(
        //     e.startTime.copyWith(isUtc: false).toUtc(),
        //   ),
        // ),
      ].join(","),
      calendarId: calendarId,
      title: mainInstance.title,
      descriptions: mainInstance.description,
      location: mainInstance.location,
      color: mainInstance.color,
      allDay: false,
      visualId: mainInstance.visualId,
      entryType: .clazz,
      canceled: mainInstance.canceled,
      exceptions: exceptions
          .map(
            (e) => NewExceptionCalendarEventEntry(
              start: e.start,
              end: e.end,
              title: e.title,
              descriptions: e.description,
              location: e.location,
              color: e.color,
              visualId: e.visualId,
              canceled: e.canceled,
              attendees: e.attendees,
            ),
          )
          .toList(growable: false),
      attendees: mainInstance.attendees,
    );
  }
}
