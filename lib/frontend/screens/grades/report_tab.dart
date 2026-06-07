import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:flutter/material.dart";

class ReportTab extends StatefulWidget {
  const ReportTab({super.key});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> with TabMixin<ReportTab> {
  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return const Placeholder();
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) {}
}
