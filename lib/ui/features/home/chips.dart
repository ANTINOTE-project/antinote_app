import 'dart:typed_data';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/data.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/ui/features/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

final class const AvailableProfile({
  required final String name,
  required final Uint8List? picture,
  required final String? visualId,
  required final String? clazz,
});

class HomePageChips extends StatefulWidget {
  const HomePageChips({
    super.key,
    required this.account,
    required this.manager,

    required this.reloadPage,
  });

  final AntinoteAccount? account;
  final HomePageManager manager;

  final VoidCallback reloadPage;

  @override
  State<HomePageChips> createState() => _HomePageChipsState();
}

class _HomePageChipsState extends State<HomePageChips>
    with PageMixin<HomePageChips>, TabMixin<HomePageChips> {
  List<AvailableProfile>? profiles;
  String? curProfileId;

  AvailableProfile? get curProfile =>
      (profiles ?? <AvailableProfile>[]).firstWhereOrNull(
        (element) => element.visualId == curProfileId,
      ) ??
      (widget.account == null
          ? null
          : .new(
              name: widget.account!.name,
              picture: null,
              visualId: null,
              clazz: null,
            ));

  final GlobalKey scrollViewKey = GlobalKey(
    debugLabel: 'Home page chips scroll view',
  );

  Widget buildAlways(BuildContext context) {
    return SingleChildScrollView(
      key: scrollViewKey,
      scrollDirection: .horizontal,
      child: Row(
        children: [
          HomePageChip(
            leading: loaded && curProfile != null && curProfile!.picture == null
                ? null
                : CircleAvatar(
                    foregroundImage: curProfile?.picture == null
                        ? null
                        : MemoryImage(curProfile!.picture!),
                    backgroundColor: context.c.surface,
                  ),
            label: curProfile != null
                ? Text(curProfile!.name, maxLines: 1)
                : const Skeletonizer(child: Text('no account')),
            trailing: AnimatedSize(
              duration: const .new(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              child: Icon(
                HugeIconsSolid.arrowDown01,
                size: profiles != null && profiles!.length > 1 ? 18 : 0,
              ),
            ),

            onTap: loaded && profiles!.length > 1
                ? () async {
                    if (profiles?.isEmpty ?? true) return;

                    final chipRenderBox =
                        scrollViewKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    final chipPosition = chipRenderBox
                        ?.globalToLocal(.zero)
                        .scale(-1, -1);

                    final picked = await showMenu<String>(
                      context: context,
                      position: chipPosition == null
                          ? .fill
                          : .fromLTRB(
                              chipPosition.dx,
                              chipPosition.dy + chipRenderBox!.size.height + 2,
                              chipPosition.dx + chipRenderBox.size.width,
                              0,
                            ),
                      constraints: .tightFor(width: chipRenderBox?.size.width),
                      menuPadding: .zero,
                      color: context.c.surfaceContainerLow,
                      shape: const ContinuousRectangleBorder(
                        // Ideally this would be
                        // .all(
                        //   top: .circular(8),
                        //   bottom: .circular(16),
                        // )
                        // with shape morphing on the chip.
                        borderRadius: .all(.circular(16)),
                      ),
                      items: [
                        for (final profile in profiles!)
                          if (profile != curProfile)
                            PopupMenuItem(
                              value: profile.visualId,
                              padding: const .symmetric(horizontal: 8),
                              child: Padding(
                                padding: const .only(left: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircleAvatar(
                                        foregroundImage: profile.picture == null
                                            ? null
                                            : MemoryImage(profile.picture!),
                                        backgroundColor: context.c.surface,
                                      ),
                                    ),
                                    Padding(
                                      padding: const .symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(text: profile.name),
                                                if (profile.clazz != null) ...[
                                                  const TextSpan(text: '\n'),
                                                  TextSpan(
                                                    text: profile.clazz!,
                                                    style: context.tt.bodySmall
                                                        ?.copyWith(
                                                          color: context
                                                              .c
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    );

                    if (picked == null || !mounted || !context.mounted) return;

                    final pickSuccessful = await context.ar.runTask(
                      context: context,
                      callback: (session) {
                        final resource = session.user.allResources
                            .firstWhereOrNull(
                              (element) => element.visualId == picked,
                            );

                        if (resource == null) return false;

                        session.changeUserResource(resource);

                        return true;
                      },
                      debugLabel: 'Update the currently selected resource',
                    );

                    if (pickSuccessful) {
                      logger.info('Successfully picked account $picked');
                    } else {
                      logger.warning('Failed to pick account $picked');
                    }

                    if (mounted) await reload();
                    if (mounted) widget.reloadPage();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    return buildAlways(context);
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    double? progress,
  ) {
    return buildAlways(context);
  }

  @override
  Set<String> get loadChannels => {};

  @override
  Future<void> load(RemoteSession session) async {
    final curProfiles = <AvailableProfile>[];
    String? curProfile;

    for (final resource in session.user.requestableResources) {
      final visualId = resource.visualId;

      curProfiles.add(
        .new(
          name: resource.name,
          picture: resource.profilePicture,
          visualId: visualId,
          clazz: resource.studentClass?.name,
        ),
      );

      if (curProfile == null ||
          session.stack.clientSignature?.member.id == resource.id) {
        curProfile = visualId;
      }
    }

    profiles = curProfiles.toList(growable: false);
    curProfileId = curProfile;
  }
}

class HomePageChip extends StatelessWidget {
  const new({
    super.key,
    this.leading,
    required this.label,
    this.trailing,

    this.onTap,
  });

  final Widget? leading;
  final Widget label;
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const .all(4),
      decoration: BoxDecoration(
        color: context.c.surfaceContainerLow,
        borderRadius: .circular(16),
      ),
      height: 48,
      child: InkWell(
        borderRadius: .circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: .circular(12),
            color: onTap != null
                ? context.c.tertiaryContainer
                : context.c.surface,
          ),
          padding: const .symmetric(horizontal: 8),
          height: 44,
          child: DefaultTextStyle(
            style: (context.tt.labelLarge ?? DefaultTextStyle.of(context).style)
                .copyWith(
                  color: onTap != null
                      ? context.c.onTertiaryContainer
                      : context.c.onSurface,
                ),
            child: IconTheme(
              data: .new(color: context.c.onTertiaryContainer, size: 18),
              child: Row(
                children: [
                  if (leading != null)
                    ConstrainedBox(
                      constraints: const .new(maxWidth: 18, maxHeight: 18),
                      child: leading!,
                    ),
                  Padding(
                    padding: const .symmetric(horizontal: 8),
                    child: label,
                  ),
                  if (trailing != null)
                    ConstrainedBox(
                      constraints: const .new(maxWidth: 18, maxHeight: 18),
                      child: trailing!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
