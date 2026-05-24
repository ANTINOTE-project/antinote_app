import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
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
        await session.ensurePage(16);

        final result = await session.access(
          TimetableAccessor.forRange(
            resource: session.userResource,
            from: DateTime.now().copyWith(isUtc: true).toDay(),
            to: null,
          ),
        );

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
          return const Center(child: LoadingWidget(size: 30));
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
