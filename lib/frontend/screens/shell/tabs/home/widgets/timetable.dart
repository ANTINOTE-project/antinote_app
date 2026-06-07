import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class TimetableWidget extends StatelessWidget {
  final EDT data;

  const TimetableWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      label: context.l10n.timetable,

      onShowMorePressed: () {
        context.sc.goToTab(.timetable);
      },

      content: const SizedBox.shrink(),
    );
  }
}
