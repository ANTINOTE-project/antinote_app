import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/grade_text.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'modal.dart';

typedef _ServiceGradeList = Map<Service, List<Exam>>;

typedef _DetailsItem = ({
  IconData icon,
  String label,
  Grade? grade,
  Grade? theoreticalMaxGrade,
  Grade? defaultMaxGrade,
  double? coefficient,
  String? rawValue,
});

Future<void> showExamDetails(BuildContext context, Exam exam) async {
  final items = <_DetailsItem>[
    (
      label: context.l10n.youGot,
      icon: HugeIconsSolid.male02,
      grade: exam.selfGrade,
      theoreticalMaxGrade: exam.theoreticalMaxGrade,
      defaultMaxGrade: exam.defaultMaxGrade,
      coefficient: null,
      rawValue: null,
    ),

    if (exam.coefficient != null)
      (
        label: context.l10n.coefficient,
        icon: HugeIconsSolid.calculate,
        coefficient: exam.coefficient,
        theoreticalMaxGrade: null,
        defaultMaxGrade: null,
        grade: null,
        rawValue: null,
      ),

    if (exam.classAverage != null)
      (
        label: context.l10n.averageClass,
        icon: HugeIconsSolid.chartAverage,
        grade: exam.classAverage,
        theoreticalMaxGrade: exam.theoreticalMaxGrade,
        defaultMaxGrade: exam.defaultMaxGrade,
        coefficient: null,
        rawValue: null,
      ),

    if (exam.maxGrade != null)
      (
        label: context.l10n.bestGrade,
        icon: HugeIconsSolid.plusSign,
        grade: exam.maxGrade,
        theoreticalMaxGrade: exam.theoreticalMaxGrade,
        defaultMaxGrade: exam.defaultMaxGrade,
        coefficient: null,
        rawValue: null,
      ),

    if (exam.minGrade != null)
      (
        label: context.l10n.worstGrade,
        icon: HugeIconsSolid.minusSign,
        grade: exam.minGrade,
        theoreticalMaxGrade: exam.theoreticalMaxGrade,
        defaultMaxGrade: exam.defaultMaxGrade,
        coefficient: null,
        rawValue: null,
      ),
  ];

  await _showDetails(
    context: context,
    name: exam.service.name,
    serviceColor: exam.service.color,
    items: items,
    title: Utils.getExamComment(context, exam),
    subtitle: exam.date.asRelativeDate(context),
  );
}

Future<void> showServiceDetails(
  BuildContext context,
  Service service,
  List<Exam> exams,
) async {
  final items = <_DetailsItem>[
    (
      label: context.l10n.gradeCount,
      icon: HugeIconsSolid.textNumberSign,
      grade: null,
      theoreticalMaxGrade: null,
      defaultMaxGrade: null,
      coefficient: null,
      rawValue: exams.length.toString(),
    ),
    (
      label: context.l10n.selfServiceAverage,
      icon: HugeIconsSolid.male02,
      grade: service.selfAverage,
      theoreticalMaxGrade: service.theoreticalMaxGrade,
      defaultMaxGrade: service.defaultTheoreticalMaxGrade,
      coefficient: null,
      rawValue: null,
    ),

    if (service.classAverage != null)
      (
        label: context.l10n.averageClass,
        icon: HugeIconsSolid.chartAverage,
        grade: service.classAverage,
        theoreticalMaxGrade: service.theoreticalMaxGrade,
        defaultMaxGrade: service.defaultTheoreticalMaxGrade,
        coefficient: null,
        rawValue: null,
      ),

    if (service.maxGrade != null)
      (
        label: context.l10n.bestGrade,
        icon: HugeIconsSolid.crown03,
        grade: service.maxGrade,
        theoreticalMaxGrade: service.theoreticalMaxGrade,
        defaultMaxGrade: service.defaultTheoreticalMaxGrade,
        coefficient: null,
        rawValue: null,
      ),

    if (service.minGrade != null)
      (
        label: context.l10n.worstGrade,
        icon: HugeIconsStroke.crying,
        grade: service.minGrade,
        theoreticalMaxGrade: service.theoreticalMaxGrade,
        defaultMaxGrade: service.defaultTheoreticalMaxGrade,
        coefficient: null,
        rawValue: null,
      ),
  ];

  await _showDetails(
    context: context,
    name: service.name,
    serviceColor: service.color,
    items: items,
  );
}

class GradesTab extends StatefulWidget {
  final VisualId periodId;

  const GradesTab({super.key, required this.periodId});

