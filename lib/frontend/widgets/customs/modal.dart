import "package:antinote_app/frontend/app.dart";
import "package:flutter/material.dart";

class Modal {
  Modal._();

  static Future<T?> show<T>(String title, Widget child) async {
    final state = App.navigatorKey.currentState;
    if (state == null) return null;

    return await showModalBottomSheet<T>(
      context: state.context,
      isScrollControlled: true,

      builder: (_) => _Modal(title: title, child: child),
    );
  }
}

class _Modal extends StatelessWidget {
  final String title;
  final Widget child;

  const _Modal({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.viewInsetsOf(context),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,

            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
