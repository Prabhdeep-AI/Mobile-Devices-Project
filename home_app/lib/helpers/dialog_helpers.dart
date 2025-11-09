import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../pages/progress_page.dart';


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
