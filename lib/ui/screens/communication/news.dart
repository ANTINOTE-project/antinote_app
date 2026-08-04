import 'package:antinote/antinote.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/attachment.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/remote_html.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({
    super.key,
    required this.mode,
    required this.news,
    required this.deleteNews,
  });

  final NewsDisplayMode mode;

  final ValueNotifier<News> news;
  final VoidCallback deleteNews;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with PageMixin<NewsScreen>, TabMixin<NewsScreen> {
  final Map<String, NewsQuestionAnswer> _overriddenAnswers = {};

  Future<void> _sendCompleted() async {
    throw UnimplementedError();
  }

  Future<void> _toggleReadStatus() async {
    throw UnimplementedError();
  }

  Future<void> _delete() async {
    throw UnimplementedError();
  }

  News get _news => widget.news.value;

  late List<NewsQuestion> questions;

  static final _dateFormat = DateFormat(DateFormat.MONTH_WEEKDAY_DAY);

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    final String pollSuffix = !_news.isPoll
        ? ''
        : ' (${_news.anonymousResponse ? context.l10n.anonymousPoll : context.l10n.nominativePoll})';

    final subtitle =
        '${context.l10n.recipient(_news.recipientFirstName ?? context.l10n.self)}$pollSuffix';

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
              items: questions,

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

  @override
  Set<String> get loadChannels =>
      _news.questions == null ? {'communication'} : {};

  @override
  Future<void> load(RemoteSession session) async {
    if (_news.questions != null) {
      questions = _news.questions!;
      return;
    }

    questions =
        _news.questions ??
        (await session.access(
          NewsContentAccessor(mode: widget.mode, baseNews: _news),
        )).questions;
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
          borderRadius: hasResponse || question.attachments.isNotEmpty
              ? borderRadius.copyWith(
                  bottomLeft: ListWidget.defaultRadius,
                  bottomRight: ListWidget.defaultRadius,
                )
              : borderRadius,
          title: RemoteHtml(
            rawHtml: question.htmlText,
            style: TextStyle(color: context.c.onSurface, fontWeight: .normal),

            // style: TextStyle(color: context.c.onSurface, fontWeight: .bold),
            // removeStyleAndFontSize: true,

            // maxLines: 999,
          ),
        ),

        ListWidget(
          items: question.attachments,
          shrinkWrap: true,
          isColumn: true,
          isSliver: false,
          gotBefore: true,
          gotAfter: hasResponse,
          itemBuilder: (context, attachment, borderRadius) {
            return AttachmentItemWidget(
              attachment: attachment,
              borderRadius: borderRadius,
              backgroundColor: context.c.surfaceContainer,
            );
          },
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
      RANewsQuestionAnswer(withAnswer: final answered) => ItemWidget(
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

      // TODO
      TextualResponseNewsQuestionAnswer() => const SizedBox.shrink(),
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

      child: ListWidget(
        items: question.picks,

        isSliver: false,
        isColumn: true,

        itemBuilder: (context, choice, borderRadius) {
          final selected = _answer.answers.contains(choice.rank);

          return ItemWidget(
            backgroundColor: selected
                ? context.c.primaryContainer
                : context.c.surfaceContainerHigh,

            borderRadius: choice == question.picks.first
                ? borderRadius.copyWith(
                    topLeft: ListWidget.defaultRadius,
                    topRight: ListWidget.defaultRadius,
                  )
                : borderRadius,

            title: Text(
              choice.label,
              maxLines: 999,
              style: const TextStyle(fontSize: 15),
            ),

            leading: SizedBox(
              width: 24,
              height: 24,

              child: Radio<int>(
                value: choice.rank,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        },
      ),
    );
  }
}
