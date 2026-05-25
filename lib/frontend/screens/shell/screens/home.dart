import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:flutter/material.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ScreenMixin<HomeScreen> {
  @override
  Widget buildLoaded(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget(size: 30)));
  }

  @override
  Widget buildLoading(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget(size: 30)));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) {
    // TODO: implement loadActiveDataFromSession
  }
}
