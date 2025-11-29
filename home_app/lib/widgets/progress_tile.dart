import 'package:flutter/material.dart';

class ProgressTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProgressTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      // Use const TextStyle for efficiency
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
