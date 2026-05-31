import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/screens/shell/screens/homeworks/app_bar.dart";
import "package:antinote_app/frontend/screens/shell/screens/homeworks/body.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:flutter/material.dart";

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen>
    with ScreenMixin<HomeworksScreen> {
  final List<Homework> _homeworks = [];

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: RefreshIndicator(
        onRefresh: () => reload(fromRefreshIndicator: true),

        child: CustomScrollView(
          slivers: [
            const HomeworksAppBar(),

            HomeworksBody(homeworks: _homeworks),

            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget()));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(88);

    final page = await session.access(
      NotebookPageAccessor.upcoming(date: .now()),
    );

    _homeworks
      ..clear()
      ..addAll(page.homeworkSet?.homeworks ?? [])
      ..sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));
  }
}
