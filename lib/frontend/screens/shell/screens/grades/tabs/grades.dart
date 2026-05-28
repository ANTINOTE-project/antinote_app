import "dart:async";
import "dart:math" as math;
import "dart:ui";

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

typedef _DetailsItem = ({
  IconData icon,
  String label,
  Grade? grade,
  Grade? theoreticalMaxGrade,
  double? coefficient,
});

Future<void> _showDetails({
  required BuildContext context,
  required String name,
  required int? serviceColor,
  required List<_DetailsItem> items,
  String? title,
  String? subtitle,
}) async {
  await showModalBottomSheet(
    context: context,

    builder: (context) {
      final (color, backgroundColor, _, _, _, subtitleColor) = Utils.adaptColorPair(
        serviceColor,
        context.c,
      );

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        width: double.infinity,

        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,

            children: [
              Column(
                mainAxisAlignment: .center,

                children: [
                  Text(
                    name,

                    textAlign: TextAlign.center,

                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,

                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26),
                  ),

                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),

                      child: Text(
                        title,

                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                      ),
                    ),
                ],
              ),

              Flexible(
                child: ListWidget(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  isSliver: false,

                  items: items,

                  itemBuilder: (context, item, borderRadius) {
                    return ItemWidget(
                      borderRadius: borderRadius,
                      backgroundColor: backgroundColor,

                      leading: Icon(item.icon),

                      title: Text(
                        item.label,
                        style: TextStyle(color: subtitleColor, fontSize: 18, fontWeight: .bold),
                      ),

                      trailing: item.coefficient != null
                          ? Text(
                              "x${Utils.formatNumber(item.coefficient)}",

                              style: TextStyle(
                                color: color,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : item.grade != null && item.theoreticalMaxGrade != null
                          ? _GradeText(
                              selfGrade: item.grade!,
                              maxGrade: item.theoreticalMaxGrade!,
                              color: color,
                              size: 20,
                            )
                          : null,
                    );
                  },
                ),
              ),

              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(color: subtitleColor, fontWeight: .bold),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showExamDetails(BuildContext context, Exam exam) async {
  final items = <_DetailsItem>[
    (
      label: context.l10n.youGot,
      icon: HugeIconsSolid.male02,
      grade: exam.selfGrade,
      theoreticalMaxGrade: exam.theoreticalMaxGrade,
      coefficient: null,
    ),

    if (exam.coefficient != null)
      (
        label: context.l10n.coefficient,
        icon: HugeIconsSolid.calculate,
        coefficient: exam.coefficient,
        theoreticalMaxGrade: null,
        grade: null,
      ),

    if (exam.classAverage != null)
      (
        label: context.l10n.averageClass,
        icon: HugeIconsSolid.chartAverage,
        grade: exam.classAverage,
        theoreticalMaxGrade: exam.theoreticalMaxGrade,
        coefficient: null,
      ),

    if (exam.maxGrade != null)
      (
        label: context.l10n.bestGrade,
        icon: HugeIconsSolid.chartMaximum,
        grade: exam.maxGrade,
        theoreticalMaxGrade: exam.theoreticalMaxGrade,
        coefficient: null,
      ),

    if (exam.minGrade != null)
      (
        label: context.l10n.worstGrade,
        icon: HugeIconsSolid.chartMinimum,
        grade: exam.minGrade,
        theoreticalMaxGrade: exam.theoreticalMaxGrade,
        coefficient: null,
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

Future<void> showServiceDetails(BuildContext context, Service service, List<Exam> exams) async {
  final items = <_DetailsItem>[
    (
      label: context.l10n.averageSelf,
      icon: HugeIconsSolid.male02,
      grade: service.selfAverage,
      theoreticalMaxGrade: service.theoreticalMaxGrade,
      coefficient: null,
    ),

    if (service.classAverage != null)
      (
        label: context.l10n.averageClass,
        icon: HugeIconsSolid.chartAverage,
        grade: service.classAverage,
        theoreticalMaxGrade: service.theoreticalMaxGrade,
        coefficient: null,
      ),

    if (service.maxGrade != null)
      (
        label: context.l10n.bestGrade,
        icon: HugeIconsSolid.chartMaximum,
        grade: service.maxGrade,
        theoreticalMaxGrade: service.theoreticalMaxGrade,
        coefficient: null,
      ),

    if (service.minGrade != null)
      (
        label: context.l10n.worstGrade,
        icon: HugeIconsSolid.chartMinimum,
        grade: service.minGrade,
        theoreticalMaxGrade: service.theoreticalMaxGrade,
        coefficient: null,
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

class _GradesTabState extends State<GradesTab> with ScreenMixin<GradesTab> {
  late LatestGradesPage _data;

  @override
  void didUpdateWidget(GradesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.periodId != widget.periodId) {
      reload();
    }
  }

  @override
  Widget buildLoaded(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    final ServiceGradeList organizedData = {for (final service in _data.services!) service: []};

    final List<Exam> orderedExams = List.from(_data.exams);
    orderedExams.sort((a, b) => b.date.compareTo(a.date));

    for (final exam in orderedExams) {
      final service = organizedData.keys.firstWhere((element) => element.id == exam.service.id);
      organizedData[service]!.add(exam);
    }

    return buildRefreshIndicator(
      child: CustomScrollView(
        slivers: [
          _AverageWidget(data: _data),

          if (orderedExams.isNotEmpty) ...[
            _SectionWidget(label: context.l10n.latestGrades, icon: HugeIconsSolid.note),
            _LatestWidget(exams: orderedExams),
          ],

          if (organizedData.isNotEmpty) ...[
            _SectionWidget(label: context.l10n.services, icon: HugeIconsSolid.gitbook),
            _SubjectsWidget(data: organizedData),
          ],

          SliverPadding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildLoading(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget(size: 30)));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    final period = session.instance.periods.firstWhere((e) => e.visualId == widget.periodId);
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
    const style = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);

    final selfAvg = data.selfGeneralAverage?.value;
    final classAvg = data.classGeneralAverage?.value;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const .only(top: 16, left: 12, right: 12),

        child: Container(
          decoration: BoxDecoration(
            color: context.c.surfaceContainerHigh,
            borderRadius: .circular(20),
          ),

          padding: const .symmetric(vertical: 12),

          child: Column(
            spacing: 8,

            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 12,

                children: [
                  Column(
                    children: [
                      Text(context.l10n.averageSelf, style: style),

                      if (selfAvg != null)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: selfAvg),

                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutExpo,

                          builder: (context, value, _) {
                            return Text(
                              Utils.formatNumber(value),

                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: .w800,
                                color: context.c.primary,
                              ),
                            );
                          },
                        ),
                    ],
                  ),

                  Column(
                    children: [
                      Text(context.l10n.averageClass, style: style),

                      if (classAvg != null)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: classAvg),

                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutExpo,

                          builder: (context, value, _) {
                            return Text(
                              Utils.formatNumber(value),

                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: context.c.secondary,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),

              TweenAnimationBuilder<double>(
                key: ValueKey(data.exams.length),
                tween: Tween(begin: 0.5, end: 1.0),

                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutExpo,

                builder: (context, value, _) {
                  return CustomPaint(
                    size: const Size(double.infinity, 40),

                    painter: _GradesCurvePainter(
                      color: context.c.primary,
                      progress: value,

                      values: data.exams
                          .where((e) => e.selfGrade.type == GradeType.note)
                          .map((e) => e.selfGrade.value)
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradesCurvePainter extends CustomPainter {
  final List<double> values;
  final double progress;
  final Color color;

  const _GradesCurvePainter({required this.values, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final min = values.reduce(math.min);
    final max = values.reduce(math.max);

    final range = (max - min).clamp(1.0, double.infinity);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;

      final yFinal = size.height - ((values[i] - min) / range * size.height);
      final y = lerpDouble(size.height, yFinal, progress)!;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GradesCurvePainter old) => old.values != values || old.progress != progress;
}

class _LatestWidget extends StatelessWidget {
  final List<Exam> exams;

  const _LatestWidget({required this.exams});

  @override
  Widget build(BuildContext context) {
    // rebuild when theme mode changes
    final _ = Theme.of(context);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,

        child: ListView.builder(
          padding: const EdgeInsets.all(12),

          scrollDirection: .horizontal,
          itemCount: exams.length,

          itemBuilder: (context, index) {
            final exam = exams[index];

            final (color, backgroundColor, headerColor, borderColor, _, subtitleColor) =
                Utils.adaptColorPair(exam.service.color, context.c);

            final date = DateFormat("dd/MM/yyyy").format(exam.date);
            final title = Utils.getExamComment(context, exam);
            final subject = exam.service.name;

            return Padding(
              padding: const EdgeInsets.only(right: 8),

              child: Pressable(
                onPressed: () => showExamDetails(context, exam),

                child: IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),

                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        color: backgroundColor,
                      ),

                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,

                        children: [
                          Text(
                            subject,

                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: const .new(750),
                              color: color,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              title,

                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,

                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),

                          Row(
                            children: [
                              Text(
                                date,
                                style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor),
                              ),

                              const Spacer(),

                              _GradeText(
                                selfGrade: exam.selfGrade,
                                maxGrade: exam.theoreticalMaxGrade,
                                color: color,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                PinnedHeaderSliver(
                  child: _ServiceWidget(service: entry.key, exams: entry.value),
                ),

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
  final List<Exam> exams;

  const _ServiceWidget({required this.service, required this.exams});

  @override
  Widget build(BuildContext context) {
    final (color, _, headerColor, borderColor, titleColor, _) = Utils.adaptColorPair(
      service.color,
      context.c,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),

      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
          color: headerColor,
        ),

        child: Pressable(
          onPressed: () => showServiceDetails(context, service, exams),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            child: Row(
              spacing: 8,

              children: [
                Expanded(
                  child: Text(
                    service.name,

                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,

                    style: TextStyle(fontSize: 21, fontWeight: .w800, color: titleColor),
                  ),
                ),

                if (service.selfAverage != null && service.theoreticalMaxGrade != null)
                  _GradeText(
                    selfGrade: service.selfAverage!,
                    maxGrade: service.theoreticalMaxGrade!,
                    isMain: true,
                    color: color,
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
    final (color, backgroundColor, _, _, titleColor, subtitleColor) = Utils.adaptColorPair(
      exam.service.color,
      context.c,
    );

    final title = Utils.getExamComment(context, exam);
    final subtitle = exam.date.asRelativeDate(context);

    return ItemWidget(
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,

      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: Text(subtitle, style: TextStyle(color: subtitleColor)),

      trailing: _GradeText(
        selfGrade: exam.selfGrade,
        maxGrade: exam.theoreticalMaxGrade,
        color: color,
        size: 19,
      ),

      onPressed: () => showExamDetails(context, exam),
    );
  }
}

class _GradeText extends StatelessWidget {
  final Grade selfGrade;
  final Grade maxGrade;

  final Color color;

  final bool isMain;
  final double size;

  const _GradeText({
    required this.selfGrade,
    required this.maxGrade,

    required this.color,

    this.isMain = false,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final showMaxGrade = (maxGrade.value - 20.0).abs() > 0.001;
    String selfValue = Utils.formatNumber(selfGrade.value);

    selfValue = switch (selfGrade.type) {
      .absent => context.l10n.gradeAbsent,
      .notHandedZero => context.l10n.gradeNotHandedZero,
      .exemption => context.l10n.gradeExemption,
      .notGraded => context.l10n.gradeNotGraded,
      .inapt => context.l10n.gradeInapt,
      .notHanded => context.l10n.gradeNotHanded,
      .absentZero => context.l10n.gradeAbsentZero,
      .felicitations => context.l10n.gradeFelicitations,
      _ => selfValue,
    };

    return Text.rich(
      textAlign: .end,

      TextSpan(
        children: [
          TextSpan(
            text: selfValue,

            style: TextStyle(color: color, fontSize: size, fontWeight: isMain ? .w900 : .w800),
          ),

          if (showMaxGrade) ...[
            const WidgetSpan(child: SizedBox(width: 2)),

            TextSpan(
              text: "/${Utils.formatNumber(maxGrade.value, digits: 0)}",

              style: TextStyle(
                color: context.c.onSurfaceVariant,
                fontSize: size * 0.75,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
