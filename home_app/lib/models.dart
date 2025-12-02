import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;
  final DateTime? dueDate;

  Goal({
    String? id,
    required this.title,
    this.done = false,
    DateTime? createdAt,
    this.dueDate,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Goal copyWith({String? title, bool? done, DateTime? dueDate}) {
    return Goal(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  // -------------------------------
  // API / JSON
  // -------------------------------
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      done: json['done'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}

class Habit {
  final String id;
  final String title;
  final Set<String> completions;
  final int streak;

  Habit({
    String? id,
    required this.title,
    Set<String>? completions,
    this.streak = 0,
  })  : id = id ?? const Uuid().v4(),
        completions = completions ?? {};

  Habit copyWith({String? title, Set<String>? completions, int? streak}) {
    return Habit(
      id: id,
      title: title ?? this.title,
      completions: completions ?? this.completions,
      streak: streak ?? this.streak,
    );
  }

  // -------------------------------
  // API / JSON
  // -------------------------------
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      completions: (json['completions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      streak: json['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completions': completions.toList(),
      'streak': streak,
    };
  }
}











