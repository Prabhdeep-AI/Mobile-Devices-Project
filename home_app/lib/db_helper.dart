import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper{
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'life_goals.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(''' 
        CREATE TABLE goals(
        id TEXT PRIMARY KEY,
        title TEXT,
        done INTERGER,
        createdAt TEXT
        dueDate TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT,
        streak INTEGER,
        completions TEXT)
        ''');

        await db.execute('''
        CREATE TABLE reminders (
        time TEXT PRIMARY KEY
        )
        ''');
            },
    );
  }

  //------------- Goals -------------

static Future <void> insertGoal(Goal goal) async{
    final dbClient = await db;
    await dbClient.insert('goals', goal.toJson(),
    conflictAlgorithm:  ConflictAlgorithm.replace);
  }
static Future<List<Goal>> getGoals() async {
    final dbClient = await db;
    final maps = await dbClient.query('goals');
    return maps.map((m) => Goal.fromJson(m)).toList();
  }

  static Future<void> deleteGoal(String id) async {
    final dbClient = await db;
    await dbClient.delete('goals', where: 'id = ?', whereArgs: [id]);
  }


//------------- Habits -------------
static Future<void> insertHabit(Habit habit) async {
    final dbClient = await db;
    await dbClient.insert('habits', habit.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace);
}

static Future<List<Habit>> getHabits() async {
    final dbClient = await db;
    final maps = await dbClient.query('habits');
    return maps.map((m) => Habit.fromJson(m)).toList();
}

static Future<void> deleteHabit(String id) async{
    final dbClient = await db;
    await dbClient.delete('habits', where: 'id = ?', whereArgs: [id]);
}

//------------- Reminders -------------

static Future<void> addReminder(String time) async {
    final dbClient = await db;
    await dbClient.insert('reminders', {'time': time},
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> removeReminder(String time) async {
    final dbClient = await db;
    await dbClient.delete('reminders', where: 'time = ?', whereArgs: [time]);
    }

    static Future<List<String>> getReminders() async{
    final dbClient = await db;
    final maps = await dbClient.query('reminders');
    return maps.map((m) => m['time'] as String).toList();
    }
}