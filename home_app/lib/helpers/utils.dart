import 'package:flutter/material.dart';
import '../models.dart'; // Habit model

// Centralized static utility class for date/day operations.
class Utils {
  // Global helper for day string keys (YYYYMMDD) - Used for Habit completions storage.
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}'
          '${d.month.toString().padLeft(2, '0')}'
          '${d.day.toString().padLeft(2, '0')}';

  // Helper to check if a date is today.
  static bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  // FIX: Added zero-padding for month and day for consistent display date formatting (YYYY-MM-DD).
  static String dateShort(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}

// Keep last7DaysCompletionCounts top-level as it was, and update it to use Utils.dayKey.
List<int> last7DaysCompletionCounts(List<Habit> habits) {
  final now = DateTime.now();
  final days = List.generate(
      7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
  return days
      // CHANGE: Use Utils.dayKey instead of the old AppState.dayKey
      .map((d) => habits.where((h) => h.completions.contains(Utils.dayKey(d))).length)
      .toList();
}