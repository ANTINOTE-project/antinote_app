import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class GradesWidget extends StatelessWidget {
  final Notes data;

  const GradesWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      label: context.l10n.grades,

      onShowMorePressed: () {
        context.sc.goToTab(.grades);
      },

      content: const SizedBox.shrink(),
    );
  }
}
