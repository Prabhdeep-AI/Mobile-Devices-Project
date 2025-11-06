import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const LifeGoalsApp());

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

    final gRaw = sp.getStringList(_kGoals) ?? [];
    final hRaw = sp.getStringList(_kHabits) ?? [];
    final rRaw = sp.getStringList(_kReminders) ?? [];

    goals
      ..clear()
      ..addAll(gRaw.map((e) => Goal.fromJson(jsonDecode(e))));
    habits
      ..clear()
      ..addAll(hRaw.map((e) => Habit.fromJson(jsonDecode(e))));
    reminderTimes
      ..clear()
      ..addAll(rRaw);

    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDark, darkMode);
    await sp.setStringList(
      _kGoals,
      goals.map((g) => jsonEncode(g.toJson())).toList(),
    );
    await sp.setStringList(
      _kHabits,
      habits.map((h) => jsonEncode(h.toJson())).toList(),
    );
    await sp.setStringList(_kReminders, reminderTimes);
  }

  // ---------- Goals API ----------
  void addGoal(String title, {DateTime? due}) {
    goals.add(Goal(title: title, dueDate: due));
    _persist();
  }

  void toggleGoal(int index) {
    goals[index] = goals[index].copyWith(done: !goals[index].done);
    _persist();
  }

  void removeGoal(int index) {
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
    if (!reminderTimes.contains(s)) {
      reminderTimes.add(s);
      _persist();
    }
  }

  void removeReminder(String hhmm) {
    reminderTimes.remove(hhmm);
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

// =============================================================
// Data Models
// =============================================================
class Goal {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;
  final DateTime? dueDate;

  Goal({
    required this.title,
    this.done = false,
    String? id,
    DateTime? createdAt,
    this.dueDate,
  })  : id = id ?? UniqueKey().toString(),
        createdAt = createdAt ?? DateTime.now();

  Goal copyWith({String? title, bool? done, DateTime? dueDate}) => Goal(
        id: id,
        title: title ?? this.title,
        done: done ?? this.done,
        createdAt: createdAt,
        dueDate: dueDate ?? this.dueDate,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
      };

  static Goal fromJson(Map<String, dynamic> m) => Goal(
        id: m['id'] as String,
        title: m['title'] as String,
        done: m['done'] as bool,
        createdAt: DateTime.parse(m['createdAt'] as String),
        dueDate:
            m['dueDate'] == null ? null : DateTime.parse(m['dueDate'] as String),
      );
}

class Habit {
  final String id;
  final String title;
  final int streak;
  final Set<String> completions; // yyyyMMdd

  Habit({
    required this.title,
    this.streak = 0,
    Set<String>? completions,
    String? id,
  })  : id = id ?? UniqueKey().toString(),
        completions = completions ?? <String>{};

  Habit copyWith({String? title, int? streak, Set<String>? completions}) =>
      Habit(
        id: id,
        title: title ?? this.title,
        streak: streak ?? this.streak,
        completions: completions ?? this.completions,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'streak': streak,
        'completions': completions.toList(),
      };

  static Habit fromJson(Map<String, dynamic> m) => Habit(
        id: m['id'] as String,
        title: m['title'] as String,
        streak: m['streak'] as int,
        completions: (m['completions'] as List).map((e) => e as String).toSet(),
      );
}

/// A simple inherited notifier to share [AppState] without external packages.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState notifier, required Widget child})
      : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}

// =============================================================
// App Root
// =============================================================
class LifeGoalsApp extends StatefulWidget {
  const LifeGoalsApp({super.key});

  @override
  State<LifeGoalsApp> createState() => _LifeGoalsAppState();
}

