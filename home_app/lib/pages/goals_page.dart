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
import '../helpers/dialog_helpers.dart';
import '../helpers/utils.dart';

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
          if (state.goals.isEmpty) return const EmptyState(msg: 'No goals yet. Add one!');
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

  Future<String?> _promptForText(BuildContext context, {required String title}) async {
    String? result;
    await showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                result = controller.text;
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return result;
  }

  String _dateShort(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
  }
}

class EmptyState extends StatelessWidget {
  final String msg;
  const EmptyState({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
