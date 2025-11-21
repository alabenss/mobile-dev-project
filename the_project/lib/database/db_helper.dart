import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rise_app.db');
    return _database!;
  }

  // Initialize and open the database
  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create all the tables
  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        totalPoints INTEGER DEFAULT 0
      );
    ''');

    // Habits table (includes createdDate and lastUpdated)
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        description TEXT,
        frequency TEXT,       -- 'daily', 'weekly', 'monthly'
        status TEXT,          -- 'active', 'completed', 'skipped'
        createdDate TEXT,     -- date when habit was added
        Doitat TEXT,     -- when task is going to be performed y3ni alert time
        points INTEGER,       -- points earned when completed
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');

    // Journals table
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        mood TEXT,
        text TEXT,
        imagePath TEXT,
        voicePath TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');

  }

  // clear all tables 
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('journals');
    await db.delete('habits');
    await db.delete('users');
  }

  // Close the database
  static Future<void> close() async {
    final db = await _database;
    db?.close();
    _database = null;
  }
}
