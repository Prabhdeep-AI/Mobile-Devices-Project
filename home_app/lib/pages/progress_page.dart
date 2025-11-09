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
import '../helpers/dialogs.dart';
import '../helpers/utils.dart';
// =============================================================
// Progress Page + Sparkline (no external packages)
// =============================================================
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          final totalGoals = state.goals.length;
          final done = state.goals.where((g) => g.done).length;
          final habits = state.habits.length;

          final last7Counts = _last7DaysCompletionCounts(state.habits);
          final totalStreak = state.habits.fold<int>(0, (sum, h) => sum + h.streak);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressTile(label: 'Goals completed', value: '$done / $totalGoals', icon: Icons.flag),
                const SizedBox(height: 8),
                _ProgressTile(label: 'Habits tracking', value: '$habits', icon: Icons.repeat),
                const SizedBox(height: 8),
                _ProgressTile(label: 'Total streak (all habits)', value: '$totalStreak', icon: Icons.local_fire_department),
                const SizedBox(height: 16),
                Text('Completions (last 7 days)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(height: 100, child: CustomPaint(painter: _SparklinePainter(values: last7Counts))),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Great job!'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keep going! 🚀'))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}