class _LifeGoalsAppState extends State<LifeGoalsApp> {
  final appState = AppState();
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = appState.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: appState,
          builder: (context, __) {
            final scheme = ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: appState.darkMode ? Brightness.dark : Brightness.light,
            );
            return AppStateScope(
              notifier: appState,
              child: MaterialApp(
                title: 'Life Goals',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(colorScheme: scheme, useMaterial3: true),
                home: const LifeGoalsHome(),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================
// Home
// =============================================================
class LifeGoalsHome extends StatefulWidget {
  const LifeGoalsHome({super.key});

  @override
  State<LifeGoalsHome> createState() => _LifeGoalsHomeState();
}

class _LifeGoalsHomeState extends State<LifeGoalsHome> {
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            tooltip: 'Reminders',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersPage())),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: _ProfileHeader(date: selectedDay),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _DateScroller(
            initial: selectedDay,
            onSelect: (d) => setState(() => selectedDay = d),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    label: 'Goals',
                    icon: Icons.flag,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    label: 'Habits',
                    icon: Icons.repeat,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HabitsPage(day: selectedDay))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedBuilder(
                animation: state,
                builder: (_, __) {
                  final completed = state.goals.where((g) => g.done).length;
                  final total = state.goals.length;
                  final todayDone = state.habits
                      .where((h) => h.completions.contains(AppState._dayKey(selectedDay)))
                      .length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatCard(
                        title: 'Today',
                        lines: [
                          '$completed / $total goals completed',
                          '$todayDone habits checked in',
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Last 7 days'),
                      const SizedBox(height: 6),
                      _Sparkline(habits: state.habits),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())),
              child: const Text('My Goals'),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HabitsPage(day: selectedDay))),
              child: const Text('My Habits'),
            ),
            const SizedBox(width: 40),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressPage())),
              child: const Text('Progress'),
            ),
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'Quick Add',
              onPressed: () => _showQuickAdd(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.home),
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final DateTime date;
  const _ProfileHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final dStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Column(
        children: [
          const CircleAvatar(radius: 24, child: Icon(Icons.person)),
          const SizedBox(height: 6),
          Text('My Profile', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(dStr, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _DateScroller extends StatefulWidget {
  final DateTime initial;
  final ValueChanged<DateTime> onSelect;
  const _DateScroller({required this.initial, required this.onSelect});

  @override
  State<_DateScroller> createState() => _DateScrollerState();
}

class _DateScrollerState extends State<_DateScroller> {
  late DateTime start;
  DateTime? selected;

  @override
  void initState() {
    super.initState();
    final today = DateTime(widget.initial.year, widget.initial.month, widget.initial.day);
    start = today.subtract(Duration(days: today.weekday % 7)); // start from last Sunday
    selected = today;
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final d = days[i];
          final isSel = d.year == selected!.year && d.month == selected!.month && d.day == selected!.day;
          final label = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][d.weekday % 7];
          return ChoiceChip(
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(label), Text('${d.day}')],
            ),
            selected: isSel,
            onSelected: (_) {
              setState(() => selected = d);
              widget.onSelect(d);
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: days.length,
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickCard({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [Icon(icon), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _StatCard({required this.title, required this.lines});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...lines.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(e),
                      )),
                ],
              ),
            ),
            const Icon(Icons.trending_up),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// Goals Page
// =============================================================
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Goals')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          if (state.goals.isEmpty) return const _EmptyState(msg: 'No goals yet. Add one!');
          return ListView.separated(
            itemCount: state.goals.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final g = state.goals[i];
              return Dismissible(
                key: ValueKey(g.id),
                background: Container(color: Colors.red.withOpacity(0.2)),
                onDismissed: (_) => state.removeGoal(i),
                child: CheckboxListTile(
                  title: Text(
                    g.title,
                    style: TextStyle(decoration: g.done ? TextDecoration.lineThrough : null),
                  ),
                  subtitle: g.dueDate == null ? null : Text('Due: ${_dateShort(g.dueDate!)}'),
                  value: g.done,
                  onChanged: (_) => state.toggleGoal(i),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Goal',
        onPressed: () async {
          final title = await _promptForText(context, title: 'New Goal');
          if (title == null || title.trim().isEmpty) return;
          DateTime? due;
          if (context.mounted) {
            due = await showDatePicker(
              context: context,
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
              initialDate: DateTime.now(),
            );
          }
          state.addGoal(title.trim(), due: due);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _dateShort(DateTime d) => '${d.year}/${d.month}/${d.day}';

// =============================================================
// Habits Page (check-in per day)
// =============================================================
class HabitsPage extends StatelessWidget {
  final DateTime day;
  const HabitsPage({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('My Habits — ${day.month}/${day.day}')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          if (state.habits.isEmpty) return const _EmptyState(msg: 'No habits yet. Add one!');
          final key = AppState._dayKey(day);
          return ListView.separated(
            itemCount: state.habits.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final h = state.habits[i];
              final done = h.completions.contains(key);
              return ListTile(
                leading: Icon(done ? Icons.check_circle : Icons.circle_outlined),
                title: Text(h.title),
                subtitle: Text('Streak: ${h.streak}'),
                trailing: Wrap(spacing: 8, children: [
                  IconButton(
                    tooltip: done ? 'Unmark today' : 'Mark done today',
                    icon: const Icon(Icons.today),
                    onPressed: () => state.toggleHabitForDay(i, day),
                  ),
                  IconButton(
                    tooltip: 'Reset streak',
                    icon: const Icon(Icons.refresh),
                    onPressed: () => state.resetHabit(i),
                  ),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Habit',
        onPressed: () async {
          final text = await _promptForText(context, title: 'New Habit');
          if (text != null && text.trim().isNotEmpty) {
            state.addHabit(text.trim());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String msg;
  const _EmptyState({required this.msg});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_empty, size: 48),
          const SizedBox(height: 8),
          Text(msg),
        ],
      ),
    );
  }
}

// =============================================================
// Progress Page + Sparkline (no external packages)
// =============================================================
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          final totalGoals = state.goals.length;
          final done = state.goals.where((g) => g.done).length;
          final habits = state.habits.length;

          final last7Counts = _last7DaysCompletionCounts(state.habits);
          final totalStreak = state.habits.fold<int>(0, (sum, h) => sum + h.streak);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressTile(label: 'Goals completed', value: '$done / $totalGoals', icon: Icons.flag),
                const SizedBox(height: 8),
                _ProgressTile(label: 'Habits tracking', value: '$habits', icon: Icons.repeat),
                const SizedBox(height: 8),
                _ProgressTile(label: 'Total streak (all habits)', value: '$totalStreak', icon: Icons.local_fire_department),
                const SizedBox(height: 16),
                Text('Completions (last 7 days)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(height: 100, child: CustomPaint(painter: _SparklinePainter(values: last7Counts))),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Great job!'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keep going! 🚀'))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

List<int> _last7DaysCompletionCounts(List<Habit> habits) {
  final now = DateTime.now();
  final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
  return days
      .map((d) => habits.where((h) => h.completions.contains(AppState._dayKey(d))).length)
      .toList();
}

class _ProgressTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ProgressTile({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<Habit> habits;
  const _Sparkline({required this.habits});
  @override
  Widget build(BuildContext context) {
    final values = _last7DaysCompletionCounts(habits);
    return SizedBox(height: 80, child: CustomPaint(painter: _SparklinePainter(values: values)));
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  _SparklinePainter({required this.values});
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = (values.reduce((a, b) => a > b ? a : b)).clamp(1, 999);
    final stepX = size.width / (values.length - 1);
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxV) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.blue;
    canvas.drawPath(path, paint);
    // Dots
    final dot = Paint()..color = Colors.blue;
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxV) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.values != values;
}

// =============================================================
// Settings + Reminders
// =============================================================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                value: state.darkMode,
                onChanged: state.setDark,
              ),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('Life Goals • Flutter single-file demo with persistence'),
                trailing: const Icon(Icons.info_outline),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Life Goals',
                  applicationVersion: '1.1',
                  applicationIcon: const Icon(Icons.flag),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.reminderTimes
                      .map((t) => InputChip(
                            label: Text(t),
                            onDeleted: () => state.removeReminder(t),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Add reminder time'),
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) state.addReminder(picked);
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note: This demo stores reminder times but does not schedule OS notifications.\n'
                  'To enable real alerts, integrate a package like "flutter_local_notifications".',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================
// Shared helpers
// =============================================================
Future<String?> _promptForText(BuildContext context, {required String title}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Type here...', border: OutlineInputBorder()),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
      ],
    ),
  );
}

void _showQuickAdd(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) {
      final state = AppStateScope.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            runSpacing: 8,
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Add Goal'),
                onTap: () async {
                  Navigator.pop(context);
                  final text = await _promptForText(context, title: 'New Goal');
                  if (text != null && text.trim().isNotEmpty) {
                    state.addGoal(text.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal added')));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Add Habit'),
                onTap: () async {
                  Navigator.pop(context);
                  final text = await _promptForText(context, title: 'New Habit');
                  if (text != null && text.trim().isNotEmpty) {
                    state.addHabit(text.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit added')));
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('View Progress'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressPage()));
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
