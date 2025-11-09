import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import 'goals_page.dart';
import 'habits_page.dart';
import 'progress_page.dart';
import 'settings_page.dart';
import '../widgets/profile_header.dart';
import '../widgets/date_scroller.dart';
import '../widgets/quick_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/sparkline.dart';
import '../helpers/dialog_helpers.dart';
import '../helpers/utils.dart';

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
                    label: Text(t), // display string directly
                    onDeleted: () => state.removeReminder(t),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Add reminder time'),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
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
