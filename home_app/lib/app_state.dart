import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  // -------------------------------
  // DATA
  // -------------------------------
  List<Goal> goals = [];
  List<Habit> habits = [];
  List<String> reminders = [];



  // -------------------------------
  // THEME / BACKGROUND
  // -------------------------------
  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;

  String backgroundKey = 'default';
  bool darkMode = false;

  // -------------------------------
  // SELECTED DATE
  // -------------------------------
  DateTime selectedDate = DateTime.now();

  // -------------------------------
  // INITIAL LOAD
  // -------------------------------
  Future<void> loadFromDatabase() async {
    goals = await DBHelper.getGoals();
    habits = await DBHelper.getHabits();
    reminders = await DBHelper.getReminders();
    _backgroundColor = await DBHelper.getBackgroundColor() ?? Colors.white;
    notifyListeners();
  }

  // -------------------------------
  // THEME METHODS
  // -------------------------------
  Future<void> updateBackgroundColor(Color color, {String? key}) async {
    _backgroundColor = color;
    if (key != null) backgroundKey = key;
    await DBHelper.saveBackgroundColor(color);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }

  void setBackground(String key) {
    backgroundKey = key;
    final color = backgroundOptions
        .firstWhere((o) => o.key == key, orElse: () => backgroundOptions.first)
        .color;
    updateBackgroundColor(color, key: key);
  }

  // -------------------------------
  // GOALS METHODS
  // -------------------------------
  Future<void> addGoal(String title, {DateTime? due}) async {
    final goal = Goal(title: title, dueDate: due);
    await DBHelper.insertGoal(goal);
    goals.add(goal);
    notifyListeners();
  }

  Future<void> toggleGoal(String id) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final updated = goals[index].copyWith(done: !goals[index].done);
      goals[index] = updated;
      await DBHelper.updateGoal(updated);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    await DBHelper.deleteGoal(id);
    goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // -------------------------------
  // HABITS METHODS
  // -------------------------------
  Future<void> addHabit(String title) async {
    final habit = Habit(title: title);
    await DBHelper.insertHabit(habit);
    habits.add(habit);
    notifyListeners();
  }

  Future<void> toggleHabit(int index, DateTime day) async {
    final habit = habits[index];
    final key = dayKey(day);
    final completions = Set<String>.from(habit.completions);
    if (completions.contains(key)) {
      completions.remove(key);
    } else {
      completions.add(key);
    }

    final updated = habit.copyWith(
      completions: completions,
      streak: DBHelper.calculateStreak(completions),
    );
    habits[index] = updated;
    await DBHelper.updateHabit(updated);
    notifyListeners();
  }

  Future<void> resetHabit(int index) async {
    final habit = habits[index];
    final updated = habit.copyWith(completions: {}, streak: 0);
    habits[index] = updated;
    await DBHelper.updateHabit(updated);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await DBHelper.deleteHabit(id);
    habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  // -------------------------------
  // REMINDERS METHODS
  // -------------------------------
  Future<void> addReminder(TimeOfDay time) async {
    final str =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (!reminders.contains(str)) {
      reminders.add(str);
      await DBHelper.addReminder(str);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String time) async {
    reminders.remove(time);
    await DBHelper.removeReminder(time);
    notifyListeners();
  }

  // -------------------------------
  // UTILITIES
  // -------------------------------
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  static List<BackgroundOption> backgroundOptions = [
    BackgroundOption(
        key: 'default', name: 'Blue', color: Colors.blue, icon: Icons.circle),
    BackgroundOption(
        key: 'green', name: 'Green', color: Colors.green, icon: Icons.circle),
    BackgroundOption(
        key: 'pink', name: 'Pink', color: Colors.pink, icon: Icons.circle),
  ];
}

class BackgroundOption {
  final String key;
  final String name;
  final Color color;
  final IconData icon;

  const BackgroundOption({
    required this.key,
    required this.name,
    required this.color,
    required this.icon,
  });
}






