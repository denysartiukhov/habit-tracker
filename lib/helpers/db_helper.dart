import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:habit_tracker/models/habit.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = "/Users/denysartiukhov/Desktop/flutter_projects/habit-tracker/habits.db";
    return await openDatabase(
      path,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE Habits (
            HabitID TEXT PRIMARY KEY, 
            HabitName TEXT NOT NULL, 
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );
        ''');
        db.execute('''
          CREATE TABLE Completions (
            CompletionID INTEGER PRIMARY KEY AUTOINCREMENT,
            HabitID TEXT,
            CompletionDate DATE NOT NULL,
            Status BOOLEAN NOT NULL,
            FOREIGN KEY (HabitID) REFERENCES Habits(HabitID),
            UNIQUE (HabitID, CompletionDate)
          );
        ''');
      },
      version: 1,
    );
  }

  Future<void> toggleCompletion(String habitId, String date, bool status) async {
    print("Toggling complition in DB");
    final db = await database;
    int count = await db.rawUpdate(
      '''
      UPDATE Completions
      SET Status = ?
      WHERE HabitID = ? AND CompletionDate = ?
      ''',
      [status ? 1 : 0, habitId, date],
    );

    if (count == 0) {
      await db.insert('Completions', {
        'HabitID': habitId,
        'CompletionDate': date,
        'Status': status ? 1 : 0,
      });
    }
  }
  Future<void> addHabit(String habitId, String habitName) async {
    print("Adding new habit in DB");
    final db = await database;
    await db.insert('Habits', {
      'HabitID': habitId,
      'HabitName': habitName,
    });
  }

  Future<void> removeHabit(String habitId) async {
    final db = await database;
    await db.rawQuery('''
      DELETE FROM Completions WHERE HabitID = "$habitId";
    ''');
    await db.rawQuery('''
      DELETE FROM Habits WHERE HabitID = "$habitId";
    ''');
  }

  Future<List<Habit>> getHabits() async {
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final db = await database;
    var habits = await db.rawQuery('SELECT h.HabitID, h.HabitName, c.CompletionDate, c.Status  FROM Habits h LEFT JOIN Completions c ON h.HabitID = c.HabitID AND c.CompletionDate = "$date";');

    final habitsList = List.generate(habits.length, (i) {
      return Habit(
        id: habits[i]['HabitID'].toString(),
        name: habits[i]['HabitName'].toString(),
        isCompleted: habits[i]['Status'].toString() == "1" ? true : false,
        // Same for the other properties
      );
    });
    return habitsList;
  }
}