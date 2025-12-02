// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // ------------------ GOALS ------------------
  static Future<List<Goal>> fetchGoals() async {
    final url = Uri.parse('$baseUrl/goals');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((json) => Goal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch goals');
    }
  }

  static Future<Goal> addGoal(String title, {DateTime? dueDate}) async {
    final url = Uri.parse('$baseUrl/goals');
    final body = jsonEncode({
      'title': title,
      'dueDate': dueDate?.toIso8601String(),
    });

    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200 || res.statusCode == 201) {
      return Goal.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to add goal');
    }
  }

  static Future<void> updateGoal(Goal goal) async {
    final url = Uri.parse('$baseUrl/goals/${goal.id}');
    final body = jsonEncode(goal.toJson());

    final res = await http.put(url, body: body, headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) throw Exception('Failed to update goal');
  }

  static Future<void> deleteGoal(String id) async {
    final url = Uri.parse('$baseUrl/goals/$id');
    final res = await http.delete(url);

    if (res.statusCode != 200) throw Exception('Failed to delete goal');
  }

  // ------------------ HABITS ------------------
  static Future<List<Habit>> fetchHabits() async {
    final url = Uri.parse('$baseUrl/habits');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((json) => Habit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch habits');
    }
  }

  static Future<Habit> addHabit(String title) async {
    final url = Uri.parse('$baseUrl/habits');
    final body = jsonEncode({'title': title});

    final res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200 || res.statusCode == 201) {
      return Habit.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to add habit');
    }
  }

  static Future<void> updateHabit(Habit habit) async {
    final url = Uri.parse('$baseUrl/habits/${habit.id}');
    final body = jsonEncode(habit.toJson());

    final res = await http.put(url, body: body, headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) throw Exception('Failed to update habit');
  }

  static Future<void> deleteHabit(String id) async {
    final url = Uri.parse('$baseUrl/habits/$id');
    final res = await http.delete(url);

    if (res.statusCode != 200) throw Exception('Failed to delete habit');
  }

  // ------------------ PROFILE ------------------
  static Future<void> updateProfileName(String name) async {
    final url = Uri.parse('$baseUrl/profile');
    final body = jsonEncode({'profileName': name});

    final res = await http.put(url, body: body, headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) throw Exception('Failed to update profile');
  }
}


