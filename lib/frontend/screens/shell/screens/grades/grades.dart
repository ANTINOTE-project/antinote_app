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

class GradesList extends StatefulWidget {
  final VisualId periodId;

  const GradesList({super.key, required this.periodId});

  @override
  State<GradesList> createState() => _GradesListState();
}

class _GradesListState extends State<GradesList>
    with AutomaticKeepAliveClientMixin<GradesList>, ScreenMixin<GradesList> {
  late LatestGradesPage _data;

  @override
  void didUpdateWidget(GradesList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.periodId != widget.periodId) {
      reload();
    }
  }

  @override
  Widget buildLoaded(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    final organizedData = <Service, List<Exam>>{for (final service in _data.services!) service: []};

    for (final exam in _data.exams) {
      final service = organizedData.keys.firstWhere((element) => element.id == exam.service.id);

      organizedData[service]!.add(exam);
    }

    return buildRefreshIndicator(
      child: CustomScrollView(
        slivers: [
          _AverageWidget(data: _data),

          for (final MapEntry(key: service, value: exams) in organizedData.entries)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),

              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    floating: true,
                    pinned: true,

                    delegate: _ServiceWidget(service: service),
                  ),

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
  Widget buildLoading(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget(size: 30)));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    final period = session.instance.periods.firstWhere((e) => e.visualId == widget.periodId);
    _data = await session.access(LatestGradesPageAccessor(period: period));
  }

  @override
  bool get wantKeepAlive => true;
}

class _AverageWidget extends StatelessWidget {
  final LatestGradesPage data;

  const _AverageWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 12, right: 12),

        child: Pressable(
          child: Container(
            decoration: BoxDecoration(
              color: context.c.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),

            padding: const EdgeInsets.all(12),
            height: 300,

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 8,

                  children: [
                    Text(
                      context.l10n.averageSelf,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      context.l10n.averageClass,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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

class _ServiceWidget extends SliverPersistentHeaderDelegate {
  final Service service;

  const _ServiceWidget({required this.service});

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: color),
                  ),
                ),

                if (hasSelfAverage)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: Utils.formatNumber(service.selfAverage!.value),
                          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
                        ),

                        const WidgetSpan(child: SizedBox(width: 2)),

                        TextSpan(
                          text: "/${Utils.formatNumber(service.theoreticalMaxGrade!.value)}",
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

  @override
  bool shouldRebuild(_ServiceWidget old) => old.service != service;
}

class _ExamWidget extends StatelessWidget {
  final Exam exam;

  final bool isFirst;
  final bool isLast;

  const _ExamWidget({required this.exam, required this.isFirst, required this.isLast});

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

    final (color, bgColor) = Utils.adaptColorPair(exam.service.color!, context.c);

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

                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                      style: TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.w900),
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
            ],
          ),
        ),
      ),
    );
  }
}
