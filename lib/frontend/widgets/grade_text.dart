import 'package:antinote/antinote.dart';
import 'package:antinote_app/frontend/utils/utils.dart';
import 'package:flutter/material.dart';

class GradeText extends StatelessWidget {
  final Grade selfGrade;
  final Grade maxGrade;
  final Grade defaultMaxGrade;

  final Color color;

  final bool isMain;
  final double size;

  final TextOverflow overflow;

  const GradeText({
    super.key,

    required this.selfGrade,
    required this.maxGrade,
    required this.defaultMaxGrade,

    required this.color,

    this.isMain = false,
    this.size = 22,

    this.overflow = TextOverflow.visible,
  });

  @override
  Widget build(BuildContext context) {
    final showMaxGrade = maxGrade.value != defaultMaxGrade.value;
    String selfValue = Formatters.formatNumber(selfGrade.value);

    selfValue = switch (selfGrade.type) {
      .absent => context.l10n.gradeAbsent,
      .notHandedZero => context.l10n.gradeNotHandedZero,
      .exemption => context.l10n.gradeExemption,
      .notGraded => context.l10n.gradeNotGraded,
      .inapt => context.l10n.gradeInapt,
      .notHanded => context.l10n.gradeNotHanded,
      .absentZero => context.l10n.gradeAbsentZero,
      .felicitations => context.l10n.gradeFelicitations,
      _ => selfValue,
    };

    return Text.rich(
      textAlign: .end,
      overflow: overflow,

      TextSpan(
        children: [
          TextSpan(
            text: selfValue,

            style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: isMain ? .w900 : .w800,
            ),
          ),

          if (showMaxGrade) ...[
            const WidgetSpan(child: SizedBox(width: 2)),

            TextSpan(
              text: '/${Formatters.formatNumber(maxGrade.value, digits: 0)}',

              style: TextStyle(
                color: context.c.onSurfaceVariant,
                fontSize: size * 0.75,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
