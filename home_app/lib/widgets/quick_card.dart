import 'package:flutter/material.dart';

class QuickCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const QuickCard({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [Icon(icon), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))],
          ),
        ),
      ),
    );
  }
}