enum CommunicationType {
  discussion(pageId: 131),
  news(pageId: 8);

  final int pageId;

  const CommunicationType({required this.pageId});
}

final class CommunicationFilter {
  final Set<CommunicationType> allowedTypes;

  const CommunicationFilter({required this.allowedTypes});

  static const defaultFilter = CommunicationFilter(allowedTypes: {.discussion, .news});
}
