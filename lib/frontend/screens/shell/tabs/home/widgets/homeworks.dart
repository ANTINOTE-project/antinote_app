import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/frontend/screens/shell/widgets/homework.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class HomeworksWidget extends StatelessWidget {
  final TravailAFaire data;

  const HomeworksWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      onShowMorePressed: () {},

      label: context.l10n.homeworks,

      content: ListWidget(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        isSliver: false,
        isColumn: true,

        items: data.homeworks,

        itemBuilder: (context, homework, _) {
          return HomeworkCard(homework: homework, isCompact: true);
        },
      ),
    );
  }
}
