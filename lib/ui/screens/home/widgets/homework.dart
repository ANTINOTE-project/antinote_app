import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/ui/screens/home/screen.dart';
import 'package:antinote_app/ui/screens/home/widgets.dart';
import 'package:antinote_app/ui/screens/homeworks/detail.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/compact_card.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/remote_html.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

final class const HomeworkWidgetSliver({
  super.key,
  required final HomePageWidgetState state,
  required final Map<Date, List<Homework>> value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeworks = value.values.fold(
      <Homework>[],
      (value, element) => value..addAll(element),
    );
    homeworks.sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));

    return SliverToBoxAdapter(
      child: HomeWidget(
        icon: const Icon(HugeIconsSolid.work),
        label: Text(
          homeworks.length > 5
              ? '${context.l10n.homeworks} (+${homeworks.length - 5})'
              : context.l10n.homeworks,
        ),

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
            return _HomeworkCard(
              homework: homework,
              update: () async {
                final manager = HomePageScope.of(context).manager;

                await context.ar.runTask(
                  context: context,
                  callback: (session) async {
                    await manager.reloadWidget(session, state, force: true);
                  },
                  debugLabel:
                      'Reload home page after homepage state was updated.',
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;
  final Future<void> Function() update;

  const _HomeworkCard({required this.homework, required this.update});

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);

    return Padding(
      padding: const .symmetric(vertical: 1),

      child: CompactCard(
        scheme: scheme,

        onPressed: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) {
                return HomeworkDetailScreen(
                  homework: homework,
                  onHomeworkChange: (_) async {
                    await update();
                  },
                );
              },
            ),
          );
        },

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
              color: homework.isDone
                  ? scheme.onPrimaryContainer
                  : scheme.outline,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
