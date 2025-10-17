import 'package:flutter/material.dart';

void main() => runApp(const LifeGoalsApp());

/// ------------------------------------------------------------
/// Tiny in-memory "app state" for DartPad demo purposes only.
/// ------------------------------------------------------------
class AppState extends ChangeNotifier {
  final List<Goal> goals = [];
  final List<Habit> habits = [];

  void addGoal(String title) {
    goals.add(Goal(title: title));
    notifyListeners();
  }

  void toggleGoal(int index) {
    goals[index] = goals[index].copyWith(done: !goals[index].done);
    notifyListeners();
  }

  void removeGoal(int index) {
    goals.removeAt(index);
    notifyListeners();
  }

  void addHabit(String title) {
    habits.add(Habit(title: title));
    notifyListeners();
  }

  void tickHabit(int index) {
    habits[index] = habits[index].copyWith(streak: habits[index].streak + 1);
    notifyListeners();
  }

  void resetHabit(int index) {
    habits[index] = habits[index].copyWith(streak: 0);
    notifyListeners();
  }
}

class Goal {
  final String title;
  final bool done;
  Goal({required this.title, this.done = false});
  Goal copyWith({String? title, bool? done}) =>
      Goal(title: title ?? this.title, done: done ?? this.done);
}

class Habit {
  final String title;
  final int streak;
  Habit({required this.title, this.streak = 0});
  Habit copyWith({String? title, int? streak}) =>
      Habit(title: title ?? this.title, streak: streak ?? this.streak);
}

/// A simple inherited notifier to share [AppState] without external packages.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}

/// ------------------------------------------------------------
/// App
/// ------------------------------------------------------------
class LifeGoalsApp extends StatefulWidget {
  const LifeGoalsApp({super.key});

  @override
  State<LifeGoalsApp> createState() => _LifeGoalsAppState();
}

class _LifeGoalsAppState extends State<LifeGoalsApp> {
  final appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        title: 'Life Goals',
        debugShowCheckedModeBanner: false,
        home: const LifeGoalsHome(),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Home
/// ------------------------------------------------------------
class LifeGoalsHome extends StatelessWidget {
  const LifeGoalsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: const Text(
          "Life Goals",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time, color: Colors.black),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RemindersPage()));
            },
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
            tooltip: 'Settings',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: const [
              Icon(Icons.person, size: 40, color: Colors.black),
              SizedBox(height: 4),
              Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "Date",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Tappable date chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _DateChip(day: "Sat", num: "20"),
                _DateChip(day: "Sun", num: "21"),
                _DateChip(day: "Mon", num: "22"),
                _DateChip(day: "Tue", num: "23"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick glance cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    label: "Goals",
                    icon: Icons.flag,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoalsPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    label: "Habits",
                    icon: Icons.repeat,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HabitsPage()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Tiny summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: state,
              builder: (_, __) {
                final done = state.goals.where((g) => g.done).length;
                final total = state.goals.length;
                return Text(
                  "Completed goals: $done / $total    |    Habits tracked: ${state.habits.length}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                );
              },
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoalsPage()),
              ),
              child: const Text("My Goals"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitsPage()),
              ),
              child: const Text("My Habits"),
            ),
            const SizedBox(width: 40), // spacing for FAB
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressPage()),
              ),
              child: const Text("Progress"),
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
        onPressed: () {
          // Go "Home": pop to first route
          Navigator.of(context).popUntil((r) => r.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Back to Home')),
          );
        },
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// Quick tappable day chip
class _DateChip extends StatelessWidget {
  final String day;
  final String num;
  const _DateChip({required this.day, required this.num});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected $day $num')),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(num),
          ],
        ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Goals Page
/// ------------------------------------------------------------
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
          if (state.goals.isEmpty) {
            return const Center(child: Text("No goals yet. Add one!"));
          }
          return ListView.builder(
            itemCount: state.goals.length,
            itemBuilder: (_, i) {
              final g = state.goals[i];
              return Dismissible(
                key: ValueKey('goal-$i-${g.title}'),
                background: Container(color: Colors.redAccent),
                onDismissed: (_) => state.removeGoal(i),
                child: CheckboxListTile(
                  title: Text(
                    g.title,
                    style: TextStyle(
                      decoration: g.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
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
          final text = await _promptForText(context, title: 'New Goal');
          if (text != null && text.trim().isNotEmpty) {
            state.addGoal(text.trim());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Habits Page
/// ------------------------------------------------------------
class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Habits')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          if (state.habits.isEmpty) {
            return const Center(child: Text("No habits yet. Add one!"));
          }
          return ListView.builder(
            itemCount: state.habits.length,
            itemBuilder: (_, i) {
              final h = state.habits[i];
              return ListTile(
                leading: const Icon(Icons.repeat),
                title: Text(h.title),
                subtitle: Text('Streak: ${h.streak}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: 'Mark done (streak +1)',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () => state.tickHabit(i),
                    ),
                    IconButton(
                      tooltip: 'Reset streak',
                      icon: const Icon(Icons.refresh),
                      onPressed: () => state.resetHabit(i),
                    ),
                  ],
                ),
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

/// ------------------------------------------------------------
/// Progress Page (simple summary)
/// ------------------------------------------------------------
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
          final totalStreak =
              state.habits.fold<int>(0, (sum, h) => sum + h.streak);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _ProgressTile(
                  label: 'Goals completed',
                  value: '$done / $totalGoals',
                  icon: Icons.flag,
                ),
                const SizedBox(height: 8),
                _ProgressTile(
                  label: 'Habits tracked',
                  value: '$habits',
                  icon: Icons.repeat,
                ),
                const SizedBox(height: 8),
                _ProgressTile(
                  label: 'Total habit streak',
                  value: '$totalStreak',
                  icon: Icons.local_fire_department,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.celebration),
                  label: const Text('Great job!'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Keep going! 🚀')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ProgressTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Settings + Reminders (simple demo pages)
/// ------------------------------------------------------------
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    bool notifications = true;
    bool darkMode = false;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: StatefulBuilder(
        builder: (context, setState) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Notifications'),
              value: notifications,
              onChanged: (v) => setState(() => notifications = v),
            ),
            SwitchListTile(
              title: const Text('Dark mode (visual only)'),
              value: darkMode,
              onChanged: (v) => setState(() => darkMode = v),
            ),
            ListTile(
              title: const Text('About'),
              subtitle: const Text('Life Goals demo (DartPad single file)'),
              trailing: const Icon(Icons.info_outline),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Life Goals',
                applicationVersion: '1.0 (demo)',
                applicationIcon: const Icon(Icons.flag),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alarm, size: 64),
            const SizedBox(height: 12),
            Text(
              "It's ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}\nStay consistent today!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_alarm),
              label: const Text('Create a quick reminder'),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder set (demo)')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Helpers
/// ------------------------------------------------------------
Future<String?> _promptForText(BuildContext context, {required String title}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Type here...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
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
                  final text =
                      await _promptForText(context, title: 'New Goal');
                  if (text != null && text.trim().isNotEmpty) {
                    state.addGoal(text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal added')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Add Habit'),
                onTap: () async {
                  Navigator.pop(context);
                  final text =
                      await _promptForText(context, title: 'New Habit');
                  if (text != null && text.trim().isNotEmpty) {
                    state.addHabit(text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Habit added')),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('View Progress'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProgressPage()));
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
