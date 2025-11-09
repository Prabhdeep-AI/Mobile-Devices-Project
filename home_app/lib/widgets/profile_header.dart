import 'package:flutter/material.dart';


class _ProfileHeader extends StatelessWidget {
  final DateTime date;
  const _ProfileHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final dStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Column(
        children: [
          const CircleAvatar(radius: 24, child: Icon(Icons.person)),
          const SizedBox(height: 6),
          Text('My Profile', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(dStr, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}