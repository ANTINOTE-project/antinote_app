import "package:antinote/antinote.dart";
import "package:antinote_app/utils/context.dart";
import "package:flutter/material.dart";

export "context.dart";
export "curves.dart";
export "date.dart";
export "fake_data.dart";
export "formatters.dart";
export "tabs.dart";
export "week_view.dart";

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
