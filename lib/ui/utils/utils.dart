import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:flutter/material.dart';

export 'src/class.dart';
export 'src/context.dart';
export 'src/curves.dart';
export 'src/date.dart';
export 'src/fake_data.dart';
export 'src/formatters.dart';
export 'src/tabs.dart';
export 'src/week_view.dart';

class Utils {
  Utils._();

  static String getExamComment(BuildContext context, Exam exam) {
    final isNotEmpty = exam.comment?.trim().isNotEmpty ?? false;
    if (isNotEmpty) return exam.comment!.trim();
    return context.l10n.gradeOf(exam.service.name);
  }

  static ColorScheme buildColorScheme(BuildContext context, int? color) {
    if (color == null) return context.c;

    return ColorScheme.fromSeed(
      seedColor: Color(color),
      brightness: context.c.brightness,
    );
  }
}
