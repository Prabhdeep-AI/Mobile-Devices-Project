import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'db_helper.dart';
import 'notifications.dart';

class AppState extends ChangeNotifier {
  final List<Goal> goals = [];
  final List<Habit> habits = [];
  final List<String> reminderTimes = [];
  bool darkMode = false;

  static const _kDark = 'dark';

  // Public dayKey
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    darkMode = sp.getBool(_kDark) ?? false;

    goals
      ..clear()
      ..addAll(await DBHelper.getGoals());

    habits
      ..clear()
      ..addAll(await DBHelper.getHabits());

    reminderTimes
      ..clear()
      ..addAll(await DBHelper.getReminders());

    for (var hhmm in reminderTimes) {
      final parts = hhmm.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      await NotificationService.scheduleDaily(time: time, id: hhmm.hashCode);
    }

    notifyListeners();
  }

  void addGoal(String title, {DateTime? due}) {
    final g = Goal(title: title, dueDate: due);
    goals.add(g);
    DBHelper.insertGoal(g);
    notifyListeners();
  }

  void toggleGoal(int index) {
    final g = goals[index];
    final updated = g.copyWith(done: !g.done);
    goals[index] = updated;
    DBHelper.insertGoal(updated);
    notifyListeners();
  }

  void removeGoal(int index) {
    DBHelper.deleteGoal(goals[index].id!);
    goals.removeAt(index);
    notifyListeners();
  }

  void addHabit(String title) {
    final h = Habit(title: title);
    habits.add(h);
    DBHelper.insertHabit(h);
    notifyListeners();
  }

  void toggleHabitForDay(int index, DateTime day) {
    final h = habits[index];
    final key = dayKey(day);
    final newCompletions = Set<String>.from(h.completions);
    if (newCompletions.contains(key)) newCompletions.remove(key);
    else newCompletions.add(key);

    final updated = h.copyWith(
      completions: newCompletions,
      streak: DBHelper.calculateStreak(newCompletions),
    );

    habits[index] = updated;
    DBHelper.insertHabit(updated);
    notifyListeners();
  }

  void resetHabit(int index) {
    final h = habits[index];
    final updated = h.copyWith(completions: {}, streak: 0);
    habits[index] = updated;
    DBHelper.insertHabit(updated);
    notifyListeners();
  }

  void addReminder(TimeOfDay t) {
    final s = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (!reminderTimes.contains(s)) {
      reminderTimes.add(s);
      DBHelper.addReminder(s);
      NotificationService.scheduleDaily(time: t, id: s.hashCode);
      notifyListeners();
    }
  }

  void removeReminder(String s) {
    reminderTimes.remove(s);
    DBHelper.removeReminder(s);
    NotificationService.cancel(s.hashCode);
    notifyListeners();
  }

  void setDark(bool value) {
    darkMode = value;
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDark, darkMode);
  }
}







