import 'package:flutter/material.dart';

class DateScroller extends StatefulWidget {
  final DateTime selectedDate;                 // <-- the currently selected date
  final ValueChanged<DateTime> onSelect;       // <-- callback when user picks a day

  const DateScroller({
    required this.selectedDate,
    required this.onSelect,
    super.key,
  });

  @override
  State<DateScroller> createState() => _DateScrollerState();
}

class _DateScrollerState extends State<DateScroller> {
  late DateTime start;  // beginning of the week (Sunday)

  @override
  void initState() {
    super.initState();

    final today = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    // Start from last Sunday
    start = today.subtract(Duration(days: today.weekday % 7));
  }

  @override
  void didUpdateWidget(DateScroller oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the selected date changes from outside, update the week start
    final newDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    start = newDate.subtract(Duration(days: newDate.weekday % 7));
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = days[i];
          final isSelected =
              d.year == widget.selectedDate.year &&
                  d.month == widget.selectedDate.month &&
                  d.day == widget.selectedDate.day;

          final label = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          [d.weekday % 7];

          return ChoiceChip(
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                Text('${d.day}'),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => widget.onSelect(d),
          );
        },
      ),
    );
  }
}
