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
    final subtitle =
        context.l10n.recipient(_news.recipientFirstName ?? context.l10n.self) +
        (!_news.isPoll
            ? ""
            : (_news.anonymousResponse
                  ? context.l10n.anonymousPoll
                  : context.l10n.nominativePoll));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(
              _news.label,

              overflow: .ellipsis,
              maxLines: 1,

              style: const TextStyle(fontWeight: .w800),
            ),

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

              child: ItemWidget(
                borderRadius: const .all(ListWidget.radius),

                title: Text(_news.author, style: const TextStyle(fontSize: 16)),
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
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const .symmetric(horizontal: 12),

              child: Container(
                child: Column(
                  children: [
                    for (int i = 0; i < _news.questions.length; i++)
                      _Question(
                        question: _news.questions[i],
                        isFirst: i == 0,
                        isLast: i == _news.questions.length - 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  final NewsQuestion question;

  final bool isFirst;
  final bool isLast;

  const _Question({
    required this.question,
    required this.isFirst,
    required this.isLast,
  });

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

    final hasResponse = !<NewsQuestionAnswerType>[
      .withoutResponse,
      .withoutReceiptAcknowledgment,
    ].contains(question.responseType);

    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceContainerLow,
        borderRadius: borderRadius,
      ),

      padding: const .symmetric(horizontal: 12, vertical: 8),

      child: Column(
        children: [
          HtmlText(
            rawHtml: question.htmlText,
            style: TextStyle(color: context.c.onSurface, fontWeight: .w600),
          ),

          if (hasResponse) ...[
            const Divider(),

            _Answer(
              question: question,
              answerEmitted: (newAnswer) => throw UnimplementedError(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Answer extends StatefulWidget {
  const _Answer({required this.question, required this.answerEmitted});

  final NewsQuestion question;
  final Future<void> Function(NewsQuestionAnswer newAnswer) answerEmitted;

  @override
  State<_Answer> createState() => _AnswerState();
}

class _AnswerState extends State<_Answer> {
  @override
  Widget build(BuildContext context) {
    final answer = widget.question.answer;

    return switch (answer) {
      RANewsQuestionAnswer(answered: final answered) => ListTile(
        title: Text(context.l10n.raMessage),

        trailing: Checkbox(
          value: answered,

          onChanged: (value) async {
            if (answered) return;
            await widget.answerEmitted(answer.buildAnswered());
          },
        ),
      ),

      WithoutRANewsQuestionAnswer() => const SizedBox.shrink(),
      NoResponseNewsQuestionAnswer() => const SizedBox.shrink(),

      // TODO
      SingleChoiceNewsQuestionAnswer() => _ChoiceAnswer(
        question: widget.question,
      ),

      // TODO
      MultipleChoiceNewsQuestionAnswer() => _ChoiceAnswer(
        question: widget.question,
      ),

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
