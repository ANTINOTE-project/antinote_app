import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/frontend/widgets/remote_html.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class HomeworksBody extends StatelessWidget {
  final List<Homework> homeworks;

  const HomeworksBody({super.key, required this.homeworks});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: homeworks.length,

      itemBuilder: (context, index) {
        final homework = homeworks[index];

        final colors = AdaptedColors.fromScheme(
          homework.backgroundColor,
          context.c,
        );

        final title = RemoteHtml(rawHtml: homework.description);

        return Padding(
          padding: const .only(bottom: 8, left: 12, right: 12),

          child: Pressable(
            child: Ink(
              decoration: BoxDecoration(
                border: .all(color: colors.border),
                borderRadius: .circular(20),
                color: colors.background,
              ),

              padding: const .symmetric(horizontal: 12, vertical: 8),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 6,

                      children: [
                        Text(
                          homework.subject.name ?? "",

                          style: TextStyle(
                            color: colors.base,
                            fontWeight: .w800,
                            fontSize: 21,
                          ),
                        ),

                        DefaultTextStyle(
                          style: const TextStyle(fontWeight: .bold),
                          child: title,
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Text(
                        homework.isDone
                            ? context.l10n.homeworkDone
                            : context.l10n.homeworkNotDone,

                        style: TextStyle(
                          fontWeight: .w600,
                          color: context.c.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
