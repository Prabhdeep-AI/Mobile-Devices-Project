import 'package:flutter/material.dart';


String _dateShort(DateTime d) => '${d.year}/${d.month}/${d.day}';

List<int> _last7DaysCompletionCounts(List<Habit> habits) {
  final now = DateTime.now();
  final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
  return days
      .map((d) => habits.where((h) => h.completions.contains(AppState._dayKey(d))).length)
      .toList();
}

class _Sparkline extends StatelessWidget {
  final List<Habit> habits;
  const _Sparkline({required this.habits});
  @override
  Widget build(BuildContext context) {
    final values = _last7DaysCompletionCounts(habits);
    return SizedBox(height: 80, child: CustomPaint(painter: _SparklinePainter(values: values)));
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  _SparklinePainter({required this.values});
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = (values.reduce((a, b) => a > b ? a : b)).clamp(1, 999);
    final stepX = size.width / (values.length - 1);
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxV) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.blue;
    canvas.drawPath(path, paint);
    // Dots
    final dot = Paint()..color = Colors.blue;
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxV) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.values != values;
}
