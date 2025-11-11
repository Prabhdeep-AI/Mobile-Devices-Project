import 'package:flutter/material.dart';
import '../app_state.dart';
import '../app_state_scope.dart';

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
          final totalStreak = state.habits.fold<int>(0, (sum, h) => sum + h.streak);
          final last7 = _last7Counts(state.habits);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressTile(label: 'Goals completed', value: '$done / $totalGoals', icon: Icons.flag),
                ProgressTile(label: 'Habits tracking', value: '$habits', icon: Icons.repeat),
                ProgressTile(label: 'Total streak', value: '$totalStreak', icon: Icons.local_fire_department),
                const SizedBox(height: 16),
                const Text('Completions (last 7 days)'),
                const SizedBox(height: 8),
                SizedBox(height: 100, child: CustomPaint(painter: SparklinePainter(values: last7))),
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

  List<int> _last7Counts(List<dynamic> habits) {
    final now = DateTime.now();
    List<int> counts = List.generate(7, (_) => 0);
    for (var h in habits) {
      for (int i = 0; i < 7; i++) {
        final key = AppState.dayKey(now.subtract(Duration(days: i)));
        if (h.completions.contains(key)) counts[6 - i]++;
      }
    }
    return counts;
  }
}

class ProgressTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const ProgressTile({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<int> values;
  SparklinePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue..strokeWidth = 3..style = PaintingStyle.stroke;
    if (values.isEmpty) return;
    final step = size.width / (values.length - 1);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - (values[i] / (maxVal == 0 ? 1 : maxVal)) * size.height;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    final dotPaint = Paint()..color = Colors.blue;
    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - (values[i] / (maxVal == 0 ? 1 : maxVal)) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) => oldDelegate.values != values;
}

