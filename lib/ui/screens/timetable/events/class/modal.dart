import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showClassModal(BuildContext context, Class defaultClass) async {
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
          resource: session.userResource,
          withStudentCount: true,
          withStudentList: true,
        ),
      )).firstWhereOrNull((element) => element.id == latestClass.id);
    },
    debugLabel: 'Fetch detailed data about class',
  );

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return FutureBuilder(
        future: clazzCallback,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.fastOutSlowIn,
            child: SingleChildScrollView(
              key: ValueKey(snapshot.connectionState == .done),
              child: ClassModalContents(clazz: snapshot.data ?? defaultClass),
            ),
          );
        },
      );
    },
  );
}

class ClassModalContents extends StatelessWidget {
  const ClassModalContents({super.key, required this.clazz});

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

    return Container(
      padding: const .all(12),
      child: Column(
        children: [
          Text(
            clazz.classTitle(context),
            textAlign: .center,
            maxLines: 2,
            overflow: .ellipsis,
            style: TextTheme.of(context).headlineSmall
                ?.copyWith(fontWeight: .w800),
          ),
          if (clazz.studentCountString != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),

              child: Text(
                clazz.studentCountString!,

                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          Padding(
            padding: const .only(top: 16),
            child: ListWidget(
              shrinkWrap: true,
              isSliver: false,
              physics: const NeverScrollableScrollPhysics(),
              items: sortedContentCategories,
              itemBuilder: (context, item, borderRadius) {
                return ItemWidget(
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
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '${clazz.startDate.asLongNumericDate()} ${clazz.startDate.asNumericTime()} - ${clazz.endDate.asNumericTime()} (${Formatters.formatDuration(clazz.endDate.difference(clazz.startDate))})',
              style: TextStyle(color: context.c.onSurface, fontWeight: .bold),
            ),
          ),
        ],
      ),
    );
  }
}
