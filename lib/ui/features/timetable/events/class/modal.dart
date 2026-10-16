import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/list.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:collection/collection.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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

    final List<String?> subtitles = [clazz.studentCountString, clazz.status];
    final List<String> presentSubtitles = subtitles.whereType<String>().toList(
      growable: false,
    );

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
                  children: [
                    Text(
                      clazz.classTitle(context),
                      style: context.tt.classTitle,
                    ),
                    AnimatedOpacity(
                      opacity: presentSubtitles.isEmpty ? 0 : 1,
                      duration: const .new(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            for (final subtitle in subtitles)
                              WidgetSpan(
                                child: AnimatedOpacity(
                                  duration: const .new(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                  opacity: subtitle == null ? 0 : 1,
                                  child: AnimatedSize(
                                    duration: const .new(milliseconds: 300),
                                    curve: Curves.fastOutSlowIn,
                                    alignment:
                                        presentSubtitles.singleOrNull ==
                                            subtitle
                                        ? .center
                                        : presentSubtitles.firstOrNull ==
                                              subtitle
                                        ? .centerRight
                                        : (presentSubtitles.firstOrNull ==
                                                  subtitle
                                              ? .centerLeft
                                              : .center),
                                    child: Container(
                                      constraints: subtitle == null
                                          ? const .new(maxWidth: 0)
                                          : null,
                                      child: Text(
                                        '${presentSubtitles.firstOrNull != subtitle ? ' ' : ''}$subtitle${presentSubtitles.lastOrNull != subtitle ? ' •' : ''}',
                                        maxLines: 1,
                                        overflow: .clip,
                                        style: context.tt.classSubtitle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            if (presentSubtitles.isEmpty)
                              const TextSpan(text: 'xxx'),
                          ],
                        ),
                        style: context.tt.classSubtitle,
                        maxLines: 2,
                      ),
                    ),

                    const Padding(padding: .symmetric(vertical: 4)),

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

                    if (clazz.contents.any(
                      (element) => element is VirtualClassroomContent,
                    )) ...[
                      TextIcon(
                        label: context.l10n.contentVirtualClassrooms,
                        icon: HugeIconsSolid.computerVideoCall,
                      ),
                      ListWidget(
                        shrinkWrap: true,
                        isSliver: false,
                        physics: const NeverScrollableScrollPhysics(),
                        items: clazz.contents
                            .whereType<VirtualClassroomContent>()
                            .toList(growable: false),

                        itemBuilder: (context, item, borderRadius) {
                          return TileWidget(
                            borderRadius: borderRadius,
                            backgroundColor: scheme.primaryContainer,

                            leading: const Icon(HugeIconsSolid.link01),
                            title: Text(item.value.comment),
                            subtitle: Text(item.value.linkLabel),
                            trailing: const Icon(HugeIconsSolid.arrowRight01),

                            onPressed: () {
                              launchUrl(
                                item.value.url,
                                mode: .externalApplication,
                              );
                            },
                          );
                        },
                      ),
                    ],

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
