import "dart:async";
import "dart:typed_data";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/attendance.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TabMixin<HomeScreen> {
  List<HomePageWidget> _widgets = [];

  Uint8List? _profilePicture;
  late String _displayName;

  Widget _buildWidget(HomePageWidget widget) {
    return switch (widget.widgetId) {
      HomePageWidgetType.vieScolaire => AttendanceWidget(
        data: widget as VieScolaire,
      ),

      // TODO add others widgets
      HomePageWidgetType.travailAFaire => const SizedBox.shrink(),
      HomePageWidgetType.actualites => const SizedBox.shrink(),
      HomePageWidgetType.notes => const SizedBox.shrink(),
      HomePageWidgetType.edt => const SizedBox.shrink(),
      HomePageWidgetType.ds => const SizedBox.shrink(),

      _ => throw UnimplementedError(
        "Unknown home page widget for ${widget.widgetId}",
      ),
    };
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: Scaffold(
        appBar: AppBarWidget(
          leading: Padding(
            padding: const .only(left: 6),

            child: Row(
              spacing: 10,

              children: [
                Container(
                  height: 46,
                  width: 46,

                  decoration: const BoxDecoration(shape: .circle),
                  clipBehavior: .antiAlias,

                  child: _profilePicture != null
                      ? Image.memory(_profilePicture!, fit: .cover)
                      : const CircleAvatar(),
                ),

                // TODO fix overflow
                Expanded(
                  child: Text(
                    _displayName,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: const TextStyle(fontWeight: .w800, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            IconButton(
              onPressed: () => context.push(Routes.settings),
              icon: const Icon(HugeIconsSolid.settings01),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const .only(top: 16, left: 12, right: 12),

          child: Column(
            children: [
              ..._widgets.mapIndexed((index, widget) {
                return _buildWidget(widget);
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(7);

    final home = await session.access(
      HomePageAccessor(
        nextWorkingDay: session.instance.nextBusinessDay,
        weekNumber: session.instance.nextBusinessDay.toPronoteWeekNumber(
          session,
        ),
      ),
    );

    _widgets = home.widgets;

    _displayName = session.userResource.name;
    _profilePicture = session.userResource.profilePicture;
  }
}
