// lib/helpers/utils.dart
import '../models.dart';

class Utils {
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';

  static bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  static String dateShort(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }
}

// Returns completion counts for last 7 days
List<int> last7DaysCompletionCounts(List<Habit> habits) {
  final now = DateTime.now();
  final days = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i)));
  return days
      .map((d) => habits.where((h) => h.completions.contains(Utils.dayKey(d))).length)
      .toList();
}

