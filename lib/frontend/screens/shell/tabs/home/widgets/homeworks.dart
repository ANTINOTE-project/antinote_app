import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/helpers/various.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/frontend/widgets/compact_card.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/remote_html.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class HomeworksWidget extends StatelessWidget {
  final TravailAFaire data;

  const HomeworksWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final homeworks = List<Homework>.from(data.homeworks);
    homeworks.sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));

    return HomeWidget(
      label: homeworks.length > 5
          ? "${context.l10n.homeworks} (+${homeworks.length - 5})"
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
