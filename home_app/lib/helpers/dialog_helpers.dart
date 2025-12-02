import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../app_state.dart';
import '../models.dart';
import '../helpers/utils.dart';

class DialogHelpers {
  static Future<void> addGoalDialog(BuildContext context) async {
    final controller = TextEditingController();
    final state = AppStateScope.read(context);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Goal"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Goal"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                state.addGoal(text);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  static Future<void> addHabitDialog(BuildContext context) async {
    final controller = TextEditingController();
    final state = AppStateScope.read(context);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Habit"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Habit"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) state.addHabit(text);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  static Future<void> showQuickAdd(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Quick Add"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text("Add Goal"),
            onTap: () {
              Navigator.pop(context);
              addGoalDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text("Add Habit"),
            onTap: () {
              Navigator.pop(context);
              addHabitDialog(context);
            },
          ),
        ],
      ),
    ),
  );
}

static Future<void> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}
static Future<void> pickColorDialog(BuildContext context) async {
  final state = AppStateScope.read(context);

  Color tempColor = state.backgroundColor;

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Pick Background Color"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Colors.white,
                Colors.black,
                Colors.blue.shade100,
                Colors.blue.shade200,
                Colors.green.shade100,
                Colors.yellow.shade100,
                Colors.pink.shade100,
                Colors.orange.shade100,
                Colors.purple.shade100,
              ].map((c) {
                return GestureDetector(
                  onTap: () {
                    tempColor = c;
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );

  state.setBackgroundColor(tempColor);
}



}







