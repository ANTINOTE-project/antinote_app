import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

Future<bool> updateHomeworkState(
  BuildContext context,
  Homework homework,
  bool target,
) async {
  if (target) {
    await HapticFeedback.lightImpact();
  } else {
    await HapticFeedback.selectionClick();
  }

  if (!context.mounted) return false;

  try {
    await context.ar.runTask(
      context: context,
      debugLabel: 'Update state for homework',

      callback: (session) async {
        final cachedHomework = session.getCachedValue<Homework>(
          .HOMEWORK,
          homework.visualId,
        );

        await session.access(
          ChangeHomeworkStateAccessor(
            homeworksToUpdate: {cachedHomework: target},
          ),
        );
      },
    );

    return true;
  } catch (_) {
    await HapticFeedback.heavyImpact();

    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.homeworkUpdateFailed),
          behavior: .floating,
        ),
      );
    }

    return false;
  }
}
