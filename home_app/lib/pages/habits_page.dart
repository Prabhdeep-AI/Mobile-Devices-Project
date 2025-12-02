// lib/pages/habits_page.dart
import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../helpers/dialog_helpers.dart';
import '../helpers/utils.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);
    final todayKey = Utils.dayKey(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text("Habits")),
      body: ListView(
        children: [
          for (final h in state.habits)
            CheckboxListTile(
              value: h.completions.contains(todayKey),
              title: Text(h.title), 
              subtitle: Text("Streak: ${h.streak}"),
              onChanged: (_) => state.toggleHabitCompletion(h),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => DialogHelpers.addHabitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}












