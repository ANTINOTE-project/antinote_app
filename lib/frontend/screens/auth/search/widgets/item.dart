import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";

class ListItemCard extends StatelessWidget {
  final VoidCallback onPressed;

  final IconData leading;
  final String label;
  final Widget trailing;

  const ListItemCard({
    super.key,
    required this.onPressed,

    required this.leading,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,

      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),

          child: Row(
            spacing: 10,

            children: [
              Icon(leading),

              Expanded(
                child: Text(
                  label.trim(),

                  maxLines: 1,
                  overflow: .ellipsis,

                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
