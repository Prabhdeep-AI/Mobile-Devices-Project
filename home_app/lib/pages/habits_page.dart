import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import 'goals_page.dart';
import 'habits_page.dart';
import 'progress_page.dart';
import 'settings_page.dart';
import 'reminders_page.dart';
import '../widgets/profile_header.dart';
import '../widgets/date_scroller.dart';
import '../widgets/quick_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/sparkline.dart';
import '../helpers/dialogs.dart';
import '../helpers/utils.dart';


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