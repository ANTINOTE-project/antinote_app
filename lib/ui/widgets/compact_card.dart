import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:material_ui/material_ui.dart';

class CompactCard extends StatelessWidget {
  final ColorScheme scheme;

  final String title;
  final Widget subtitle;
  final Widget? trailing;

  const CompactCard({
    super.key,
    required this.scheme,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: .circular(16),

      child: Ink(
        decoration: BoxDecoration(
          border: .all(color: scheme.inversePrimary),
          borderRadius: .circular(16),
          color: scheme.primaryContainer,
        ),

        padding: const .symmetric(vertical: 6, horizontal: 12),

        child: Row(
          spacing: 10,

          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 2,

                children: [
                  Text(
                    title,
                    overflow: .ellipsis,
                    maxLines: 1,

                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: .w800,
                      fontSize: 16,
                    ),
                  ),

                  subtitle,
                ],
              ),
            ),

            ?trailing,
          ],
        ),
      ),
    );
  }
}
