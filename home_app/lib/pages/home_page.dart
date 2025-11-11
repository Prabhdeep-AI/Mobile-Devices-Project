import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../helpers/dialog_helpers.dart';
import 'progress_page.dart';
import '../app_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showQuickAdd(context),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProgressPage()));
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Goals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...state.goals.map(
                    (g) => ListTile(
                  title: Text(g.title),
                  trailing: Checkbox(
                    value: g.done,
                    onChanged: (_) {
                      final index = state.goals.indexOf(g);
                      state.toggleGoal(index);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Habits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...state.habits.map(
                    (h) => ListTile(
                  title: Text(h.title),
                  subtitle: Text('Streak: ${h.streak}'),
                  trailing: IconButton(
                    icon: Icon(
                      h.completions.contains(AppState.dayKey(DateTime.now()))
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    onPressed: () {
                      final index = state.habits.indexOf(h);
                      state.toggleHabitForDay(index, DateTime.now());
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showQuickAdd(context),
      ),
    );
  }
}




