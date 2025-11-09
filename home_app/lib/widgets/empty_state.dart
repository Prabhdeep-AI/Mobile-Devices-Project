import 'package:flutter/material.dart';

class _EmptyState extends StatelessWidget {
  final String msg;

  const _EmptyState({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_empty, size: 48),
          const SizedBox(height: 8),
          Text(msg),
        ],
      ),
    );
  }
}