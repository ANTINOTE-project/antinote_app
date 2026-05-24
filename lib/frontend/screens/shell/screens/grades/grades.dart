import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
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

    return CustomScrollView(
      slivers: [
        for (final MapEntry(key: service, value: exams)
            in organizedData.entries)
          SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(child: Text(service.name)),

              SliverList.builder(
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return Text(exam.comment ?? "Pas de nom");
                },
              ),
            ],
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 128)),
      ],
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

    _data = await session.access(
      LatestGradesPageAccessor(period: widget.period),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
