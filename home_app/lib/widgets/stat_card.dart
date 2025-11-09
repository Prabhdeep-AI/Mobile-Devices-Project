import 'package:flutter/material.dart';

class _StatCard extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _StatCard({required this.title, required this.lines});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...lines.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(e),
                  )),
                ],
              ),
            ),
            const Icon(Icons.trending_up),
          ],
        ),
      ),
    );
  }
}