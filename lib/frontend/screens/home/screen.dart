import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/home/widgets.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeDisplayData data = HomeDisplayData();

  @override
  Widget build(BuildContext context) {
    return HomeDisplayDataAccessor(data: data, child: const HomeDisplay());
  }
}

class HomeDisplayDataAccessor extends InheritedWidget {
  const HomeDisplayDataAccessor({
    super.key,
    required this.data,
    required super.child,
  });

  final HomeDisplayData data;

  static HomeDisplayDataAccessor of(BuildContext context) {
    final HomeDisplayDataAccessor? result = context
        .dependOnInheritedWidgetOfExactType<HomeDisplayDataAccessor>();
    assert(result != null, "No HomeDisplayDataAccessor found in context");
    return result!;
  }

  @override
  bool updateShouldNotify(HomeDisplayDataAccessor old) {
    return old.data != data;
  }
}

class HomeDisplayData extends ChangeNotifier
    implements ValueListenable<List<HomePageWidget>?> {
  Map<String, dynamic> _curOverrides = {};
  DateTime? nextWorkingDay;
  int? weekNumber;

  @override
  List<HomePageWidget>? value;
  bool get pageLoaded => value != null;

  Future<T?> updateWidget<T extends HomePageWidget>(
    RemoteSession session,
    Map<String, dynamic> update,
    HomePageWidgetType? widgetId,
  ) async {
    nextWorkingDay ??= session.instance.nextBusinessDay;
    weekNumber ??= session.instance.getWeekNumberForDate(nextWorkingDay!);

    _curOverrides = deepMergeMaps(update, _curOverrides);

    final newPage = await session.access(
      HomePageAccessor(
        weekNumber: weekNumber!,
        nextWorkingDay: nextWorkingDay!,
        extras: _curOverrides,
        widgets: widgetId == null ? null : [widgetId],
      ),
    );

    HomePageWidget? retained;

    if (!pageLoaded) {
      value = newPage.widgets.toList();
      if (widgetId != null) {
        retained = value!.firstWhereOrNull((e) => e.widgetId == widgetId);
      }
    } else {
      for (final widget in newPage.widgets) {
        if (widget.widgetId == widgetId) retained = widget;

        final existingIndex = value!.indexWhere(
          (element) => element.widgetId == widget.widgetId,
        );
        if (existingIndex == -1) {
          value!.add(widget);
        } else {
          value![existingIndex] = widget;
        }
      }
    }

    notifyListeners();

    return retained as T?;
  }
}

class HomeDisplay extends StatefulWidget {
  const HomeDisplay({super.key});

  @override
  State<HomeDisplay> createState() => _HomeDisplayState();
}

class _HomeDisplayState extends State<HomeDisplay> with TabMixin<HomeDisplay> {
  List<HomePageWidget> _widgets = [];

  Uint8List? _profilePicture;
  late String _displayName;
  String? _establishmentName;

  Widget _buildWidget(BuildContext context, HomePageWidget widget) {
    return ValueListenableBuilder(
      valueListenable: HomeDisplayDataAccessor.of(context).data,
      builder: (context, state, _) {
        final latestWidget =
            state?.firstWhereOrNull(
              (element) => element.widgetId == widget.widgetId,
            ) ??
            widget;

        return switch (widget.widgetId) {
          HomePageWidgetType.vieScolaire => AttendanceWidget(
            data: latestWidget as VieScolaire,
          ),
          HomePageWidgetType.travailAFaire => HomeworksWidget(
            data: latestWidget as TravailAFaire,
          ),
          HomePageWidgetType.actualites => NewsWidget(
            data: latestWidget as Actualites,
          ),
          HomePageWidgetType.notes => GradesWidget(data: latestWidget as Notes),
          // TODO: Implement this in a way that no PageViews are used (do not
          // TODO: use the janky expandable_page_view package)
          HomePageWidgetType.edt =>
            const Placeholder() /*TimetableWidget(data: latestWidget as EDT)*/,
          HomePageWidgetType.ds => ExamsWidget(data: latestWidget as DS),

          _ => throw UnimplementedError(
            "Unknown home page widget for ${latestWidget.widgetId}",
          ),
        };
      },
    );
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    return Scaffold(
      appBar: AppBarWidget(
        leading: Container(
          height: 46,
          width: 46,

          decoration: const BoxDecoration(shape: .circle),
          clipBehavior: .antiAlias,

          child: _profilePicture != null && context.s.theme.showProfilePicture
              ? Image.memory(_profilePicture!, fit: .cover)
              : const CircleAvatar(),
        ),

        titleAlign: .centerStart,
        title: Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              Text(
                _displayName,
                overflow: .ellipsis,
                maxLines: 1,

                style: TextStyle(
                  fontWeight: .w800,
                  fontSize: 19,
                  color: context.c.onSurface,
                ),
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
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(HugeIconsSolid.settings01),
            tooltip: context.l10n.appSettings,
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
              child: _buildWidget(context, widget),
            );
          },
        ),
      ),
    );
  }

  @override
  Stream<double?> load(RemoteSession session) async* {
    await session.ensurePage(7);

    if (!mounted) return;

    final data = HomeDisplayDataAccessor.of(context).data;

    await data.updateWidget(session, {}, null);

    _widgets = data.value!.toList(growable: false);
    _widgets.sort((a, b) => b.widgetId.id.compareTo(a.widgetId.id));

    _displayName = session.userResource.name;
    _profilePicture = session.userResource.profilePicture;
    _establishmentName =
        session.userResource.establishmentName ??
        session.instance.establishmentName;
  }
}
