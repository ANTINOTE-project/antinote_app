import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/app_bar.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/list.dart';
import 'package:collection/collection.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showClassModal(BuildContext context, Class defaultClass) async {
  final clazzCallback = context.ar.runTask<Class?>(
    debugLabel: 'Fetch detailed data about class',
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
  );

  await showModalBottomSheet(
    backgroundColor: context.c.surfaceContainerLowest,
    context: context,
    isScrollControlled: true,
    showDragHandle: true,

    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),

        child: FutureBuilder(
          future: clazzCallback,
          builder: (context, snapshot) {
            return _Modal(clazz: snapshot.data ?? defaultClass);
          },
        ),
      );
    },
  );
}

class _Modal extends StatelessWidget {
  const _Modal({required this.clazz});

  final Class clazz;

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

    final hasStatus = clazz.status != null;
    final canceled = clazz.canceled;

    return CustomScrollView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),

      slivers: [
        SliverPadding(
          padding: const .symmetric(horizontal: 12),

          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  spacing: 12,

                  children: [
                    AppBarWidget(
                      backButton: false,
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

                    if (hasStatus)
                      TileWidget(
                        borderRadius: const .all(ListWidget.radius),
                        backgroundColor: canceled
                            ? scheme.errorContainer
                            : scheme.surfaceContainer,

                        leading: Icon(
                          canceled
                              ? HugeIconsSolid.alertCircle
                              : HugeIconsSolid.informationCircle,
                          color: canceled ? scheme.error : scheme.secondary,
                        ),

                        title: Text(
                          clazz.status!,
                          style: TextStyle(
                            color: canceled ? scheme.error : scheme.secondary,
                            fontWeight: .w900,
                          ),
                        ),
                      ),

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

                          subtitle: Wrap(
                            spacing: 6,

                            children: [
                              for (final child in item.value)
                                Text(
                                  child.data ?? context.l10n.contentUnknowns,
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontWeight: .w800,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    Row(
                      mainAxisAlignment: .spaceAround,

                      children: [
                        Text(
                          clazz.startDate.asLongNumericDate(),
                          textAlign: .center,
                          style: TextStyle(
                            color: context.c.onSurface,
                            fontWeight: .bold,
                          ),
                        ),

                        Text(
                          '${clazz.startDate.asNumericTime()} - ${clazz.endDate.asNumericTime()}',
                          textAlign: .center,
                          style: TextStyle(
                            color: context.c.onSurface,
                            fontWeight: .bold,
                          ),
                        ),

                        Text(
                          Formatters.formatDuration(
                            clazz.endDate.difference(clazz.startDate),
                          ),
                          textAlign: .center,
                          style: TextStyle(
                            color: context.c.onSurface,
                            fontWeight: .bold,
                          ),
                        ),
                      ],
                    ),
                  ],
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
