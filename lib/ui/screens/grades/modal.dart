part of 'grades_tab.dart';

Future<void> _showDetails({
  required BuildContext context,
  required String name,
  required int? serviceColor,
  required List<_DetailsItem> items,
  String? title,
  String? subtitle,
}) async {
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final scheme = Utils.buildColorScheme(context, serviceColor ?? 0);

      return Container(
        padding: const .fromLTRB(12, 0, 12, 20),
        width: double.infinity,

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            spacing: 16,

            children: [
              Column(
                mainAxisAlignment: .center,
                spacing: 8,

                children: [
                  Padding(
                    padding: const .symmetric(horizontal: 12),
                    child: Text(
                      name,
                      textAlign: .center,
                      style: context.tt.headlineSmall?.copyWith(
                        fontWeight: .w800,
                        height: 1,
                      ),
                    ),
                  ),

                  if (title != null)
                    Padding(
                      padding: const .symmetric(horizontal: 25),
                      child: Text(
                        title,
                        textAlign: .center,
                        style: context.tt.bodyLarge?.copyWith(
                          fontWeight: .w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                ],
              ),

              Flexible(
                child: ListWidget(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  isSliver: false,
                  items: items,

                  itemBuilder: (context, item, borderRadius) {
                    return TileWidget(
                      backgroundColor: scheme.primaryContainer,
                      borderRadius: borderRadius,

                      leading: Icon(
                        item.icon,
                        color: scheme.onPrimaryContainer,
                      ),

                      title: Text(
                        item.label,
                        style: TextStyle(color: scheme.onSurface),
                      ),

                      trailing: item.coefficient != null
                          ? Text(
                              '×${Formatters.formatNumber(item.coefficient)}',
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 17,
                                fontWeight: .w800,
                              ),
                            )
                          : item.grade != null &&
                                item.theoreticalMaxGrade != null
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
                  },
                ),
              ),

              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.c.onSurface,
                    fontWeight: .bold,
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
