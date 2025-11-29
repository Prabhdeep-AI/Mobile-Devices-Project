import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../helpers/utils.dart';
import '../models.dart';
import '../app_state.dart'; 

class HabitsPage extends StatefulWidget {
  final DateTime day;
  const HabitsPage({super.key, required this.day});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage>
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
    final dayKey = AppState.dayKey(widget.day);

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: state.backgroundColor,
          appBar: AppBar(title: Text('My Habits — ${widget.day.month}/${widget.day.day}')),
          body: state.habits.isEmpty
              ? const Center(child: Text('No habits yet. Add one!', style: TextStyle(color: Colors.grey)))
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.separated(
                    itemCount: state.habits.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, index) {
                      final h = state.habits[index];
                      final isDone = h.completions.contains(dayKey);

                      return Dismissible(
                        key: ValueKey(h.id),
                        background: Container(color: Colors.red.withOpacity(0.2)),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => state.deleteHabit(h.id),
                        child: ListTile(
                          onTap: () => state.toggleHabit(index, widget.day),
                          leading: Icon(
                            isDone ? Icons.check_circle : Icons.circle_outlined,
                            color: isDone ? Theme.of(context).colorScheme.primary : Colors.grey,
                          ),
                          title: Text(h.title),
                          subtitle: Text('Streak: ${h.streak} days'),
                          trailing: IconButton(
                            icon: Icon(isDone ? Icons.undo : Icons.check),
                            onPressed: () => state.toggleHabit(index, widget.day),
                          ),
                        ),
                      );
                    },
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




