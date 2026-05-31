import "package:flutter/material.dart";

class HomeworksAppBar extends StatelessWidget {
  const HomeworksAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(pinned: true, title: Text("Devoirs"));
  }
}
