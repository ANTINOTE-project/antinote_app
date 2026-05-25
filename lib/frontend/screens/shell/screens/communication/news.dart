import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/widgets/remote_html.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, required this.news, required this.deleteNews});

  final ValueNotifier<News> news;
  final VoidCallback deleteNews;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // TODO: Check if there are session-specific IDs we SEND when we give out the
  // TODO: updated answers to a poll.
  final Map<String, NewsQuestionAnswer> _overriddenAnswers = {};

  Future<void> sendCompleted() async {
    // TODO: Reimplement it in a safe manner
    throw UnimplementedError();
    // await SessionManager.execute(
    //   context: context,
    //   callback: (session) async {
    //     await session.ensurePage(CommunicationType.news.pageId);
    //
    //     await session.access(
    //       ChangeNewsStateAccessor(
    //         updatesToPerform: {
    //           widget.news.value!: NewsUpdate(
    //             read:
    //                 _overriddenAnswers.values.any(
    //                   (final element) =>
    //                       element is RANewsQuestionAnswer && element.answered,
    //                 )
    //                 ? true
    //                 : null,
    //             onlyMarkedRead: null,
    //             deleted: null,
    //             answersToChange: _overriddenAnswers.map(
    //               (key, value) => MapEntry(
    //                 session.getCachedValue<NewsQuestion>(.NEWS_QUESTION, key),
    //                 value,
    //               ),
    //             ),
    //           ),
    //         },
    //       ),
    //     );
    //   },
    // );
    //
    // news = await widget.onNewsUpdated();
  }

  Future<void> invertReadStatus() async {
    throw UnimplementedError();

    // await SessionManager.run(
    //   context: context,
    //   callback: (session) async {
    //     await session.ensurePage(CommunicationType.news.pageId);
    //
    //     await session.access(
    //       ChangeNewsStateAccessor(
    //         updatesToPerform: {
    //           news: NewsUpdate(
    //             read: !news.read,
    //             onlyMarkedRead: !news.read ? true : null,
    //             deleted: null,
    //             answersToChange: {},
    //           ),
    //         },
    //       ),
    //     );
    //   },
    // );

    // news = await widget.onNewsUpdated();
  }

  Future<void> delete() async {
    throw UnimplementedError();

    // await SessionManager.execute(
    //   context: context,
    //   callback: (session) async {
    //     await session.ensurePage(CommunicationType.news.pageId);
    //
    //     await session.access(
    //       ChangeNewsStateAccessor(
    //         updatesToPerform: {
    //           news: NewsUpdate(
    //             read: null,
    //             onlyMarkedRead: null,
    //             deleted: true,
    //             answersToChange: {},
    //           ),
    //         },
    //       ),
    //     );
    //   },
    // );

    // news = await widget.onNewsUpdated();
  }

  News get news => widget.news.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(news.label, maxLines: 1, overflow: .ellipsis),
            actions: [
              IconButton(
                onPressed: delete,
                icon: const Icon(HugeIconsSolid.delete01),
              ),
              IconButton(
                onPressed: invertReadStatus,
                icon: Icon(
                  news.read
                      ? HugeIconsSolid.checkUnread01
                      : HugeIconsSolid.checkUnread02,
                ),
              ),
            ],
          ),
          PinnedHeaderSliver(
            child: ListItemCard(
              onPressed: null,
              title: news.author,
              subtitle:
                  context.l10n.recipient(
                    news.recipientFirstName ?? context.l10n.self,
                  ) +
                  (!news.isPoll
                      ? ""
                      : (news.anonymousResponse
                            ? context.l10n.anonymousPoll
                            : context.l10n.nominativePoll)),
              trailing: Text(news.creationTime.asRelativeDate(context)),
            ),
          ),
          SliverToBoxAdapter(
            child: Card(
              child: Column(
                children: [
                  for (int i = 0; i < news.questions.length; i++)
                    NewsQuestionWidget(
                      question: news.questions[i],
                      isFirst: i == 0,
                      isLast: i == news.questions.length - 1,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsQuestionWidget extends StatelessWidget {
  const NewsQuestionWidget({
    super.key,
    required this.question,
    required this.isFirst,
    required this.isLast,
  });

  final NewsQuestion question;

  final bool isFirst;
  final bool isLast;

  static const radius = Radius.circular(16);
  static const defaultRadius = Radius.circular(6);

  @override
  Widget build(BuildContext context) {
    final borderRadius = switch ((isFirst, isLast)) {
      (true, true) => const BorderRadius.all(radius),

      (true, _) => const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: defaultRadius,
        bottomRight: defaultRadius,
      ),

      (_, true) => const BorderRadius.only(
        topLeft: defaultRadius,
        topRight: defaultRadius,
        bottomLeft: radius,
        bottomRight: radius,
      ),

      _ => const BorderRadius.all(defaultRadius),
    };

    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceContainerLow,
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          RemoteHtml(rawHtml: question.htmlText),
          if (!<NewsQuestionAnswerType>[
            .withoutResponse,
            .withoutReceiptAcknowledgment,
          ].contains(question.responseType)) ...[
            const Divider(),
          ],
        ],
      ),
    );
  }
}

class NewsQuestionAnswerWidget extends StatefulWidget {
  const NewsQuestionAnswerWidget({
    super.key,
    required this.question,
    required this.answerEmitted,
  });

  final NewsQuestion question;
  final Future<void> Function(NewsQuestionAnswer newAnswer) answerEmitted;

  @override
  State<NewsQuestionAnswerWidget> createState() =>
      _NewsQuestionAnswerWidgetState();
}

class _NewsQuestionAnswerWidgetState extends State<NewsQuestionAnswerWidget> {
  @override
  Widget build(BuildContext context) {
    final answer = widget.question.answer;
    return switch (answer) {
      RANewsQuestionAnswer(answered: final answered) => ListTile(
        title: Text(context.l10n.raMessage),
        trailing: Checkbox(
          value: answered,
          onChanged: answered
              ? null
              : (value) async {
                  await widget.answerEmitted(answer.buildAnswered());
                },
        ),
      ),
      WithoutRANewsQuestionAnswer() => const SizedBox.shrink(),
      NoResponseNewsQuestionAnswer() => const SizedBox.shrink(),
      // TODO: Handle this case.
      SingleChoiceNewsQuestionAnswer() => throw UnimplementedError(),
      // TODO: Handle this case.
      MultipleChoiceNewsQuestionAnswer() => throw UnimplementedError(),
    };
  }
}
