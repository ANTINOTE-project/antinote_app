import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/helpers/various.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/frontend/widgets/compact_card.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/grade_text.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class GradesWidget extends StatelessWidget {
  final Notes data;

  const GradesWidget({super.key, required this.data});

  List<Exam> get exams => data.page.exams;

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      label: context.l10n.grades,

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
        color: scheme.primary,
        size: 19,
      ),
    );
  }
}
