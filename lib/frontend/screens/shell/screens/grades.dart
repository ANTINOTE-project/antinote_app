import "package:antinote/antinote.dart";
import "package:flutter/material.dart";

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with
        TickerProviderStateMixin<GradesScreen>,
        AutomaticKeepAliveClientMixin<GradesScreen> {
  late TabController controller = TabController(length: 2, vsync: this);
  Future<List<Period>>? loadedPeriods;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [SliverAppBar()]);
  }
}
