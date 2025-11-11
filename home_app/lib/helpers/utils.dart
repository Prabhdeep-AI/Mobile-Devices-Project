import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';

List<int> last7DaysCompletionCounts(List<Habit> habits) {
  final now = DateTime.now();
  final days = List.generate(
      7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
  return days
      .map((d) => habits.where((h) => h.completions.contains(AppState.dayKey(d))).length)
      .toList();
}

String dateShort(DateTime d) => '${d.year}/${d.month}/${d.day}';


