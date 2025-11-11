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
}







