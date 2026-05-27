import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:flutter/material.dart";

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> with ScreenMixin<HomeworksScreen> {
  @override
  Widget buildLoaded(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(
      child: RefreshIndicator(
        onRefresh: () => reload(fromRefreshIndicator: true),

        child: CustomScrollView(),
      ),
    );
  }

  @override
  Widget buildLoading(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget(size: 30)));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(88);

    // await session.access(NotebookPageAccessor(weeks: weeks));
  }
}
