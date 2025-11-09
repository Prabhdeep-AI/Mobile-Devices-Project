import 'package:flutter/material.dart';

class DateScroller extends StatefulWidget {
  final DateTime initial;
  final ValueChanged<DateTime> onSelect;
  const DateScroller({required this.initial, required this.onSelect});

  @override
  State<DateScroller> createState() => _DateScrollerState();
}

class _DateScrollerState extends State<DateScroller> {
  late DateTime start;
  DateTime? selected;

  @override
  void initState() {
    super.initState();
    final today = DateTime(widget.initial.year, widget.initial.month, widget.initial.day);
    start = today.subtract(Duration(days: today.weekday % 7)); // start from last Sunday
    selected = today;
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final d = days[i];
          final isSel = d.year == selected!.year && d.month == selected!.month && d.day == selected!.day;
          final label = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][d.weekday % 7];
          return ChoiceChip(
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(label), Text('${d.day}')],
            ),
            selected: isSel,
            onSelected: (_) {
              setState(() => selected = d);
              widget.onSelect(d);
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: days.length,
      ),
    );
  }
}