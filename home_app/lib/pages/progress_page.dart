import 'package:flutter/material.dart';
import '../app_state.dart';
import '../app_state_scope.dart';
import '../helpers/utils.dart';
import '../widgets/progress_tile.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context); // ✅ FIXED

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        final totalGoals = state.goals.length;
        final done = state.goals.where((g) => g.done).length;
        final totalHabits = state.habits.length;
        final totalStreak =
            state.habits.fold<int>(0, (sum, h) => sum + h.streak);
        final last7 = last7DaysCompletionCounts(state.habits);

        return Scaffold(
          backgroundColor: state.backgroundColor,
          appBar: AppBar(title: const Text('Progress')),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressTile(
                    label: 'Goals completed',
                    value: '$done / $totalGoals',
                    icon: Icons.flag,
                  ),
                  ProgressTile(
                    label: 'Habits tracking',
                    value: '$totalHabits',
                    icon: Icons.repeat,
                  ),
                  ProgressTile(
                    label: 'Total streak',
                    value: '$totalStreak',
                    icon: Icons.local_fire_department,
                  ),
                  const SizedBox(height: 16),
                  const Text('Completions (last 7 days)'),
                  const Divider(),
                  SizedBox(
                    height: 100,
                    child: CustomPaint(
                      painter: SparklinePainter(values: last7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Go to Home',
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.home),
          ),
        );
      },
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<int> values;
  SparklinePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    if (values.isEmpty) return;

    final step = size.width / (values.length - 1);
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height -
          (values[i] / (maxVal == 0 ? 1 : maxVal)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // dots
    final dotPaint = Paint()
      ..color = Colors.blue.shade900
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height -
          (values[i] / (maxVal == 0 ? 1 : maxVal)) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

