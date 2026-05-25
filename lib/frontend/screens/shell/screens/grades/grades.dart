import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";

typedef ServiceGradeList = Map<Service, List<Exam>>;

class GradesList extends StatefulWidget {
  final VisualId periodId;

  const GradesList({super.key, required this.periodId});

  @override
  State<GradesList> createState() => _GradesListState();
}

class _GradesListState extends State<GradesList> with ScreenMixin<GradesList> {
  late LatestGradesPage _data;

  @override
  void didUpdateWidget(GradesList oldWidget) {
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
    final ServiceGradeList organizedData = {
      for (final service in _data.services!) service: [],
    };

    for (final exam in _data.exams) {
      final service = organizedData.keys.firstWhere(
        (element) => element.id == exam.service.id,
      );
      organizedData[service]!.add(exam);
    }

    final List<Exam> orderedExams = List.from(_data.exams);
    orderedExams.sort((a, b) => a.date.compareTo(b.date));

    return buildRefreshIndicator(
      child: CustomScrollView(
        slivers: [
          _AverageWidget(data: _data),

          _SectionWidget(
            label: context.l10n.latestGrades,
            icon: HugeIconsSolid.note,
          ),
          _LatestWidget(exams: orderedExams),

          _SectionWidget(
            label: context.l10n.services,
            icon: HugeIconsSolid.gitbook,
          ),
          _SubjectsWidget(data: organizedData),

          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: const Center(child: LoadingWidget(size: 30)),
    );
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    final period = session.instance.periods.firstWhere(
      (e) => e.visualId == widget.periodId,
    );
    _data = await session.access(LatestGradesPageAccessor(period: period));
  }
}

class _SectionWidget extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionWidget({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20),

        child: Row(
          spacing: 6,

          children: [
            Icon(icon, size: 22, color: context.c.onSurfaceVariant),

            Text(
              label,

              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: context.c.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AverageWidget extends StatelessWidget {
  final LatestGradesPage data;

  const _AverageWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

    final selfAvg = data.selfGeneralAverage?.value;
    final classAvg = data.classGeneralAverage?.value;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 12, right: 12),

        child: Container(
          decoration: BoxDecoration(
            color: context.c.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),

          padding: const EdgeInsets.all(12),

          child: Column(
            spacing: 8,

            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 12,

                children: [
                  Column(
                    children: [
                      Text(context.l10n.averageSelf, style: style),

                      Text(
                        selfAvg != null ? Utils.formatNumber(selfAvg) : "—",

                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: context.c.primary,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Text(context.l10n.averageClass, style: style),

                      Text(
                        classAvg != null ? Utils.formatNumber(classAvg) : "—",

                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: context.c.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestWidget extends StatelessWidget {
  final List<Exam> exams;

  const _LatestWidget({required this.exams});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,

        child: ListView.builder(
          padding: const EdgeInsets.all(12),

          scrollDirection: .horizontal,
          itemCount: exams.length,

          itemBuilder: (context, index) {
            final exam = exams[index];

            final (color, bgColor) = Utils.adaptColorPair(
              exam.service.color,
              context.c,
            );

            final date = DateFormat("dd/MM/yyyy").format(exam.date);
            final title = Utils.getExamComment(context, exam);
            final subject = exam.service.name;

            return Pressable(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: bgColor,
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(left: 6),

                width: 250,

                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 8,

                  children: [
                    Text(
                      subject,

                      overflow: .ellipsis,
                      maxLines: 1,

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: .bold,
                        color: color,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        title,

                        overflow: .ellipsis,
                        maxLines: 2,

                        style: const TextStyle(fontSize: 16, fontWeight: .w500),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: .spaceBetween,

                      children: [
                        Text(date, style: const TextStyle(fontWeight: .w500)),

                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: Utils.formatNumber(exam.selfGrade.value),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const WidgetSpan(child: SizedBox(width: 2)),

                              TextSpan(
                                text:
                                    "/${Utils.formatNumber(exam.theoreticalMaxGrade.value)}",
                                style: TextStyle(
                                  color: context.c.onSurfaceVariant,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubjectsWidget extends StatelessWidget {
  final ServiceGradeList data;

  const _SubjectsWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        for (final entry in data.entries)
          SliverPadding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 10),

            sliver: SliverMainAxisGroup(
              slivers: [
                PinnedHeaderSliver(child: _ServiceWidget(service: entry.key)),

                ListWidget<Exam>(
                  items: entry.value,
                  itemBuilder: (context, item, borderRadius) {
                    return _ExamWidget(exam: item, borderRadius: borderRadius);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ServiceWidget extends StatelessWidget {
  final Service service;

  const _ServiceWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = Utils.adaptColorPair(service.color, context.c);
    final hasSelfAverage = service.selfAverage != null;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),

      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: bgColor),
          borderRadius: BorderRadius.circular(16),
          color: context.c.surfaceContainerLow,
        ),

        child: Pressable(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            child: Row(
              spacing: 8,

              children: [
                Expanded(
                  child: Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),

                if (hasSelfAverage)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: Utils.formatNumber(service.selfAverage!.value),
                          style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const WidgetSpan(child: SizedBox(width: 2)),

                        TextSpan(
                          text:
                              "/${Utils.formatNumber(service.theoreticalMaxGrade!.value)}",
                          style: TextStyle(
                            color: context.c.onSurfaceVariant,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamWidget extends StatelessWidget {
  final BorderRadius borderRadius;
  final Exam exam;

  const _ExamWidget({required this.exam, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = Utils.adaptColorPair(
      exam.service.color,
      context.c,
    );

    final title = Utils.getExamComment(context, exam);
    final subtitle = exam.date.asRelativeDate(context);

    return ItemWidget(
      borderRadius: borderRadius,
      backgroundColor: bgColor,

      title: Text(title),
      subtitle: Text(subtitle),

      trailing: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: Utils.formatNumber(exam.selfGrade.value),
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const WidgetSpan(child: SizedBox(width: 2)),

            TextSpan(
              text: "/${Utils.formatNumber(exam.theoreticalMaxGrade.value)}",
              style: TextStyle(
                color: context.c.onSurfaceVariant,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
