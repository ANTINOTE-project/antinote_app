import 'package:antinote_api/antinote_api.dart';

enum HomeworkUrgency { none, tomorrow, overdue }

extension HomeworkUrgencyX on Homework {
  HomeworkUrgency get urgency {
    if (isDone) return .none;

    final today = DateTime.now().copyWith(isUtc: true).toDay();
    final tomorrow = today.add(const Duration(days: 1)).toDay();

    if (deadlineDate.isBefore(today)) return .overdue;
    if (deadlineDate.isAtSameMomentAs(tomorrow)) return .tomorrow;
    return .none;
  }
}
