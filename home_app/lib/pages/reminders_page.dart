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
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        return Scaffold(
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
                    children: state.reminders
                        .map((t) => InputChip(
                              label: Text(t),
                              onDeleted: () => state.deleteReminder(t),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_alarm),
                    label: const Text('Add Reminder Time'),
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (picked != null) state.addReminder(picked);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note: This demo stores reminder times but does not schedule OS notifications.\n'
                    'To enable real alerts, integrate a package like "flutter_local_notifications".',
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
        );
      },
    );
  }
}

