// lib/app_state.dart
import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models.dart';
import 'notifications.dart';
import 'helpers/utils.dart';

class AppState extends ChangeNotifier {
  // -------------------------------
  // DATA
  // -------------------------------
  List<Goal> goals = [];
  List<Habit> habits = [];
  List<Map<String, String>> reminders = []; // {'time': 'HH:mm', 'name': 'Reminder Name'}

  // -------------------------------
  // THEME / BACKGROUND
  // -------------------------------
  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;

  String backgroundKey = 'white';
  bool darkMode = false;

  // -------------------------------
  // SELECTED DATE
  // -------------------------------
  DateTime selectedDate = DateTime.now();

  // -------------------------------
  // PROFILE NAME
  // -------------------------------
  String profileName = 'My Profile';

  // -------------------------------
  // INITIAL LOAD
  // -------------------------------
  Future<void> loadFromDatabase() async {
    goals = await DBHelper.getGoals();
    habits = await DBHelper.getHabits();
    reminders = await DBHelper.getReminders();

    // Schedule all saved reminders
    for (var r in reminders) {
      final parts = r['time']!.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      await NotificationService.scheduleDailyNotification(
        id: '${r['time']}-${r['name']}'.hashCode,
        title: 'Reminder: ${r['name']}',
        body: 'It\'s time for your habit/goal!',
        hour: hour,
        minute: minute,
      );
    }

    // Reset today’s habit marks to uncross if necessary
    _resetHabitsForNewDay();

    // Clean up old goals
    _removeCompletedGoalsOfYesterday();

    // Load background color
    final savedColor = await DBHelper.getBackgroundColor();
    if (savedColor != null) {
      _backgroundColor = savedColor;
      for (var opt in backgroundOptions) {
        if (opt.color.value == savedColor.value) backgroundKey = opt.key;
      }
    }

    // Load profile name
    final savedProfile = await DBHelper.getProfileName();
    if (savedProfile != null) profileName = savedProfile;

    notifyListeners();
  }

  

   void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners(); // works because AppState extends ChangeNotifier
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
  // PROFILE METHODS (added)
  // -------------------------------
  Future<void> setProfileName(String name) async {
  profileName = name; // ✅ use the existing variable
  await DBHelper.saveProfileName(name);
  notifyListeners();
}

  // -------------------------------
  // RESET ALL (added)
  // -------------------------------
  Future<void> resetAll() async {
    // wipe DB
    await DBHelper.clearAllData();

    // clear in-memory
    goals.clear();
    habits.clear();
    reminders.clear();

    // reset profileName and persist
    profileName = 'My Profile';
    await DBHelper.saveProfileName(profileName);

    // reset background to default white
    await updateBackgroundColor(Colors.white, key: 'white');

    notifyListeners();
  }

  // -------------------------------
  // GOALS METHODS
  // -------------------------------
  Future<void> addGoal(String title, {DateTime? due}) async {
    final goal = Goal(title: title, dueDate: due);
    await DBHelper.insertGoal(goal);
    goals.add(goal);
    notifyListeners();

    NotificationService.showNotification(
      title: "New Goal Added",
      body: title,
    );
  }

  Future<void> toggleGoal(String id) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final updated = goals[index].copyWith(done: !goals[index].done);
      goals[index] = updated;
      await DBHelper.updateGoal(updated);
      notifyListeners();

      NotificationService.showNotification(
        title: updated.done ? "Goal Completed!" : "Goal Updated",
        body: updated.title,
      );
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

