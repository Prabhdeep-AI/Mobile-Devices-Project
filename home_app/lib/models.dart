import 'package:uuid/uuid.dart';


class Goal {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;
  final DateTime? dueDate;

  Goal({
    required this.title,
    this.done = false,
    String? id,
    DateTime? createdAt,
    this.dueDate,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Goal copyWith({String? title, bool? done, DateTime? dueDate}) => Goal(
    id: id,
    title: title ?? this.title,
    done: done ?? this.done,
    createdAt: createdAt,
    dueDate: dueDate ?? this.dueDate,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
  };

  static Goal fromJson(Map<String, dynamic> m) => Goal(
    id: m['id'] as String,
    title: m['title'] as String,
    done: m['done'] as bool,
    createdAt: DateTime.parse(m['createdAt'] as String),
    dueDate:
    m['dueDate'] == null ? null : DateTime.parse(m['dueDate'] as String),
  );
}

class Habit {
  final String id;
  final String title;
  final int streak;
  final Set<String> completions; // yyyyMMdd

  Habit({
    required this.title,
    this.streak = 0,
    Set<String>? completions,
    String? id,
  })  : id = id ?? const Uuid().v4(),
        completions = completions ?? <String>{};

  Habit copyWith({String? title, int? streak, Set<String>? completions}) =>
      Habit(
        id: id,
        title: title ?? this.title,
        streak: streak ?? this.streak,
        completions: completions ?? this.completions,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'streak': streak,
    'completions': completions.toList(),
  };

  static Habit fromJson(Map<String, dynamic> m) => Habit(
    id: m['id'] as String,
    title: m['title'] as String,
    streak: m['streak'] as int,
    completions: (m['completions'] as List).map((e) => e as String).toSet(),
  );
}