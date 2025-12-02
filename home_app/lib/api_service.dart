// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ApiService {
  static const String baseUrl = 'https://example.com/api';

  // Fetch all goals from backend
  static Future<List<Goal>> fetchGoals() async {
    final response = await http.get(Uri.parse('$baseUrl/goals'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Goal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load goals');
    }
  }

  // Add a new habit to backend
  static Future<Habit> addHabit(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habits'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode == 201) {
      return Habit.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create habit');
    }
  }

  // Update profile name on backend
  static Future<void> updateProfileName(String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'profileName': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile name');
    }
  }
}

