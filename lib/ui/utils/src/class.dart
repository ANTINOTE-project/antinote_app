import 'package:antinote/antinote.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons_pro/hugeicons.dart';

extension ClassHelpers on Class {
  String classTitle(BuildContext context) =>
      contents
          .where(
            (element) => element is TitleContent || element is SubjectContent,
          )
          .map(
            (e) =>
                e is TitleContent ? e.value : (e as SubjectContent).value.name,
          )
          .firstOrNull ??
      switch (this) {
        Lesson lesson => lesson.subject?.name ?? context.l10n.noSubject,
        Activity _ => context.l10n.pedagogicalActivity,
        Detention _ => context.l10n.detention,
      };

  static const contentPriorities = [
    ClassroomContent,
    TeacherContent,
    PersonalContent,
    UnknownContent,
    ClassGroupContent,
    StudentClassContent,
    VirtualClassroomContent,
  ];

  List<ClassContent> listContents() {
    return contents
        .where(
          (element) => element is! TitleContent && element is! SubjectContent,
        )
        .toList(growable: false)
      ..sortByCompare(
        (element) => element.runtimeType,
        (a, b) => contentPriorities
            .indexOf(a)
            .compareTo(contentPriorities.indexOf(b)),
      );
  }

  int? get accentColor =>
      backgroundColor ??
      contents.whereType<SubjectContent>().firstOrNull?.value.backgroundColor;
}

extension ClassContentHelper on ClassContent {
  String? get data => switch (this) {
    TeacherContent(value: final v) => v.name,
    PersonalContent(value: final v) => v.name,

    ClassroomContent(value: final v) => v.label,
    VirtualClassroomContent(value: final v) => v.toString(),

    ClassGroupContent(value: final v) => v.label,
    StudentClassContent(value: final v) => v.name,

    UnknownContent(value: final v) => v.get<String?>('L'),
    _ => null,
  };

  IconData? get icon => switch (this) {
    TeacherContent() => HugeIconsSolid.teacher,
    PersonalContent() => HugeIconsSolid.more,

    ClassroomContent() => HugeIconsSolid.meetingRoom,
    VirtualClassroomContent() => HugeIconsSolid.computerVideoCall,

    ClassGroupContent() => HugeIconsSolid.userGroup,
    StudentClassContent() => HugeIconsSolid.students,

    UnknownContent() => HugeIconsSolid.fileUnknown,
    _ => null,
  };

  String? label(BuildContext context) => switch (this) {
    TeacherContent() => context.l10n.contentTeachers,
    PersonalContent() => context.l10n.contentPersonal,

    ClassroomContent() => context.l10n.contentClassrooms,
    VirtualClassroomContent() => context.l10n.contentVirtualClassrooms,

    ClassGroupContent() => context.l10n.contentClassGroups,
    StudentClassContent() => context.l10n.contentClasses,

    UnknownContent() => context.l10n.contentUnknowns,
    _ => null,
  };
}
