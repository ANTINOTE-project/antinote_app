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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        width: double.infinity,

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Column(
                mainAxisAlignment: .center,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),

                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
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
                      borderRadius: borderRadius,
                      backgroundColor: scheme.primaryContainer,
                      leading: Icon(
                        item.icon,
                        color: scheme.onPrimaryContainer,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 18,
                          fontWeight: .bold,
                        ),
                      ),

                      trailing: item.coefficient != null
                          ? Text(
                              '×${Formatters.formatNumber(item.coefficient)}',
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : item.grade != null &&
                                item.theoreticalMaxGrade != null
                          ? GradeText(
                              selfGrade: item.grade!,
                              maxGrade: item.theoreticalMaxGrade!,
                              defaultMaxGrade: item.defaultMaxGrade!,
                              color: scheme.primary,
                              size: 20,
                            )
                          : item.rawValue != null
                          ? Text(
                              item.rawValue!,
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
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
