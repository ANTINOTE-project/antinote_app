import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/frontend/widgets/bottom_padding.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/utils/context.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hugeicons_pro/hugeicons.dart";

class ReportTab extends StatefulWidget {
  final VisualId periodId;

  const ReportTab({super.key, required this.periodId});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> with TabMixin<ReportTab> {
  late BaseReport _data;

  @override
  void didUpdateWidget(ReportTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.periodId != widget.periodId) {
      reload();
    }
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    if (_data is PublishedReport) {
      final report = _data as PublishedReport;

      return CustomScrollView(
        slivers: [
          _Comment(report: report),
          const BottomPadding(),
        ],
      );
    }

    return Column(
      mainAxisAlignment: .center,
      spacing: 4,

      children: [
        Icon(
          HugeIconsSolid.schoolReportCard,
          color: context.c.outline,
          size: 44,
        ),

        Text(
          context.l10n.reportUnpublished,
          style: TextStyle(fontWeight: .bold, color: context.c.outline),
        ),
      ],
    );
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    final period = session.instance.periods.firstWhere(
      (e) => e.visualId == widget.periodId,
    );

    _data = await session.access(ReportAccessor(period: period));
  }
}

class _Comment extends StatelessWidget {
  final PublishedReport report;

  const _Comment({required this.report});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 6),

        child: Column(
          crossAxisAlignment: .start,

          children: [
            Padding(
              padding: const .symmetric(vertical: 16),

              child: Text(
                context.l10n.reportComment,
                style: const TextStyle(fontWeight: .w800, fontSize: 24),
              ),
            ),

            ListWidget(
              items: report.appreciations,
              isSliver: false,
              isColumn: true,

              itemBuilder: (context, a, borderRadius) {
                return ItemWidget(
                  borderRadius: borderRadius,

                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: a.name!));
                  },

                  title: Text(
                    a.title!,

                    maxLines: 999,

                    style: TextStyle(
                      color: context.c.primary,
                      fontWeight: .w800,
                      fontSize: 19,
                    ),
                  ),

                  subtitle: Text(
                    a.name!,
                    maxLines: 999,
                    style: TextStyle(fontSize: 15, color: context.c.onSurface),
                  ),
                );
              },
            ),

            Padding(
              padding: const .symmetric(vertical: 16),

              child: Text(
                context.l10n.homeAttendance,
                style: const TextStyle(fontWeight: .w800, fontSize: 24),
              ),
            ),

            ListWidget(
              isSliver: false,
              isColumn: true,

              items: [
                report.tardnessString,
                report.absenceString,

                if (report.punitionsString.isNotEmpty) report.punitionsString,
                if (report.sanctionsString.isNotEmpty) report.sanctionsString,
              ],

              itemBuilder: (context, item, borderRadius) {
                return ItemWidget(
                  borderRadius: borderRadius,
                  title: Text(item, maxLines: 999),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