  @override
  State<GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<GradesTab>
    with PageMixin<GradesTab>, TabMixin<GradesTab> {
  late LatestGradesPage _data;

  @override
  void didUpdateWidget(GradesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.periodId != widget.periodId) {
      reload();
    }
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    final _ServiceGradeList organizedData = {
      for (final service in _data.services!) service: [],
    };

    final List<Exam> orderedExams = List.from(_data.exams);
    orderedExams.sort((a, b) => b.date.compareTo(a.date));

    for (final exam in orderedExams) {
      final service = organizedData.keys.firstWhere(
        (element) => element.id == exam.service.id,
      );
      organizedData[service]!.add(exam);
    }

    return buildRefreshIndicator(
      child: CustomScrollView(
        slivers: [
          _Averages(data: _data),

          if (orderedExams.isNotEmpty) ...[
            _SectionWidget(
              label: context.l10n.latestGrades,
              icon: HugeIconsSolid.note,
            ),

            _LatestGrades(exams: orderedExams),
          ],

          if (organizedData.isNotEmpty) ...[
            _SectionWidget(
              label: context.l10n.services,
              icon: HugeIconsSolid.gitbook,
            ),

            _ServicesGrades(data: organizedData),
          ],

          const BottomPadding(padding: 10),
        ],
      ),
    );
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    double? progress,
  ) {
    return buildRefreshIndicator(
      child: CustomScrollView(
        slivers: [
          const _Averages(data: null),

          _SectionWidget(
            label: context.l10n.latestGrades,
            icon: HugeIconsSolid.note,
          ),

          const _LatestGrades(exams: null),

          _SectionWidget(
            label: context.l10n.services,
            icon: HugeIconsSolid.gitbook,
          ),

          const _ServicesGrades(data: null),
        ],
      ),
    );
  }

