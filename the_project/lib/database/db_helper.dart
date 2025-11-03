import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Get a single database instance
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
    // 🧍 Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        totalPoints INTEGER DEFAULT 0
      );
    ''');

    // ✅ Habits table (includes createdDate and lastUpdated)
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        description TEXT,
        frequency TEXT,       -- 'daily', 'weekly', 'monthly'
        status TEXT,          -- 'active', 'completed', 'skipped'
        createdDate TEXT,     -- date when habit was added
        lastUpdated TEXT,     -- date when last status was updated
        points INTEGER,       -- points earned when completed
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');

    // 📔 Journals table
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

    // 🎯 Activities table
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        cost INTEGER
      );
    ''');

    // 💰 Transactions table (for tracking earned and spent points)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        type TEXT,            -- 'earn' or 'spend'
        amount INTEGER,
        description TEXT,
        date TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');
  }

  // Optional: clear all tables (use carefully in development)
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('activities');
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
