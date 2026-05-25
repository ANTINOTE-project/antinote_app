import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

List<(DateTime, double, double?)> _buildEvolution(List<Exam> exams) {
  final sorted = [...exams]..sort((a, b) => a.date.compareTo(b.date));
  final points = <(DateTime, double, double?)>[];

  double selfSum = 0;
  double classSum = 0;
  int classCount = 0;

  for (int i = 0; i < sorted.length; i++) {
    final exam = sorted[i];
    selfSum += exam.selfGrade.value / exam.theoreticalMaxGrade.value * 20;

    final avg = (selfSum / (i + 1));
    double? classAvg;

    if (exam.classAverage != null) {
      classSum +=
          exam.classAverage!.value / exam.theoreticalMaxGrade.value * 20;
      classCount++;
      classAvg = classSum / classCount;
    }

    points.add((exam.date, avg, classAvg));
  }

  return points;
}

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
    final organizedData = <Service, List<Exam>>{
      for (final service in _data.services!) service: [],
    };

    for (final exam in _data.exams) {
      final service = organizedData.keys.firstWhere(
        (element) => element.id == exam.service.id,
      );

      organizedData[service]!.add(exam);
    }

    return buildRefreshIndicator(
      child: CustomScrollView(
        slivers: [
          _AverageWidget(data: _data),

          for (final MapEntry(key: service, value: exams)
              in organizedData.entries)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),

              sliver: SliverMainAxisGroup(
                slivers: [
                  PinnedHeaderSliver(child: ServiceWidget(service: service)),

                  SliverList.builder(
                    itemCount: exams.length,

                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),

                        child: _ExamWidget(
                          exam: exams[index],

                          isFirst: index == 0,
                          isLast: index == exams.length - 1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
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

class _AverageWidget extends StatefulWidget {
  final LatestGradesPage data;

  const _AverageWidget({required this.data});

  @override
  State<_AverageWidget> createState() => _AverageWidgetState();
}

class _AverageWidgetState extends State<_AverageWidget> {
  late List<(DateTime, double, double?)> _points;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _points = _buildEvolution(widget.data.exams);
  }

  @override
  void didUpdateWidget(_AverageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      _points = _buildEvolution(widget.data.exams);
      _selectedIndex = 0;
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double width) {
    if (_points.length < 2) return;

    final x = details.localPosition.dx.clamp(0.0, width);
    final index = (x / width * (_points.length - 1)).round();

    setState(() => _selectedIndex = index.clamp(0, _points.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    final (date, selfAvg, classAvg) = _points[_selectedIndex];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 12, right: 12),

        child: Container(
          decoration: BoxDecoration(
            color: context.c.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),

          padding: const EdgeInsets.all(12),
          height: 225,

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
                        Utils.formatNumber(selfAvg),
                        style: TextStyle(
                          fontSize: 25,
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
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: context.c.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanUpdate: (d) => _onPanUpdate(d, constraints.maxWidth),
                      onPanEnd: (_) => setState(() => _selectedIndex = 0),

                      onTapUp: (d) {
                        if (_points.length < 2) return;

                        final x = d.localPosition.dx.clamp(
                          0.0,
                          constraints.maxWidth,
                        );
                        final index =
                            (x / constraints.maxWidth * (_points.length - 1))
                                .round();

                        setState(
                          () => _selectedIndex = index.clamp(
                            0,
                            _points.length - 1,
                          ),
                        );
                      },

                      child: CustomPaint(
                        painter: _EvolutionPainter(
                          points: _points,
                          selectedIndex: _selectedIndex,
                          selfColor: context.c.primary,
                          classColor: context.c.secondary,
                          dotBorderColor: context.c.onPrimary,
                        ),

                        size: Size.infinite,
                      ),
                    );
                  },
                ),
              ),

              Text(
                DateFormat("dd/MM/yyyy").format(date),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvolutionPainter extends CustomPainter {
  final List<(DateTime, double, double?)> points;
  final int selectedIndex;
  final Color selfColor;
  final Color classColor;
  final Color dotBorderColor;

  const _EvolutionPainter({
    required this.points,
    required this.selectedIndex,
    required this.selfColor,
    required this.classColor,
    required this.dotBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final allValues = [
      for (final (_, self, classAvg) in points) ...[self, ?classAvg],
    ];

    final minVal = (allValues.reduce((a, b) => a < b ? a : b) - 1).clamp(
      0.0,
      20.0,
    );
    final maxVal = (allValues.reduce((a, b) => a > b ? a : b) + 1).clamp(
      0.0,
      20.0,
    );

    double toY(double value) =>
        (1 - (value - minVal) / (maxVal - minVal)) * size.height;

    final selfPaint = Paint()
      ..color = selfColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final classPaint = Paint()
      ..color = classColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final selfPath = Path();
    final classPath = Path();
    bool classStarted = false;

    for (int i = 0; i < points.length; i++) {
      final (_, self, classAvg) = points[i];
      final x = i / (points.length - 1) * size.width;

      if (i == 0) {
        selfPath.moveTo(x, toY(self));
      } else {
        selfPath.lineTo(x, toY(self));
      }

      if (classAvg != null) {
        if (!classStarted) {
          classPath.moveTo(x, toY(classAvg));
          classStarted = true;
        } else {
          classPath.lineTo(x, toY(classAvg));
        }
      }
    }

    canvas.drawPath(selfPath, selfPaint);
    if (classStarted) canvas.drawPath(classPath, classPaint);

    final (_, self, classAvg) = points[selectedIndex];
    final x = selectedIndex / (points.length - 1) * size.width;

    canvas.drawCircle(
      Offset(x, toY(self)),
      9.5,
      Paint()..color = dotBorderColor,
    );
    canvas.drawCircle(Offset(x, toY(self)), 7.5, Paint()..color = selfColor);

    if (classAvg != null) {
      canvas.drawCircle(
        Offset(x, toY(classAvg)),
        9.5,
        Paint()..color = dotBorderColor,
      );
      canvas.drawCircle(
        Offset(x, toY(classAvg)),
        7.5,
        Paint()..color = classColor,
      );
    }
  }

  @override
  bool shouldRepaint(_EvolutionPainter old) {
    return old.points != points ||
        old.selectedIndex != selectedIndex ||
        old.selfColor != selfColor ||
        old.classColor != classColor;
  }
}

class ServiceWidget extends StatelessWidget {
  final Service service;

  const ServiceWidget({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = Utils.adaptColorPair(service.color!, context.c);
    final hasSelfAverage = service.selfAverage != null;

    return Padding(
      padding: const EdgeInsets.only(top: 8),

      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.c.outlineVariant),
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
  final Exam exam;

  final bool isFirst;
  final bool isLast;

  const _ExamWidget({
    required this.exam,
    required this.isFirst,
    required this.isLast,
  });

  static const radius = Radius.circular(16);
  static const defaultRadius = Radius.circular(6);

  @override
  Widget build(BuildContext context) {
    final borderRadius = switch ((isFirst, isLast)) {
      (true, true) => const BorderRadius.all(radius),

      (true, _) => const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: defaultRadius,
        bottomRight: defaultRadius,
      ),

      (_, true) => const BorderRadius.only(
        topLeft: defaultRadius,
        topRight: defaultRadius,
        bottomLeft: radius,
        bottomRight: radius,
      ),

      _ => const BorderRadius.all(defaultRadius),
    };

    final title = exam.comment?.trim().isNotEmpty ?? false
        ? exam.comment!.trim()
        : context.l10n.gradeOf(exam.service.name);

    final (color, bgColor) = Utils.adaptColorPair(
      exam.service.color!,
      context.c,
    );

    return Pressable(
      // Si tu vois ça stp laisse le container
      child: Container(
        decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

          child: Row(
            spacing: 16,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      maxLines: 1,
                      overflow: .ellipsis,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    Text(
                      exam.date.asRelativeDate(context),

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Text.rich(
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
        ),
      ),
    );
  }
}
