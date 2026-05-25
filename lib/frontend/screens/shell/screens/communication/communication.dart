import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/screens/shell/models/communication.dart";
import "package:antinote_app/frontend/screens/shell/screens/communication/news.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen>
    with ScreenMixin<CommunicationScreen> {
  CommunicationFilter filter = CommunicationFilter.defaultFilter;
  late List<CommunicationThreadPreview> threads;

  static final _minimalDateFormat = DateFormat("MMM d");

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: ListView.builder(
        itemBuilder: (context, index) {
          final thread = threads[index];

          return ListItemCard(
            onPressed: () async {
              await SessionManager.execute(
                context: context,
                channels: const [],
                callback: (session) {
                  switch (thread.commType) {
                    case .poll:
                    case .news:
                      {
                        if (!context.mounted) return;

                        final notifier = ValueNotifier(
                          session.getCachedValue<News>(.NEWS, thread.visualId),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsScreen(
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
              );
            },
            title: thread.title,
            emphaseTitle: !thread.read,
            subtitle: thread.authorName,
            leading: Icon(switch (thread.commType) {
              .discussion => HugeIconsSolid.conversation,
              .news => HugeIconsSolid.news01,
              .poll => HugeIconsSolid.pieChart,
            }),
            trailing: Text(_minimalDateFormat.format(thread.publishDate)),
          );
        },
        itemCount: threads.length,
      ),
    );
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<List<CommunicationThreadPreview>> loadThreads(
    PronoteSession session,
    CommunicationType type,
  ) async {
    await session.ensurePage(type.pageId);

    switch (type) {
      case .poll:
      case .news:
        {
          final news = await session.access(
            const NewsPageAccessor.defaultMode(),
          );
          return news.collections
              .fold(
                <News>[],
                (previousValue, element) => previousValue + element.news,
              )
              .mapL(
                (e) => CommunicationThreadPreview(
                  title: e.label,
                  publishDate: e.creationTime,
                  commType: e.isPoll ? .poll : .news,
                  authorName: e.author,
                  visualId: e.visualId,
                  read: e.read,
                ),
              );
        }
      case .discussion:
        {
          final page = await session.access(
            const DiscussionPageAccessor(showRead: true, withMessages: true),
          );
          return page.discussions.mapL(
            (e) => CommunicationThreadPreview(
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
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    final threads = <CommunicationThreadPreview>[];

    final curPage = session.stack.clientSignature?.get("onglet");
    final toLoad = filter.allowedTypes.toSet();

    for (final commType in filter.allowedTypes) {
      if (commType.pageId == curPage) {
        threads.addAll(await loadThreads(session, commType));
        toLoad.remove(commType);
        break;
      }
    }

    for (final commType in toLoad) {
      threads.addAll(await loadThreads(session, commType));
    }

    this.threads = threads
      ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
  }
}
