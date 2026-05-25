import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/screens/shell/models/communication.dart";
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

  static final _minimalDateFormat = DateFormat('MMM d');

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
            onPressed: () {},
            title: thread.title,
            emphaseTitle: !thread.read,
            subtitle: thread.authorName,
            leading: Icon(switch (thread.commType) {
              CommunicationType.discussion => HugeIconsSolid.informationCircle,
              CommunicationType.news => HugeIconsSolid.news,
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
                  commType: .news,
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
