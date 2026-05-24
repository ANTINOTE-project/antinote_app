import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class GradesList extends StatefulWidget {
  final Period period;

  const GradesList({super.key, required this.period});

  @override
  State<GradesList> createState() => _GradesListState();
}

class _GradesListState extends State<GradesList>
    with AutomaticKeepAliveClientMixin<GradesList>, ScreenMixin<GradesList> {
  late LatestGradesPage _data;

  @override
  void didUpdateWidget(GradesList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.period != widget.period) {
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

    return CustomScrollView(
      slivers: [
        for (final MapEntry(key: service, value: exams) in organizedData.entries)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),

            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(child: _ServiceWidget(service: service)),

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

        const SliverPadding(padding: EdgeInsets.only(bottom: 128)),
      ],
    );
  }

  @override
  Widget buildLoading(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget(size: 30)));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    _data = await session.access(LatestGradesPageAccessor(period: widget.period));
  }

  @override
  bool get wantKeepAlive => true;
}

class _ServiceWidget extends StatelessWidget {
  final Service service;

  const _ServiceWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    final hasSelfAverage = service.selfAverage != null;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6, left: 2),

      child: Row(
        spacing: 8,

        children: [
          Expanded(
            child: Text(
              service.name,

              maxLines: 1,
              overflow: .ellipsis,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          if (hasSelfAverage)
            Text(
              "${service.selfAverage!.value} / ${service.theoreticalMaxGrade!.value}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }
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

    final grade =
        "${Utils.formatNumber(exam.selfGrade.value)}/${Utils.formatNumber(exam.theoreticalMaxGrade.value)}";

    return Container(
      decoration: BoxDecoration(color: context.c.surfaceContainerHigh, borderRadius: borderRadius),

      child: ListTile(
        title: Text(
          title,

          maxLines: 1,
          overflow: .ellipsis,

          style: const TextStyle(fontWeight: FontWeight.w500),
        ),

        subtitle: Text(exam.date.asRelativeDate(context)),

        trailing: Text(grade),
      ),
    );
  }
}
