import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/html_text.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";

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

  Future<void> _sendCompleted() async {
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

  Future<void> _toggleReadStatus() async {
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

  Future<void> _delete() async {
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

  News get _news => widget.news.value;

  static final _dateFormat = DateFormat(DateFormat.MONTH_WEEKDAY_DAY);

  @override
  Widget build(BuildContext context) {
    final String pollSuffix = !_news.isPoll
        ? ""
        : " (${_news.anonymousResponse ? context.l10n.anonymousPoll : context.l10n.nominativePoll})";

    final subtitle =
        "${context.l10n.recipient(_news.recipientFirstName ?? context.l10n.self)}$pollSuffix";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: context.pop,
              icon: const Icon(HugeIconsSolid.arrowLeft01, size: 22),
            ),

            actions: [
              IconButton(
                onPressed: _delete,
                icon: const Icon(HugeIconsSolid.delete01, size: 22),
              ),

              IconButton(
                onPressed: _toggleReadStatus,
                icon: Icon(
                  _news.read
                      ? HugeIconsSolid.checkUnread01
                      : HugeIconsSolid.checkUnread02,
                  size: 22,
                ),
              ),
            ],
          ),

          PinnedHeaderSliver(
            child: Padding(
              padding: const .symmetric(horizontal: 12),

              child: Column(
                spacing: 8,

                children: [
                  Padding(
                    padding: const .only(left: 6),

                    child: Align(
                      alignment: .centerLeft,

                      child: Text(
                        _news.label,
                        style: const TextStyle(fontWeight: .w800, fontSize: 22),
                      ),
                    ),
                  ),

                  ItemWidget(
                    borderRadius: const .all(ListWidget.radius),

                    title: Text(
                      _news.author,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(subtitle),

                    trailing: Text(
                      _dateFormat.format(_news.creationTime),

                      style: TextStyle(
                        fontWeight: .w800,
                        color: context.c.outline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverPadding(
            padding: const .symmetric(horizontal: 12),

            sliver: ListWidget(
              items: _news.questions,

              itemBuilder: (context, question, borderRadius) {
                return _Question(
                  question: question,
                  borderRadius: borderRadius,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  final NewsQuestion question;
  final BorderRadius borderRadius;

  const _Question({required this.question, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final hasResponse = !<NewsQuestionAnswerType>[
      .withoutResponse,
      .withoutReceiptAcknowledgment,
    ].contains(question.responseType);

    return Column(
      spacing: 3,

      children: [
        ItemWidget(
          borderRadius: hasResponse
              ? borderRadius.copyWith(
                  bottomLeft: ListWidget.defaultRadius,
                  bottomRight: ListWidget.defaultRadius,
                )
              : borderRadius,

          title: HtmlText(
            rawHtml: question.htmlText,

            style: TextStyle(color: context.c.onSurface, fontWeight: .bold),
            removeStyleAndFontSize: true,

            maxLines: 999,
          ),
        ),

        if (hasResponse) ...[
          _Answer(
            question: question,

            answerEmitted: (newAnswer) async {}, // TODO,

            borderRadius: borderRadius.copyWith(
              topLeft: ListWidget.defaultRadius,
              topRight: ListWidget.defaultRadius,
            ),
          ),
        ],
      ],
    );
  }
}

class _Answer extends StatelessWidget {
  final Future<void> Function(NewsQuestionAnswer newAnswer) answerEmitted;
  final NewsQuestion question;

  final BorderRadius borderRadius;

  const _Answer({
    required this.question,
    required this.answerEmitted,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final answer = question.answer;

    return switch (answer) {
      RANewsQuestionAnswer(answered: final answered) => ItemWidget(
        backgroundColor: context.c.surfaceContainerHigh,
        borderRadius: borderRadius,

        title: Text(
          context.l10n.raMessage,
          maxLines: 3,
          style: TextStyle(fontSize: 15, color: context.c.outline),
        ),

        trailing: Checkbox(
          value: answered,

          onChanged: (value) async {
            if (answered) return;

            await answerEmitted(answer.buildAnswered());
          },
        ),
      ),

      WithoutRANewsQuestionAnswer() => const SizedBox.shrink(),
      NoResponseNewsQuestionAnswer() => const SizedBox.shrink(),

      // TODO
      SingleChoiceNewsQuestionAnswer() => _ChoiceAnswer(question: question),

      // TODO
      MultipleChoiceNewsQuestionAnswer() => _ChoiceAnswer(question: question),

      TextualResponseNewsQuestionAnswer() => const SizedBox.shrink(), // TODO
    };
  }
}

class _ChoiceAnswer extends StatelessWidget {
  final NewsQuestion question;

  const _ChoiceAnswer({required this.question});

  ChoiceNewsQuestionAnswer get _answer {
    return question.answer as ChoiceNewsQuestionAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
      groupValue: _answer.answers.singleOrNull,
      onChanged: (value) {},

      child: Column(
        children: [
          for (final choice in question.picks)
            RadioListTile(value: choice.rank, title: Text(choice.label)),
        ],
      ),
    );
  }
}
