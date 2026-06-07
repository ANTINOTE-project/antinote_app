import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";

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
