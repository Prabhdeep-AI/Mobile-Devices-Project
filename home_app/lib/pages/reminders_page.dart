import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../app_state.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _addReminderDialog(AppState state) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final nameController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reminder Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Enter reminder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      await state.addReminder(time, nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context); // ✅ FIXED

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) => Scaffold(
        backgroundColor: state.backgroundColor,
        appBar: AppBar(title: const Text('Reminders')),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.reminders.map((r) {
                    final time = r['time'] ?? '';
                    final name = r['name'] ?? '';
                    return InputChip(
                      label: Text('$time - $name'),
                      onDeleted: () => state.deleteReminder(time, name),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Add Reminder'),
                  onPressed: () => _addReminderDialog(state),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reminders will notify you at the scheduled time.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Go Home',
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.home),
        ),
      ),
    );
  }
}








