import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/helpers/various.dart";
import "package:antinote_app/frontend/screens/shell/tabs/homeworks/homework.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/frontend/widgets/remote_html.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class HomeworkCard extends StatelessWidget {
  final Homework homework;

  final VoidCallback? onReturn;
  final bool isCompact;

  const HomeworkCard({
    super.key,

    required this.homework,

    this.isCompact = false,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, homework.backgroundColor);
    final dateStr = homework.deadlineDate.asRelativeWeekday(context);

    return Pressable(
      borderRadius: .circular(16),
      hasFeedback: !isCompact,

      onPressed: () async {
        if (isCompact) return;

        await Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) {
              return HomeworkScreen(
                homework: homework,
                onHomeworkChange: (_) => onReturn?.call(),
              );
            },
          ),
        );
      },

      child: Ink(
        decoration: BoxDecoration(
          border: .all(color: scheme.inversePrimary),
          borderRadius: .circular(16),
          color: scheme.primaryContainer,
        ),

        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 6 : 8,
          horizontal: 12,
        ),

        child: Column(
          crossAxisAlignment: .start,
          spacing: isCompact ? 2 : 6,

          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              spacing: 10,

              children: [
                Expanded(
                  child: Text(
                    homework.subject.name ?? context.l10n.noSubject,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: .w800,
                      fontSize: isCompact ? 16 : 21,
                    ),
                  ),
                ),

                Text(
                  dateStr,
                  style: TextStyle(fontWeight: .bold, color: scheme.outline),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: RemoteHtml(
                    rawHtml: homework.description,
                    maxLines: isCompact ? 1 : 3,
                    compact: true,

                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: .w600,
                      fontSize: 15,
                    ),
                  ),
                ),

                if (isCompact) ...[
                  const SizedBox(width: 6),

                  Icon(
                    homework.isDone
                        ? HugeIconsSolid.tick03
                        : HugeIconsStroke.tick03,
                    color: homework.isDone
                        ? scheme.onPrimaryContainer
                        : scheme.outline,
                    size: 21,
                  ),
                ],
              ],
            ),

            if (!isCompact) ...[
              const SizedBox(height: 6),

              Row(
                spacing: 6,

                children: [
                  Icon(
                    homework.isDone
                        ? HugeIconsSolid.tick03
                        : HugeIconsStroke.tick03,
                    color: homework.isDone
                        ? scheme.onPrimaryContainer
                        : scheme.outline,
                    size: 21,
                  ),

                  Text(
                    homework.isDone
                        ? context.l10n.homeworkSetDone
                        : context.l10n.homeworkSetNotDone,

                    style: TextStyle(
                      color: homework.isDone
                          ? scheme.onPrimaryContainer
                          : scheme.outline,
                      fontWeight: .w800,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
