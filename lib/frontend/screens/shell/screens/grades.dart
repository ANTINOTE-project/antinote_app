import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:flutter/material.dart";

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with TickerProviderStateMixin<GradesScreen> {
  late TabController controller = TabController(length: 2, vsync: this);
  Future<List<Period>>? loadedPeriods;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          actions: [
            IconButton(
              onPressed: () {
                SessionManager.execute(
                  context: context,
                  callback: (session) async {
                    await session.access(const DisconnectionAccessor.logged());
                  },
                );
              },
              icon: const Icon(Icons.eighteen_mp),
            ),
          ],
        ),
      ],
    );
  }
}
