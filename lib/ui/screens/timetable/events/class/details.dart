import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/app_bar.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/list.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showClassDetails(BuildContext context, Class defaultClass) async {
  final clazzCallback = context.ar.runTask<Class?>(
    context: context,
    callback: (session) async {
      final latestClass = session.getCachedValue<Class?>(
        .CLAZZ,
        defaultClass.visualId,
      );

      if (latestClass == null) return null;

      return (await session.access(
        ClassContentAccessor(
          classToAccess: latestClass,
          resource: session.curResource,
          withStudentCount: true,
          withStudentList: true,
        ),
      )).firstWhereOrNull((element) => element.id == latestClass.id);
    },
    debugLabel: 'Fetch detailed data about class',
  );

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _ClassDetailsScreen(
        defaultClass: defaultClass,
        clazzCallback: clazzCallback,
      ),
    ),
  );
}

class _ClassDetailsScreen extends StatelessWidget {
  final Class defaultClass;
  final Future<Class?> clazzCallback;

  const _ClassDetailsScreen({
    required this.defaultClass,
    required this.clazzCallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: clazzCallback,

      builder: (context, snapshot) {
        final clazz = snapshot.data ?? defaultClass;

        return Scaffold(
          appBar: AppBarWidget(
            title: Text(clazz.classTitle(context)),

            subtitle: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              alignment: .topCenter,

              child: clazz.studentCountString != null
                  ? Text(clazz.studentCountString!)
                  : const SizedBox.shrink(),
            ),
          ),

          body: _ClassDetailsBody(clazz: clazz),
        );
      },
    );
  }
}

class _ClassDetailsBody extends StatelessWidget {
  final Class clazz;

  const _ClassDetailsBody({required this.clazz});

  @override
  Widget build(BuildContext context) {
    final contents = Map.fromEntries(
      ClassHelpers.contentPriorities.map((e) => MapEntry(e, <ClassContent>[])),
    );

    for (final content in clazz.contents) {
      contents[content.runtimeType]?.add(content);
    }

    final sortedContentCategories =
        contents.entries
            .where((element) => element.value.isNotEmpty)
            .toList(growable: false)
          ..sort(
            (a, b) => ClassHelpers.contentPriorities
                .indexOf(a.key)
                .compareTo(ClassHelpers.contentPriorities.indexOf(b.key)),
          );

    final scheme = Utils.buildColorScheme(context, clazz.accentColor);

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),

      slivers: [
        SliverPadding(
          padding: const .symmetric(horizontal: 12),

          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  alignment: .topCenter,

                  child: Column(
                    children: [
                      ListWidget(
                        shrinkWrap: true,
                        isSliver: false,
                        physics: const NeverScrollableScrollPhysics(),
                        items: sortedContentCategories,

                        itemBuilder: (context, item, borderRadius) {
                          return TileWidget(
                            borderRadius: borderRadius,
                            backgroundColor: scheme.primaryContainer,

                            leading: Icon(item.value.first.icon),
                            title: Text(item.value.first.label(context)!),

                            subtitle: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastOutSlowIn,
                              alignment: .topLeft,

                              child: Wrap(
                                spacing: 6,

                                children: [
                                  for (final child in item.value)
                                    Text(
                                      child.data ??
                                          context.l10n.contentUnknowns,
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: .w800,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      Padding(
                        padding: const .symmetric(vertical: 12),
                        child: Text(
                          '${clazz.startDate.asLongNumericDate()} ${clazz.startDate.asNumericTime()} - ${clazz.endDate.asNumericTime()} (${Formatters.formatDuration(clazz.endDate.difference(clazz.startDate))})',
                          style: TextStyle(
                            color: context.c.onSurface,
                            fontWeight: .bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const BottomPadding(padding: 16),
            ],
          ),
        ),
      ],
    );
  }
}