  @override
  Future<void> load(RemoteSession session) async {
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

class _Averages extends StatelessWidget {
  final LatestGradesPage? data;

  const _Averages({required this.data});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);

    final selfAvg = data?.selfGeneralAverage?.value;
    final classAvg = data?.classGeneralAverage?.value;

    return SliverToBoxAdapter(
      child: Skeletonizer.zone(
        enabled: data == null,

        child: Padding(
          padding: const .only(top: 16, left: 12, right: 12, bottom: 8),

          child: Container(
            decoration: BoxDecoration(
              color: context.c.surfaceContainerHigh,
              border: .all(color: context.c.outlineVariant),
              borderRadius: .circular(20),
            ),

            padding: const .symmetric(vertical: 12),

            child: Column(
              spacing: 16,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 12,

                  children: [
                    _AverageText(
                      average: selfAvg,
                      style: style,
                      color: context.c.primary,
                      isLoading: data == null,
                      label: context.l10n.averageSelf,
                    ),

                    _AverageText(
                      average: classAvg,
                      style: style,
                      color: context.c.secondary,
                      isLoading: data == null,
                      label: context.l10n.averageClass,
                    ),
                  ],
                ),

                Column(
                  spacing: 12,

                  children: data == null
                      ? [
                          const SizedBox(height: 58),
                          const Bone.text(width: 200, style: style),
                        ]
                      : [
                          TweenAnimationBuilder<double>(
                            key: ValueKey(data!.exams.length),
                            tween: Tween(begin: 0.5, end: 1.0),

                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutExpo,

                            builder: (context, value, _) {
                              return SizedBox(
                                height: 40,

                                child: ClipRect(
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 40),

                                    painter: _GradesCurvePainter(
                                      color: context.c.tertiary,
                                      progress: value,

                                      values: data!.exams
                                          .where(
                                            (e) =>
                                                e.selfGrade.type ==
                                                GradeType.note,
                                          )
                                          .map((e) => e.selfGrade.value)
                                          .toList()
                                          .reversed
                                          .toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          Text(context.l10n.gradesHistory, style: style),
                        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AverageText extends StatelessWidget {
  final double? average;
  final TextStyle style;
  final Color color;
  final bool isLoading;
  final String label;

  const _AverageText({
    required this.average,
    required this.style,
    required this.color,
    required this.isLoading,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: isLoading
          ? [
              Bone.text(width: 125, style: style),

              const SizedBox(height: 8),

              Bone.text(
                width: 75,
                style: TextStyle(fontSize: 27, fontWeight: .w800, color: color),
              ),
            ]
          : average != null
          ? [
              Text(label, style: style),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: average),

                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutExpo,

                builder: (context, value, _) {
                  return Text(
                    Formatters.formatNumber(value),

                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: .w800,
                      color: color,
                    ),
                  );
                },
              ),
            ]
          : [],
    );
  }
}

class _GradesCurvePainter extends CustomPainter {
  final List<double> values;
  final double progress;
  final Color color;

  const _GradesCurvePainter({
    required this.values,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final min = values.reduce(math.min);
    final max = values.reduce(math.max);

    final range = (max - min).clamp(1.0, double.infinity);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final List<Offset> offsets = [];

    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;

      final yFinal = size.height - ((values[i] - min) / range * size.height);
      final y = lerpDouble(size.height, yFinal, progress)!;

      offsets.add(Offset(x, y));
    }

    for (var i = 0; i < offsets.length; i++) {
      final offset = offsets[i];

      // first
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);

        // last
      } else if (i == values.length - 1) {
        path.lineTo(offset.dx, offset.dy);

        // normal
      } else {
        final nextOffset = offsets[i + 1];
        final center = (offset + nextOffset) / 2;

        path.quadraticBezierTo(offset.dx, offset.dy, center.dx, center.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GradesCurvePainter old) =>
      old.values != values || old.progress != progress;
}

class _LatestGrades extends StatelessWidget {
  final List<Exam>? exams;

  const _LatestGrades({required this.exams});

  @override
  Widget build(BuildContext context) {
    // rebuild when theme mode changes TODO: Get rid of that
    final _ = Theme.of(context);
    final totalWidth = MediaQuery.sizeOf(context).width;
    final maxItemWidth = totalWidth / 10 * 6;

    return SliverToBoxAdapter(
      child: Container(
        height: 170,
        padding: const .symmetric(horizontal: 8, vertical: 8),
        child: CarouselView.weightedBuilder(
          flexWeights: const [6, 3, 1],
          itemSnapping: true,
          infinite: exams == null,
          itemBuilder: (context, index) {
            final exam = exams == null
                ? fakeExams[index % fakeExams.length]
                : exams![index];

            return Padding(
              padding: const .symmetric(horizontal: 4),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(borderRadius: .circular(28)),
                ),
                child: GradeCard(
                  exam: exam,
                  isLoading: exams == null,
                  width: maxItemWidth,
                ),
              ),
            );
          },
          itemCount: exams?.length ?? fakeExams.length,
        ),
      ),
    );
  }
}

class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.exam,
    required this.isLoading,
    required this.width,
  });

  final Exam exam;
  final bool isLoading;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, exam.service.color);

    final date = DateFormat('dd/MM/yyyy').format(exam.date);
    final title = Utils.getExamComment(context, exam);
    final subject = exam.service.name;

    return Skeletonizer(
      enabled: isLoading,
      child: Pressable(
        onPressed: () async => await showExamDetails(context, exam),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.inversePrimary),
            color: scheme.primaryContainer,
          ),

          child: OverflowBox(
            minWidth: width,
            maxWidth: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      Text(
                        subject,

                        overflow: .ellipsis,
                        maxLines: 1,

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: .w800,
                          color: scheme.primary,
                        ),
                      ),

                      Text(
                        title,

                        overflow: .ellipsis,
                        maxLines: 2,

                        style: const TextStyle(fontSize: 16, fontWeight: .w600),
                      ),
                    ],
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        Divider(
                          color: scheme.inversePrimary,
                          radius: .circular(999),
                          thickness: 3,
                        ),

                        Row(
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),

                            const Spacer(),

                            GradeText(
                              selfGrade: exam.selfGrade,
                              maxGrade: exam.theoreticalMaxGrade,
                              defaultMaxGrade: exam.defaultMaxGrade,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServicesGrades extends StatelessWidget {
  final _ServiceGradeList? data;

  const _ServicesGrades({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = (data ?? fakeServiceGradeList).entries.sorted(
      (a, b) => a.key.name.compareTo(b.key.name),
    );

    return SliverMainAxisGroup(
      slivers: [
        for (final entry in entries)
          SliverPadding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 10),

            sliver: SliverMainAxisGroup(
              slivers: [
                PinnedHeaderSliver(
                  child: _ServiceWidget(
                    service: entry.key,
                    exams: entry.value,
                    isLoading: data == null,
                  ),
                ),

                ListWidget<Exam>(
                  isLoading: data == null,
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
  final List<Exam> exams;
  final bool isLoading;

  const _ServiceWidget({
    required this.service,
    required this.exams,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, service.color);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),

      child: Skeletonizer.zone(
        enabled: isLoading,

        child: Pressable(
          onPressed: () => showServiceDetails(context, service, exams),
          borderRadius: BorderRadius.circular(16),

          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(
                color: isLoading
                    ? context.c.outlineVariant
                    : scheme.inversePrimary,
              ),

              borderRadius: BorderRadius.circular(16),
              color: scheme.primaryContainer,
            ),

            padding: .symmetric(horizontal: 12, vertical: isLoading ? 15 : 10),

            child: Row(
              spacing: 8,

              children: isLoading
                  ? [
                      const Bone.text(width: 200, fontSize: 21),

                      const Spacer(),

                      const Bone.text(width: 60, fontSize: 23),
                    ]
                  : [
                      Expanded(
                        child: Text(
                          service.name,

                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,

                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: .w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),

                      if (service.selfAverage != null &&
                          service.theoreticalMaxGrade != null)
                        GradeText(
                          selfGrade: service.selfAverage!,
                          maxGrade: service.theoreticalMaxGrade!,
                          defaultMaxGrade: service.defaultTheoreticalMaxGrade!,
                          isMain: true,
                          color: scheme.primary,
                          size: 23,
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
    final scheme = Utils.buildColorScheme(context, exam.service.color);

    final title = Utils.getExamComment(context, exam);
    final subtitle = exam.date.asRelativeDate(context);

    return ItemWidget(
      backgroundColor: scheme.secondaryContainer,
      borderRadius: borderRadius,

      title: Text(title, style: TextStyle(color: scheme.onSecondaryContainer)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: .bold),
      ),

      trailing: GradeText(
        selfGrade: exam.selfGrade,
        maxGrade: exam.theoreticalMaxGrade,
        defaultMaxGrade: exam.defaultMaxGrade,
        color: scheme.primary,
        size: 19,
      ),

      onPressed: () => showExamDetails(context, exam),
    );
  }
}
