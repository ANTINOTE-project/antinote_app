import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/index.dart";
import "package:flutter/material.dart";

typedef ClassInfo = ({
  String baseTitle,
  String? status,
  String attendants,
  String? groups,
  String? location,
  int? accentColor,
  bool cancelled,
  bool isExam,
});

class TimetableBody extends StatelessWidget {
  final List<DateTime> days;
  final Classes classes;

  const TimetableBody({super.key, required this.days, required this.classes});

  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisGroup(
      slivers: [
        for (final day in days)
          ValueListenableBuilder(
            valueListenable: classes[day]!,

            builder: (context, classes, child) {
              if (classes != null) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),

                  sliver: SliverList.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) => _ClassWidget(clazz: classes[index]),
                  ),
                );
              }

              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            },
          ),
      ],
    );
  }
}

class _ClassWidget extends StatelessWidget {
  final Class clazz;

  const _ClassWidget({required this.clazz});

  static String _formatAttendants(List teachers, List personal) => [
    teachers.map((e) => e.name).join(", "),
    if (personal.isNotEmpty) '(+ ${personal.map((e) => e.name).join(', ')})',
  ].join(" ");

  static int? _resolveAccentColor(int? subjectBg, int? classBg) => subjectBg ?? (classBg);

  ClassInfo _info(BuildContext context) => switch (clazz) {
    Lesson(
      subject: final subject,
      status: final status,
      canceled: final canceled,
      exemptedLabel: final exempted,
      teachers: final teachers,
      personals: final personal,
      groups: final groups,
      classrooms: final classrooms,
      notebookEntryPreview: final preview,
      backgroundColor: final bg,
    ) =>
      (
        baseTitle: subject?.name ?? context.l10n.noSubject,
        status: status?.toUpperCase() ?? (canceled ? context.l10n.cancelled : exempted),
        attendants: _formatAttendants(teachers, personal),
        groups: groups.isEmpty ? null : groups.map((e) => e.label).join(", "),
        location: classrooms.map((e) => e.label).join(", "),
        accentColor: _resolveAccentColor(subject?.backgroundColor, bg),
        cancelled: canceled || exempted != null,
        isExam: preview?.isTest ?? false,
      ),

    Activity(title: final title, attendants: final attendants) => (
      baseTitle: title,
      status: null,
      attendants: attendants.join(", "),
      groups: null,
      location: null,
      accentColor: _resolveAccentColor(null, clazz.backgroundColor),
      cancelled: false,
      isExam: false,
    ),

    Detention(
      title: final title,
      teachers: final teachers,
      personals: final personal,
      classrooms: final classrooms,
    ) =>
      (
        baseTitle: title ?? context.l10n.detention,
        status: null,
        attendants: _formatAttendants(teachers, personal),
        groups: null,
        location: classrooms.map((e) => e.label).join(", "),
        accentColor: _resolveAccentColor(null, clazz.backgroundColor),
        cancelled: false,
        isExam: false,
      ),
  };

  @override
  Widget build(BuildContext context) {
    final info = _info(context);

    final colorValue = info.accentColor?.classAccentToBackgroundColor(
      isLightTheme: context.c.brightness == .light,
    );

    final color = colorValue != null ? Color(colorValue) : null;

    return Container(
      decoration: BoxDecoration(color: color, borderRadius: const .all(.circular(20))),
      padding: const .symmetric(horizontal: 12, vertical: 8),

      child: Column(children: [if (info.status != null) Text(info.status!), Text(info.baseTitle)]),
    );
  }
}
