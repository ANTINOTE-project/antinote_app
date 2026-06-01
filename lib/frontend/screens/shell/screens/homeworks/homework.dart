import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class HomeworkScreen extends StatelessWidget {
  final Homework homework;

  const HomeworkScreen({super.key, required this.homework});

  @override
  Widget build(BuildContext context) {
    final colors = AdaptedColors.fromScheme(
      homework.backgroundColor,
      context.c,
    );

    final date = DateFormat("dd/MM/yyyy").format(homework.deadlineDate);

    return const Scaffold(appBar: AppBarWidget(title: ""));
  }
}
