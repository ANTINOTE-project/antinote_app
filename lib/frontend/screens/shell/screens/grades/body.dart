import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades/index.dart";
import "package:flutter/material.dart";

class GradesBody extends StatelessWidget {
  final TabController controller;
  final List<GradesTab> tabs;

  const GradesBody({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: controller,
        children: tabs.mapL((e) => e.widget),
      ),
    );
  }
}
