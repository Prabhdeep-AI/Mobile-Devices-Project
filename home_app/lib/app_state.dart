
/// ============================================================
/// Persistent App State (SharedPreferences)
/// ============================================================
class AppState extends ChangeNotifier {
  AppState();

  final List<Goal> goals = [];
  final List<Habit> habits = [];
  bool darkMode = false;
  final List<String> reminderTimes = []; // HH:MM 24h strings

  static const _kGoals = 'goals';
  static const _kHabits = 'habits';
  static const _kDark = 'dark';
  static const _kReminders = 'reminders';

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

    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDark, darkMode);
  }

  // ---------- Goals API ----------
  void addGoal(String title, {DateTime? due}) {
    final goal = Goal(title: title, dueDate: due);
    goals.add(goal);
    DBHelper.insertGoal(goal);
    _persist();
  }

  void toggleGoal(int index) {

    final g = goals[index];
    final updated = g.copyWith(done: !g.done);
    goals[index] = updated;
    DBHelper.insertGoal(updated);
    _persist();
  }

  void removeGoal(int index) {
    DBHelper.deleteGoal(goals[index].id);
    goals.removeAt(index);
    _persist();
  }

  // ---------- Habits API ----------
  void addHabit(String title) {
    habits.add(Habit(title: title));
    _persist();
  }

  void toggleHabitForDay(int index, DateTime day) {
    final key = _dayKey(day);
    final h = habits[index];
    final set = {...h.completions};
    if (set.contains(key)) {
      set.remove(key);
    } else {
      set.add(key);
    }
    final newStreak = _computeStreakFromCompletions(set);
    habits[index] = h.copyWith(completions: set, streak: newStreak);
    _persist();
  }

  void resetHabit(int index) {
    final h = habits[index];
    habits[index] = h.copyWith(completions: {}, streak: 0);
    _persist();
  }

  // ---------- Reminders + Theme ----------
  void setDark(bool v) {
    darkMode = v;
    _persist();
  }

  void addReminder(TimeOfDay t) {
    final s = _formatTimeOfDay(t);
    if(!reminderTimes.contains(s)){
      reminderTimes.add(s);
      DBHelper.addReminder(s);
      _persist();
    }
  }

  void removeReminder(String hhmm) {
    reminderTimes.remove(hhmm);
    DBHelper.removeReminder(hhmm);
    _persist();
  }

  // ---------- Helpers ----------
  void _persist() {
    notifyListeners();
    // fire-and-forget; no need to await
    _save();
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  static int _computeStreakFromCompletions(Set<String> dates) {
    // Count consecutive days backwards starting today
    int streak = 0;
    DateTime day = DateTime.now();
    while (dates.contains(_dayKey(day))) {
      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}