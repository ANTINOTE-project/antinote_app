import 'package:antinote_api/antinote_api.dart';

enum CommunicationType {
  discussion(pageId: DiscussionPageAccessor.pageId),
  news(pageId: NewsPageAccessor.pageId),
  poll(pageId: NewsPageAccessor.pageId);

  final int pageId;

  const CommunicationType({required this.pageId});
}

final class CommunicationFilter {
  final Set<CommunicationType> allowedTypes;

  const CommunicationFilter({required this.allowedTypes});

  static const defaultFilter = CommunicationFilter(
    allowedTypes: {.discussion, .news},
  );
}

sealed class CommunicationThreadPreview({
  required final String? title,
  required final String? category,
  required final DateTime publishDate,
  required final CommunicationType commType,
  required final String authorName,
  required final String visualId,

  required final bool read,
  required final bool hasAttachment,
});

final class InformationThreadPreview({
  required super.title,
  required super.category,
  required super.publishDate,
  required super.commType,
  required super.authorName,
  required super.visualId,

  required super.read,
  required super.hasAttachment,

  required final NewsDisplayMode mode,
}) extends CommunicationThreadPreview;

final class DiscussionThreadPreview({
  required super.title,
  required super.category,
  required super.publishDate,
  required super.commType,
  required super.authorName,
  required super.visualId,

  required super.read,
  required super.hasAttachment,
}) extends CommunicationThreadPreview;
