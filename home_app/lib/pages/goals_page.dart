// lib/pages/goals_page.dart
import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../helpers/dialog_helpers.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Goals")),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        separatorBuilder: (_, __) => const Divider(height: 8),
        itemCount: state.goals.length,
        itemBuilder: (context, index) {
          final g = state.goals[index];
          return CheckboxListTile(
            value: g.done,
            title: Text(
              g.title,
              style: TextStyle(
                decoration: g.done ? TextDecoration.lineThrough : null,
              ),
            ),
            secondary: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => state.deleteGoal(g.id),
              tooltip: 'Delete goal',
            ),
            onChanged: (_) => state.toggleGoal(g.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => DialogHelpers.addGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}





