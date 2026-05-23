import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/main.dart";
import "package:flutter/material.dart";

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with AutomaticKeepAliveClientMixin {
  Future<SpecificInstanceParameters>? scheduleDisplayData;
  Future<List<Class>>? _classes;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    scheduleDisplayData ??= SessionManager.run(
      context: context,
      channels: [],
      callback: (session) {
        return session.instance;
      },
    );

    _classes ??= SessionManager.run(
      context: context,
      channels: [],

      callback: (session) async {
        talker.info("🟡 Starting ensurePage...");
        await session.ensurePage(16);
        talker.info("🟢 ensurePage done");

        final result = await session.access(
          TimetableAccessor.forRange(
            resource: session.userResource,
            from: DateTime.now().copyWith(isUtc: true).toDay(),
            to: null,
          ),
        );

        talker.info("🟢 Got ${result.classes.length} classes");
        return result.classes;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List<Class>>(
      future: _classes,

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          talker.info("⏳ State: ${snapshot.connectionState}, error: ${snapshot.error}");
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final clazz = snapshot.data![index];

            return Card(
              child: ListTile(title: Text(clazz.id), subtitle: Text("${clazz.startDate} → ${clazz.endDate}")),
            );
          },
        );
      },
    );
  }
}
