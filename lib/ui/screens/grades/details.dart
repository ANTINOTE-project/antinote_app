part of 'grades_tab.dart';

class _DetailsScreen extends StatelessWidget {
  final int? serviceColor;
  final List<_DetailsItem> items;
  final String? title;
  final String? subtitle;
  final List<Exam>? exams;

  const _DetailsScreen({
    this.serviceColor,
    this.items = const [],
    this.title,
    this.subtitle,
    this.exams,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Utils.buildColorScheme(context, serviceColor ?? 0);

    final orderedExams = exams != null
        ? (List<Exam>.from(exams!)..sort((a, b) => b.date.compareTo(a.date)))
        : null;

    return Scaffold(
      appBar: AppBarWidget(
        title: title != null ? Text(title!) : null,
        subtitle: subtitle != null ? Text(subtitle!) : null,
      ),

      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),

        slivers: [
          SliverPadding(
            padding: const .symmetric(horizontal: 12),

            sliver: SliverMainAxisGroup(
              slivers: [
                ListWidget(
                  items: items,

                  itemBuilder: (context, item, borderRadius) {
                    return _DetailsTile(
                      item: item,
                      scheme: scheme,
                      borderRadius: borderRadius,
                    );
                  },
                ),

                if (orderedExams != null && orderedExams.isNotEmpty) ...[
                  const SliverPadding(padding: .only(top: 20)),

                  TextIcon.sliver(label: context.l10n.detailsAllExams),

                  SliverPrototypeExtentList(
                    prototypeItem: _ExamWidget.prototype,

                    delegate: SliverChildBuilderDelegate(
                      childCount: orderedExams.length,

                      (context, index) {
                        return _ExamWidget(exam: orderedExams[index]);
                      },
                    ),
                  ),
                ],

                const BottomPadding(padding: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsTile extends StatelessWidget {
  final _DetailsItem item;
  final ColorScheme scheme;
  final BorderRadius borderRadius;

  const _DetailsTile({
    required this.item,
    required this.scheme,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TileWidget(
      backgroundColor: scheme.primaryContainer,
      borderRadius: borderRadius,

      leading: Icon(item.icon, color: scheme.onPrimaryContainer),
      title: Text(item.label, style: TextStyle(color: scheme.onSurface)),

      trailing: item.coefficient != null
          ? Text(
              '×${Formatters.formatNumber(item.coefficient)}',
              style: TextStyle(
                color: scheme.primary,
                fontSize: 17,
                fontWeight: .w800,
              ),
            )
          : item.grade != null && item.theoreticalMaxGrade != null
          ? GradeText(
              selfGrade: item.grade!,
              maxGrade: item.theoreticalMaxGrade!,
              defaultMaxGrade: item.defaultMaxGrade!,
              color: scheme.primary,
              size: 17,
            )
          : item.rawValue != null
          ? Text(
              item.rawValue!,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 17,
                fontWeight: .w800,
              ),
            )
          : null,
    );
  }
}
