import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/frontend/widgets/bottom_padding.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/grade_text.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils/utils.dart";
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

      return buildRefreshIndicator(
        child: CustomScrollView(
          slivers: [
            _Averages(report: report),
            _Categories(report: report),
            _Attendance(report: report),
            _GeneralAppreciations(report: report),

            const BottomPadding(padding: 10),
          ],
        ),
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
          style: TextStyle(color: context.c.outline, fontWeight: .bold),
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

class _SectionText extends StatelessWidget {
  final String label;
  final bool hasPadding;

  const _SectionText({required this.label, this.hasPadding = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: hasPadding ? const .only(left: 4, bottom: 12, top: 8) : .zero,

      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
      ),
    );
  }
}

class _Averages extends StatelessWidget {
  final PublishedReport report;

  const _Averages({required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.studentAverage == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const .symmetric(vertical: 16, horizontal: 12),

        child: Container(
          decoration: BoxDecoration(
            color: context.c.surfaceContainerHigh,
            border: .all(color: context.c.outlineVariant),
            borderRadius: .circular(20),
          ),

          padding: const .symmetric(vertical: 12),

          child: Row(
            mainAxisAlignment: .spaceEvenly,
            spacing: 12,

            children: [
              _AverageText(
                average: report.studentAverage!.value,
                color: context.c.primary,
                label: context.l10n.averageSelf,
              ),

              _AverageText(
                average: report.classAverage.value,
                color: context.c.secondary,
                label: context.l10n.averageClass,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AverageText extends StatelessWidget {
  final double? average;
  final Color color;
  final String label;

  const _AverageText({
    required this.average,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 17, fontWeight: .w700)),

        Text(
          Formatters.formatNumber(average),
          style: TextStyle(fontSize: 27, fontWeight: .w800, color: color),
        ),
      ],
    );
  }
}

class _Categories extends StatelessWidget {
  final PublishedReport report;

  const _Categories({required this.report});

  @override
  Widget build(BuildContext context) {
    final uncategorized = report.services
        .where((e) => e.category == null)
        .toList(growable: false);

    return SliverMainAxisGroup(
      slivers: [
        ...report.serviceCategories.map((category) {
          final services = report.services
              .where((e) => e.category?.id == category.id)
              .toList(growable: false);

          if (services.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const .only(left: 16, right: 12, bottom: 8, top: 12),

                  child: Column(
                    crossAxisAlignment: .start,

                    children: [
                      _SectionText(label: category.name, hasPadding: false),
                      _CategoryAverageRow(category: category),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const .symmetric(horizontal: 12),

                sliver: ListWidget(
                  items: services,

                  itemBuilder: (context, service, borderRadius) {
                    return _ServiceWidget(
                      borderRadius: borderRadius,
                      service: service,
                      report: report,
                    );
                  },
                ),
              ),
            ],
          );
        }),

        if (uncategorized.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const .only(left: 12),
              child: _SectionText(label: context.l10n.reportOtherSubjects),
            ),
          ),

          SliverPadding(
            padding: const .symmetric(horizontal: 12),

            sliver: ListWidget(
              items: uncategorized,

              itemBuilder: (context, service, borderRadius) {
                return _ServiceWidget(
                  borderRadius: borderRadius,
                  service: service,
                  report: report,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryAverageRow extends StatelessWidget {
  final ServiceCategory category;

  const _CategoryAverageRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,

      children: [
        _MiniAverage(
          label: context.l10n.averageClass,
          grade: category.classAverage,
          gradeColor: context.c.secondary,
          textColor: context.c.outline,
        ),

        _MiniAverage(
          label: context.l10n.gradeMin,
          grade: category.lowestAverage,
          gradeColor: context.c.error,
          textColor: context.c.outline,
        ),

        _MiniAverage(
          label: context.l10n.gradeMax,
          grade: category.highestAverage,
          gradeColor: context.c.tertiary,
          textColor: context.c.outline,
        ),
      ],
    );
  }
}

class _MiniAverage extends StatelessWidget {
  final String label;
  final Grade grade;
  final Color gradeColor;
  final Color textColor;

  const _MiniAverage({
    required this.label,
    required this.grade,
    required this.gradeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,

      children: [
        Text(
          label,

          style: TextStyle(color: textColor, fontWeight: .bold, fontSize: 14),
        ),

        GradeText(
          selfGrade: grade,
          maxGrade: .decodeDouble(20),
          color: gradeColor,
          size: 15,
        ),
      ],
    );
  }
}

class _ServiceWidget extends StatelessWidget {
  final ReportService service;
  final PublishedReport report;
  final BorderRadius borderRadius;

  const _ServiceWidget({
    required this.service,
    required this.report,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final hasAppreciations = service.appreciations.isNotEmpty;
    final appreciations = hasAppreciations
        ? service.appreciations
              .where((element) => element.name?.trim().isNotEmpty == true)
              .toList(growable: false)
        : <ReportAppreciation>[];

    final hasCoeff = service.coefficient != null;
    final hasTeachers = service.teachers?.isNotEmpty == true;

    final hasStats =
        service.classAverage != null ||
        service.lowestAverage != null ||
        service.highestAverage != null;

    final scheme = Utils.buildColorScheme(context, service.color);

    return Pressable(
      borderRadius: borderRadius,

      child: Ink(
        decoration: BoxDecoration(
          border: .all(color: scheme.inversePrimary),
          color: scheme.primaryContainer,
          borderRadius: borderRadius,
        ),

        padding: const .symmetric(horizontal: 12, vertical: 10),

        child: Column(
          crossAxisAlignment: .start,
          spacing: 10,

          children: [
            // Service name + grade
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.name,

                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: .w800,
                      fontSize: 21,
                    ),
                  ),
                ),

                if (service.studentAverage != null)
                  GradeText(
                    selfGrade: service.studentAverage!,
                    maxGrade: Grade.decodeDouble(20),
                    color: scheme.primary,
                    size: 20,
                  ),
              ],
            ),

            // Teachers + coefficient
            Column(
              crossAxisAlignment: .start,

              children: [
                if (hasTeachers)
                  Text(
                    service.teachers!.map((t) => t.name).join(", "),

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: TextStyle(
                      color: scheme.outline,
                      fontWeight: .bold,
                      fontSize: 13,
                    ),
                  ),

                if (hasCoeff)
                  Text(
                    context.l10n.reportCoefficient(
                      Formatters.formatNumber(service.coefficient!.value),
                    ),

                    style: TextStyle(
                      color: scheme.outline,
                      fontWeight: .bold,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),

            if (hasStats)
              Row(
                spacing: 10,

                children: [
                  if (service.classAverage != null)
                    _MiniAverage(
                      label: context.l10n.averageClass,
                      grade: service.classAverage!,
                      gradeColor: scheme.secondary,
                      textColor: scheme.outline,
                    ),

                  if (service.lowestAverage != null)
                    _MiniAverage(
                      label: context.l10n.gradeMin,
                      grade: service.lowestAverage!,
                      gradeColor: scheme.error,
                      textColor: scheme.outline,
                    ),

                  if (service.highestAverage != null)
                    _MiniAverage(
                      label: context.l10n.gradeMax,
                      grade: service.highestAverage!,
                      gradeColor: scheme.tertiary,
                      textColor: scheme.outline,
                    ),
                ],
              ),

            if (hasAppreciations)
              ListWidget(
                items: appreciations,
                isSliver: false,
                isColumn: true,

                itemBuilder: (context, a, borderRadius) {
                  final trimmed = a.name?.trim() ?? "";

                  return ItemWidget(
                    backgroundColor: scheme.surfaceContainer,
                    borderRadius: borderRadius,

                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: trimmed));
                    },

                    title: Text(
                      trimmed,

                      maxLines: 999,

                      style: TextStyle(
                        color: context.c.onSurface,
                        fontStyle: .italic,
                        fontWeight: .bold,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Attendance extends StatelessWidget {
  final PublishedReport report;

  const _Attendance({required this.report});

  @override
  Widget build(BuildContext context) {
    final items = [
      report.tardnessString,
      report.absenceString,

      if (report.punitionsString.isNotEmpty) report.punitionsString,
      if (report.sanctionsString.isNotEmpty) report.sanctionsString,
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 6),

        child: Column(
          crossAxisAlignment: .start,

          children: [
            _SectionText(label: context.l10n.homeAttendance),

            ListWidget(
              isSliver: false,
              isColumn: true,
              items: items,

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

class _GeneralAppreciations extends StatelessWidget {
  final PublishedReport report;

  const _GeneralAppreciations({required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.appreciations.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 6),

        child: Column(
          crossAxisAlignment: .start,

          children: [
            _SectionText(label: context.l10n.reportComment),

            ListWidget(
              items: report.appreciations,
              isSliver: false,
              isColumn: true,

              itemBuilder: (context, a, borderRadius) {
                final name = a.name?.trim();
                final title = a.title?.trim();

                final hasName = name != null && name.isNotEmpty;
                final hasTitle = title != null && title.isNotEmpty;

                return ItemWidget(
                  borderRadius: borderRadius,

                  onPressed: () {
                    if (hasName) {
                      Clipboard.setData(ClipboardData(text: name));
                    }
                  },

                  title: hasTitle
                      ? Text(
                          title,
                          maxLines: 999,
                          style: TextStyle(
                            color: context.c.primary,
                            fontWeight: .w800,
                            fontSize: 18,
                          ),
                        )
                      : null,

                  subtitle: hasName
                      ? Text(
                          name,
                          maxLines: 999,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.c.onSurface,
                          ),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
