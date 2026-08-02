import 'package:antinote/antinote.dart';

enum CommunicationType {
  discussion(pageId: 131),
  news(pageId: 8),
  poll(pageId: 8);

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
  required final String title,
  required final DateTime publishDate,
  required final CommunicationType commType,
  required final String authorName,
  required final String visualId,

  required final bool read,
});

final class InformationThreadPreview({
  required super.title,
  required super.publishDate,
  required super.commType,
  required super.authorName,
  required super.visualId,

  required super.read,

  required final NewsDisplayMode mode,
}) extends CommunicationThreadPreview;

final class DiscussionThreadPreview({
  required super.title,
  required super.publishDate,
  required super.commType,
  required super.authorName,
  required super.visualId,

  required super.read,
}) extends CommunicationThreadPreview;