    NotificationService.showNotification(
      title: "New Habit Added",
      body: title,
    );
  }

  Future<void> toggleHabit(int index, DateTime day) async {
    final habit = habits[index];
    final key = Utils.dayKey(day);
    final completions = Set<String>.from(habit.completions);

    if (completions.contains(key)) {
      completions.remove(key);
    } else {
      completions.add(key);
    }

    final updated = habit.copyWith(
      completions: completions,
      streak: _calculateStreak(completions),
    );

    habits[index] = updated;
    await DBHelper.updateHabit(updated);
    notifyListeners();

    NotificationService.showNotification(
      title: completions.contains(key) ? "Habit Done!" : "Habit Unchecked",
      body: habit.title,
    );
  }

  // helper used by some pages that pass habit object
  Future<void> toggleHabitCompletion(Habit habit) async {
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      await toggleHabit(index, DateTime.now());
    }
  }

  Future<void> resetHabit(int index) async {
    final updated = habits[index].copyWith(completions: {}, streak: 0);
    habits[index] = updated;
    await DBHelper.updateHabit(updated);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await DBHelper.deleteHabit(id);
    habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  void _resetHabitsForNewDay() {
    final todayKey = Utils.dayKey(DateTime.now());
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      final newCompletions = Set<String>.from(habit.completions);
      // Only remove today's mark
      if (newCompletions.contains(todayKey)) newCompletions.remove(todayKey);
      habits[i] = habit.copyWith(
        completions: newCompletions,
        streak: _calculateStreak(newCompletions),
      );
    }
  }

  int _calculateStreak(Set<String> completions) {
    if (completions.isEmpty) return 0;
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      final key = Utils.dayKey(day);
      if (completions.contains(key)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  void _removeCompletedGoalsOfYesterday() {
    final todayKey = Utils.dayKey(DateTime.now());
    goals.removeWhere((g) {
      if (g.done && Utils.dayKey(g.createdAt) != todayKey) {
        DBHelper.deleteGoal(g.id);
        return true;
      }
      return false;
    });
  }

  // -------------------------------
  // REMINDERS METHODS
  // -------------------------------
  Future<void> addReminder(TimeOfDay time, String name) async {
    final timeStr =
        '${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}';

    if (!reminders.any((r) => r['time'] == timeStr && r['name'] == name)) {
      final reminder = {'time': timeStr, 'name': name};
      reminders.add(reminder);
      await DBHelper.addReminder(reminder);
      notifyListeners();

      await NotificationService.scheduleDailyNotification(
        id: '$timeStr-$name'.hashCode,
        title: 'Reminder: $name',
        body: 'It\'s time for your habit/goal!',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> deleteReminder(String time, [String? name]) async {
    final r = reminders.firstWhere(
      (r) => r['time'] == time && (name == null || r['name'] == name),
      orElse: () => {},
    );
    if (r.isNotEmpty) {
      reminders.remove(r);
      await DBHelper.removeReminder(r['time']! + '|' + r['name']!);
      notifyListeners();

      await NotificationService.cancelNotification('${r['time']}-${r['name']}'.hashCode);
    }
  }

  // -------------------------------
  // UTILITIES
  // -------------------------------
  static String dayKey(DateTime d) => Utils.dayKey(d);

  // -------------------------------
  // BACKGROUND OPTIONS
  // -------------------------------
  static List<BackgroundOption> backgroundOptions = [
    BackgroundOption(key: 'white', name: 'White', color: Colors.white, icon: Icons.circle),
    BackgroundOption(key: 'lightgrey', name: 'Light Grey', color: Color(0xFFF2F2F2), icon: Icons.circle),
    BackgroundOption(key: 'cream', name: 'Cream', color: Color(0xFFFFF4DD), icon: Icons.circle),
    BackgroundOption(key: 'lightblue', name: 'Light Blue', color: Color(0xFFD9ECFF), icon: Icons.circle),
    BackgroundOption(key: 'blue', name: 'Blue', color: Colors.blue, icon: Icons.circle),
    BackgroundOption(key: 'green', name: 'Green', color: Colors.green, icon: Icons.circle),
    BackgroundOption(key: 'pink', name: 'Pink', color: Colors.pink, icon: Icons.circle),
    BackgroundOption(key: 'purple', name: 'Purple', color: Colors.deepPurple, icon: Icons.circle),
    BackgroundOption(key: 'black', name: 'Black', color: Colors.black, icon: Icons.circle),
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



























