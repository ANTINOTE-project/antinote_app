enum CommunicationType {
  discussion(pageId: 131),
  news(pageId: 8);

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

final class CommunicationThreadPreview {
  final String title;
  final DateTime publishDate;
  final CommunicationType commType;
  final String authorName;
  final String visualId;

  final bool read;

  const CommunicationThreadPreview({
    required this.title,
    required this.publishDate,
    required this.commType,
    required this.authorName,
    required this.visualId,
    required this.read,
  });
}
