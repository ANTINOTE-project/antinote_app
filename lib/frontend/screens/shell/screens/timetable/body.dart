import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/index.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

typedef ClassInfo = ({
  String baseTitle,
  String? status,
  String attendants,
  String? groups,
  String? location,
  DateTime start,
  DateTime end,
  int? accentColor,
  bool cancelled,
  bool isExam,
});

class TimetableBody extends StatelessWidget {
  final List<DateTime> days;
  final Classes classes;

  const TimetableBody({super.key, required this.days, required this.classes});

  Map<(DateTime, DateTime), List<Class>> _groupByTime(List<Class> classes) {
    final Map<(DateTime, DateTime), List<Class>> grouped = {};

    for (final c in classes) {
      final key = (c.startDate, c.endDate);
      grouped.putIfAbsent(key, () => []).add(c);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisGroup(
      slivers: [
        for (final day in days)
          ValueListenableBuilder(
            valueListenable: classes[day]!,

            builder: (context, dayClasses, child) {
              if (dayClasses == null) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              if (dayClasses.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: .center,
                      spacing: 6,

                      children: [
                        Icon(HugeIconsSolid.course, size: 44, color: context.c.outline),

                        Text(
                          context.l10n.noCourseToday,

                          style: TextStyle(fontWeight: .bold, color: context.c.outline),
                          textAlign: .center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final grouped = _groupByTime(dayClasses);
              final entries = grouped.entries.toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),

                sliver: SliverList.builder(
                  itemCount: entries.length,

                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _TimeRow(start: entry.key.$1, end: entry.key.$2, classes: entry.value);
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _TimeRow extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final List<Class> classes;

  const _TimeRow({required this.start, required this.end, required this.classes});

  @override
  State<_TimeRow> createState() => _TimeRowState();
}

class _TimeRowState extends State<_TimeRow> {
  bool get _hasMultipleCourses => widget.classes.length > 1;

  Class get _currentClass => widget.classes[_classIndex];
  int _classIndex = 0;

  String _fmt(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,

          children: [
            SizedBox(
              width: 56,

              child: Column(
                mainAxisAlignment: .center,

                children: [
                  Text(_fmt(widget.start), style: const TextStyle(fontSize: 17, fontWeight: .w900)),

                  Text(
                    _fmt(widget.end),
                    style: TextStyle(fontSize: 15, fontWeight: .w600, color: context.c.outline),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _hasMultipleCourses
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),

                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,

                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.2, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn));

                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },

                      child: _ClassWidget(key: ValueKey(_currentClass), clazz: _currentClass),
                    )
                  : _ClassWidget(clazz: _currentClass),
            ),

            if (widget.classes.length > 1)
              Pressable(
                onPressed: () {
                  setState(() {
                    _classIndex = (_classIndex + 1) % widget.classes.length;
                  });
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: context.c.surfaceContainerHigh,
                    borderRadius: const .all(.circular(20)),
                  ),

                  width: 30,

                  child: Icon(
                    _classIndex == widget.classes.length - 1
                        ? HugeIconsSolid.arrowLeft01
                        : HugeIconsSolid.arrowRight01,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassWidget extends StatelessWidget {
  final Class clazz;

  const _ClassWidget({super.key, required this.clazz});

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
        start: clazz.startDate,
        end: clazz.endDate,
        accentColor: _resolveAccentColor(subject?.backgroundColor, bg),
        cancelled: canceled || exempted != null,
        isExam: preview?.isTest ?? false,
      ),

    Activity(
      title: final title,
      attendants: final attendants,
      startDate: final startDate,
      endDate: final endDate,
    ) =>
      (
        baseTitle: title,
        status: null,
        attendants: attendants.join(", "),
        groups: null,
        location: null,
        start: startDate,
        end: endDate,
        accentColor: _resolveAccentColor(null, clazz.backgroundColor),
        cancelled: false,
        isExam: false,
      ),

    Detention(
      title: final title,
      teachers: final teachers,
      personals: final personal,
      classrooms: final classrooms,
      startDate: final startDate,
      endDate: final endDate,
    ) =>
      (
        baseTitle: title ?? context.l10n.detention,
        status: null,
        attendants: _formatAttendants(teachers, personal),
        groups: null,
        location: classrooms.map((e) => e.label).join(", "),
        start: startDate,
        end: endDate,
        accentColor: _resolveAccentColor(null, clazz.backgroundColor),
        cancelled: false,
        isExam: false,
      ),
  };

  @override
  Widget build(BuildContext context) {
    final info = _info(context);

    final isLightTheme = context.c.brightness == .light;
    final colorValue = info.accentColor?.classAccentToBackgroundColor(isLightTheme: isLightTheme);

    final color = colorValue != null ? Color(colorValue) : null;
    final location = info.location ?? context.l10n.noRoom;

    return Pressable(
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: const .all(.circular(20))),
        padding: const .symmetric(horizontal: 12, vertical: 8),

        child: Column(
          crossAxisAlignment: .start,
          spacing: 16,

          children: [
            Text(info.baseTitle, style: const TextStyle(fontSize: 18, fontWeight: .w800)),

            Column(
              spacing: 6,

              children: [
                Row(
                  spacing: 6,

                  children: [
                    Icon(HugeIconsSolid.teacher, size: 20, color: context.c.onSurfaceVariant),

                    Text(
                      info.attendants,

                      maxLines: 1,
                      overflow: .ellipsis,

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: .w600,
                        color: context.c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                Row(
                  spacing: 6,

                  children: [
                    Icon(HugeIconsSolid.location01, size: 20, color: context.c.onSurfaceVariant),

                    Text(
                      location,

                      maxLines: 1,
                      overflow: .ellipsis,

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: .w600,
                        color: context.c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
