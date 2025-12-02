import 'package:flutter/material.dart';
import '../app_state_scope.dart';

class ProfileHeader extends StatelessWidget {
  final DateTime date;

  const ProfileHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context); 

    return Column(
      children: [
        const CircleAvatar(
          radius: 30,
          child: Icon(Icons.person, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          state.profileName, // dynamically updates
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
