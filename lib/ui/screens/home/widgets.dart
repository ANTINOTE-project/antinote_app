import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/compact_card.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/grade_text.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:antinote_app/ui/widgets/remote_html.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class HomeWidget extends StatelessWidget {
  final String label;
  final Widget content;
  final VoidCallback onShowMorePressed;

  const HomeWidget({
    super.key,
    required this.label,
    required this.content,
    required this.onShowMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 10, vertical: 8),
      width: double.infinity,

      decoration: BoxDecoration(
        border: .all(color: context.c.outlineVariant),
        color: context.c.surfaceContainer,
        borderRadius: .circular(20),
      ),

      child: Column(
        spacing: 8,

        children: [
          Padding(
            padding: const .only(left: 4),

            child: Row(
              mainAxisAlignment: .spaceBetween,
              spacing: 6,

              children: [
                Expanded(
                  child: Text(
                    label,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: const TextStyle(fontWeight: .w800, fontSize: 19),
                  ),
                ),

                Pressable(
                  borderRadius: .circular(999),
                  onPressed: onShowMorePressed,

                  child: Ink(
                    decoration: BoxDecoration(
                      color: context.c.surfaceContainerLow,
                      borderRadius: .circular(999),
                    ),

                    padding: const .symmetric(horizontal: 12, vertical: 8),

                    child: Row(
                      spacing: 6,

                      children: [
                        Text(
                          context.l10n.homeShowMore,

                          style: TextStyle(
                            color: context.c.outline,
                            fontWeight: .bold,
                            fontSize: 14,
                          ),
                        ),

                        Icon(
                          HugeIconsSolid.arrowUpRight02,
                          color: context.c.outline,
                          size: 21,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          content,
        ],
      ),
    );
  }
}

class AttendanceWidget extends StatelessWidget {
  final VieScolaire data;

  const AttendanceWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      onShowMorePressed: () {},

      label: data.absences.length > 5
          ? '${context.l10n.homeAttendance} (+${data.absences.length - 5})'
          : context.l10n.homeAttendance,

      content: ListWidget(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        isSliver: false,
        isColumn: true,

        items: data.absences.take(5).toList(),

        itemBuilder: (context, absence, borderRadius) {
          final isJustified = absence.reasons.isNotEmpty;
          final title = isJustified
              ? absence.reasons.map((e) => e.name).join(', ')
              : context.l10n.absenceNotJustified;

          return ItemWidget(
            backgroundColor: context.c.surfaceContainerHigh,
            borderRadius: borderRadius,

            leading: Icon(
              isJustified ? HugeIconsSolid.tick03 : HugeIconsSolid.cancel02,
              color: isJustified ? context.c.primary : context.c.errorContainer,
            ),

            title: Text(title),
            subtitle: absence.start == null || absence.end == null
                ? null
                : Text(
                    context.l10n.absenceDuration(
                      absence.start!,
                      absence.start!,
                      absence.end!,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class ExamsWidget extends StatelessWidget {
  final DS data;

  const ExamsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      label: context.l10n.homeExams,
      onShowMorePressed: () {},
      content: const SizedBox.shrink(),
    );
  }
}

class GradesWidget extends StatelessWidget {
  final Notes data;

  const GradesWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final exams = List<Exam>.from(data.page.exams);
    exams.sort((a, b) => b.date.compareTo(a.date));

    return HomeWidget(
      label: exams.length > 5
          ? '${context.l10n.grades} (+${exams.length - 5})'
          : context.l10n.grades,

      onShowMorePressed: () {
        context.sc.goToTab(.grades);
      },

      content: ListWidget(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        isSliver: false,
        isColumn: true,

        items: exams.take(5).toList(),

        itemBuilder: (context, exam, _) {
          return _GradeCard(exam: exam);
        },
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final Exam exam;

  const _GradeCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, exam.service.color);

    final title = Utils.getExamComment(context, exam);
    final subtitle = exam.date.asRelativeDate(context);

    return CompactCard(
      scheme: scheme,
      title: title,

      subtitle: Text(
        subtitle,
        style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: .bold),
      ),

      trailing: GradeText(
        selfGrade: exam.selfGrade,
        maxGrade: exam.theoreticalMaxGrade,
        defaultMaxGrade: exam.defaultMaxGrade,
        color: scheme.primary,
        size: 16,
      ),
    );
  }
}

class HomeworksWidget extends StatelessWidget {
  final TravailAFaire data;

  const HomeworksWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final homeworks = List<Homework>.from(data.homeworks);
    homeworks.sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));

    return HomeWidget(
      label: homeworks.length > 5
          ? '${context.l10n.homeworks} (+${homeworks.length - 5})'
          : context.l10n.homeworks,

      onShowMorePressed: () {
        context.sc.goToTab(.homeworks);
      },

      content: ListWidget(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        isSliver: false,
        isColumn: true,

        items: homeworks.take(5).toList(),

        itemBuilder: (context, homework, _) {
          return _HomeworkCard(homework: homework);
        },
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;

  const _HomeworkCard({required this.homework});

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);

    return CompactCard(
      scheme: scheme,

      title: homework.subject.name ?? context.l10n.noSubject,

      subtitle: RemoteHtml(
        rawHtml: homework.description,
        compact: true,
        maxLines: 1,

        style: TextStyle(
          color: scheme.onSurface,
          fontWeight: .w600,
          fontSize: 15,
        ),
      ),

      trailing: Column(
        crossAxisAlignment: .end,
        spacing: 4,

        children: [
          Text(
            homework.deadlineDate.asRelativeWeekday(context),
            style: TextStyle(fontWeight: .bold, color: scheme.outline),
          ),

          Icon(
            homework.isDone ? HugeIconsSolid.tick03 : HugeIconsStroke.tick03,
            color: homework.isDone ? scheme.onPrimaryContainer : scheme.outline,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class NewsWidget extends StatelessWidget {
  final Actualites data;

  const NewsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      label: context.l10n.homeNews,

      onShowMorePressed: () {
        context.sc.goToTab(.communication);
      },

      content: const SizedBox.shrink(),
    );
  }
}
