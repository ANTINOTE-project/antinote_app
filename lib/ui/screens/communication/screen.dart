import 'dart:async';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/ui/screens/communication/models.dart';
import 'package:antinote_app/ui/screens/communication/news.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:intl/intl.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen>
    with PageMixin<CommunicationScreen>, TabMixin<CommunicationScreen> {
  CommunicationFilter filter = CommunicationFilter.defaultFilter;
  late List<CommunicationThreadPreview> threads;

  static final _minimalDateFormat = DateFormat(DateFormat.MONTH_DAY);

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    return buildRefreshIndicator(
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 4),

        child: ListWidget(
          items: threads,
          isSliver: false,

          itemBuilder: (context, thread, borderRadius) {
            return ItemWidget(
              borderRadius: borderRadius,

              title: Text(thread.title),
              subtitle: Text(thread.authorName),

              leading: Badge(
                isLabelVisible: !thread.read,
                smallSize: 7,

                child: Icon(switch (thread.commType) {
                  .discussion => HugeIconsSolid.conversation,
                  .news => HugeIconsSolid.news01,
                  .poll => HugeIconsSolid.pieChart,
                }, size: 24),
              ),

              trailing: Text(
                _minimalDateFormat.format(thread.publishDate),

                style: TextStyle(
                  fontWeight: .w800,
                  color: context.c.outline,
                  fontSize: 13,
                ),
              ),

              onPressed: () async {
                await context.ar.runTask(
                  context: context,
                  channels: const {},
                  callback: (session) {
                    switch (thread.commType) {
                      case .poll:
                      case .news:
                        {
                          if (!context.mounted ||
                              thread is! InformationThreadPreview) {
                            return;
                          }

                          final notifier = ValueNotifier(
                            session.getCachedValue<News>(
                              .NEWS,
                              thread.visualId,
                            ),
                          );

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => NewsScreen(
                                mode: thread.mode,
                                news: notifier,

                                deleteNews: () {
                                  throw UnimplementedError();
                                },
                              ),
                            ),
                          );
                        }
                      case .discussion:
                        {
                          throw UnimplementedError();
                        }
                    }
                  },
                  debugLabel: 'Retrieve news and discussion data from cache.',
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<CommunicationThreadPreview>> _loadThreads(
    RemoteSession session,
    CommunicationType type,
  ) async {
    switch (type) {
      case .poll:
      case .news:
        {
          final newsPage = await session.access(
            const NewsPageAccessor.defaultMode(),
          );

          final threads = newsPage.collections
              .map(
                (collection) => collection.news.map(
                  (e) => InformationThreadPreview(
                    title: e.label,
                    publishDate: e.creationTime,
                    commType: e.isPoll ? .poll : .news,
                    authorName: e.author,
                    visualId: e.visualId,
                    read: e.read,
                    mode: collection.mode,
                  ),
                ),
              )
              .fold(
                <InformationThreadPreview>[],
                (previousValue, element) => previousValue..addAll(element),
              )
              .toList(growable: false);

          return threads;
        }
      case .discussion:
        {
          final page = await session.access(
            const DiscussionPageAccessor(showRead: true, withMessages: true),
          );

          return page.discussions.mapL(
            (e) => DiscussionThreadPreview(
              title: e.subject,
              publishDate: e.parsedDateLabel,
              commType: .discussion,
              authorName: e.initiator ?? session.userResource.name,
              visualId: e.visualId,
              read: e.read,
            ),
          );
        }
    }
  }

  @override
  Stream<double?> load(RemoteSession session) async* {
    final threads = <CommunicationThreadPreview>[];

    final curPage = session.stack.clientSignature?.tab;
    final toLoad = filter.allowedTypes.toSet();

    if (!loaded) {
      this.threads = [];
    }

    yield 0;

    int loadedCount = 0;

    for (final commType in filter.allowedTypes.where(
      (element) => session.user.hasAccessToTab(element.pageId),
    )) {
      if (commType.pageId == curPage) {
        threads.addAll(await _loadThreads(session, commType));
        toLoad.remove(commType);

        if (!loaded) {
          this.threads = threads
            ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
        }

        loadedCount++;
        yield loadedCount / toLoad.length;
        break;
      }
    }

    for (final commType in toLoad) {
      threads.addAll(await _loadThreads(session, commType));

      if (!loaded) {
        this.threads = threads
          ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
      }

      loadedCount++;
      yield loadedCount / toLoad.length;
    }

    // Supposed to be 1 anyways but just to be sure...
    yield 1;
  }
}
