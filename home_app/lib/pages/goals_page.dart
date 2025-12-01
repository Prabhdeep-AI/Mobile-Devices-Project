// lib/pages/goals_page.dart
import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../widgets/profile_header.dart';
import '../helpers/dialog_helpers.dart';
import '../helpers/utils.dart';
import '../app_state.dart';
import '../notifications.dart'; // <- import

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>
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

    // Run animation only once
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
      builder: (context, _) {
        return Scaffold(
          backgroundColor: state.backgroundColor,
          appBar: AppBar(title: const Text('My Goals')),
          body: state.goals.isEmpty
              ? const EmptyState(msg: 'No goals yet. Add one!')
              : SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.2),
                    end: Offset.zero,
                  ).animate(_fadeAnimation),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.separated(
                      itemCount: state.goals.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, i) {
                        final g = state.goals[i];

                        return Dismissible(
                          key: ValueKey(g.id),
                          background: Container(
                            color: Colors.red.withOpacity(0.2),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => state.deleteGoal(g.id),
                          child: CheckboxListTile(
                            title: Text(g.title),
                            subtitle: g.dueDate != null
                                ? Text("Due: ${_dateShort(g.dueDate!)}")
                                : null,
                            value: g.done,
                            onChanged: (_) async {
                              // Await the toggle, then notify if it became done
                              await state.toggleGoal(g.id);
                              final updated =
                                  state.goals.firstWhere((x) => x.id == g.id);
                              if (updated.done) {
                                await NotificationService.showInstant(
                                  title: 'Goal completed 🎉',
                                  body: 'You completed "${updated.title}" — nice!',
                                );
                              } else {
                                // Optionally notify on undo
                                // await NotificationService.showInstantNotification(title: 'Goal undone', body: 'You reopened "${updated.title}"');
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      },
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add Goal',
            child: const Icon(Icons.add),
            onPressed: () async {
              final title =
                  await _promptForText(context, title: 'New Goal Title');
              if (title == null || title.trim().isEmpty) return;

              DateTime? due;

              final addDue = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Add Due Date?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );

              if (addDue == true) {
                due = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  initialDate: DateTime.now(),
                );
              }

              // Add goal and then show a notification
              await state.addGoal(title.trim(), due: due);

              // notify user
              final latest = state.goals.last;
              await NotificationService.showInstant(
                title: 'New goal added',
                body: 'You added "${latest.title}". Good luck!',
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> _promptForText(BuildContext context,
      {required String title}) async {
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
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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



