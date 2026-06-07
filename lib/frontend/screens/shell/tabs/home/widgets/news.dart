import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class NewsWidget extends StatelessWidget {
  final Actualites data;

  const NewsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      label: context.l10n.homeNews,
      onShowMorePressed: () {},
      content: const SizedBox.shrink(),
    );
  }
}
