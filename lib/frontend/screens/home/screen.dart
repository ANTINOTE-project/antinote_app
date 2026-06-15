import "dart:async";
import "dart:typed_data";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/home/widgets.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils/utils.dart";
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
  String? _establishmentName;

  Widget _buildWidget(HomePageWidget widget) {
    return switch (widget.widgetId) {
      HomePageWidgetType.vieScolaire => AttendanceWidget(
        data: widget as VieScolaire,
      ),
      HomePageWidgetType.travailAFaire => HomeworksWidget(
        data: widget as TravailAFaire,
      ),
      HomePageWidgetType.actualites => NewsWidget(data: widget as Actualites),
      HomePageWidgetType.notes => GradesWidget(data: widget as Notes),
      HomePageWidgetType.edt => TimetableWidget(data: widget as EDT),
      HomePageWidgetType.ds => ExamsWidget(data: widget as DS),

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
    return Scaffold(
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
                child: Pressable(
                  onPressed: () {
                    context.push(Routes.auth.accounts);
                  },

                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,

                    children: [
                      Text(
                        _displayName,

                        overflow: .ellipsis,
                        maxLines: 1,

                        style: const TextStyle(fontWeight: .w800, fontSize: 19),
                      ),

                      if (_establishmentName != null)
                        Text(
                          _establishmentName!,

                          overflow: .ellipsis,
                          maxLines: 1,

                          style: TextStyle(
                            color: context.c.outline,
                            fontWeight: .bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
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

      body: RefreshIndicator(
        onRefresh: () => reload(fromRefreshIndicator: true),

        child: ListView.builder(
          padding: .only(
            bottom: MediaQuery.paddingOf(context).bottom,
            right: 12,
            left: 12,
            top: 16,
          ),

          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _widgets.length,

          itemBuilder: (context, index) {
            final widget = _widgets[index];

            return Padding(
              padding: const .only(bottom: 16),
              child: _buildWidget(widget),
            );
          },
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

    var sortedWidgets = home.widgets;

    sortedWidgets.sort((a, b) => a.widgetId.id.compareTo(b.widgetId.id));
    sortedWidgets = sortedWidgets.reversed.toList(growable: false);

    _widgets = sortedWidgets;

    _displayName = session.userResource.name;
    _profilePicture = session.userResource.profilePicture;
    _establishmentName = session.userResource.establishmentName;
  }
}
