import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper {
  static Database? _db;
  static const _dbName = 'life_goals.db';
  static const _dbVersion = 3;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        done INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        dueDate TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        completions TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        time TEXT PRIMARY KEY
      );
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE goals ADD COLUMN notes TEXT;');
    }
  }

  // ---------------- GOALS ----------------
  static Future<void> insertGoal(Goal goal) async {
    final dbClient = await db;
    await dbClient.insert(
      'goals',
      {
        'id': goal.id,
        'title': goal.title,
        'done': goal.done ? 1 : 0,
        'createdAt': goal.createdAt.toIso8601String(),
        'dueDate': goal.dueDate?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Goal>> getGoals() async {
    final dbClient = await db;
    final maps = await dbClient.query('goals');
    return maps.map((m) {
      return Goal(
        id: m['id'] as String,
        title: m['title'] as String,
        done: (m['done'] as int) == 1,
        createdAt: DateTime.parse(m['createdAt'] as String),
        dueDate: m['dueDate'] == null ? null : DateTime.parse(m['dueDate'] as String),
      );
    }).toList();
  }

  static Future<void> deleteGoal(String id) async {
    final dbClient = await db;
    await dbClient.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- HABITS ----------------
  static Future<void> insertHabit(Habit habit) async {
    final dbClient = await db;
    await dbClient.insert(
      'habits',
      {
        'id': habit.id,
        'title': habit.title,
        'completions': jsonEncode(habit.completions.toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Habit>> getHabits() async {
    final dbClient = await db;
    final maps = await dbClient.query('habits');
    return maps.map((m) {
      final completions = Set<String>.from(jsonDecode(m['completions'] as String));
      final streak = calculateStreak(completions);
      return Habit(
        id: m['id'] as String,
        title: m['title'] as String,
        completions: completions,
        streak: streak,
      );
    }).toList();
  }

  static Future<void> deleteHabit(String id) async {
    final dbClient = await db;
    await dbClient.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- REMINDERS ----------------
  static Future<void> addReminder(String time) async {
    final dbClient = await db;
    await dbClient.insert('reminders', {'time': time}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> removeReminder(String time) async {
    final dbClient = await db;
    await dbClient.delete('reminders', where: 'time = ?', whereArgs: [time]);
  }

  static Future<List<String>> getReminders() async {
    final dbClient = await db;
    final maps = await dbClient.query('reminders');
    return maps.map((m) => m['time'] as String).toList();
  }

  // ---------------- STREAK ----------------
  static int calculateStreak(Set<String> completions) {
    if (completions.isEmpty) return 0;

    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      final key = '${day.year.toString().padLeft(4, '0')}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
      if (completions.contains(key)) {
        streak++;
      } else {
        break; // streak breaks on first missing day
      }
    }

    return streak;
  }
}





