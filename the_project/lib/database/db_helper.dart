import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
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
      version: 2, // Increment version to trigger onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add userId column to home_status table
      await db.execute('ALTER TABLE home_status ADD COLUMN userId INTEGER');
    }
  }

  // Create all the tables
  static Future<void> _onCreate(Database db, int version) async {
    // Users table with password field
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        totalPoints INTEGER DEFAULT 0
      );
    ''');

    // home status table with userId
    await db.execute('''
      CREATE TABLE home_status(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        userId INTEGER,
        water_count INTEGER NOT NULL,
        water_goal INTEGER NOT NULL,
        detox_progress REAL NOT NULL,
        mood_label TEXT,
        mood_image TEXT,
        mood_time TEXT,
        FOREIGN KEY (userId) REFERENCES users(id),
        UNIQUE(date, userId)
      );
    ''');

    // Habits table (includes createdDate, lastUpdated)
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        description TEXT,
        frequency TEXT,
        status TEXT,
        createdDate TEXT,
        lastUpdated TEXT,
        Doitat TEXT,
        points INTEGER,
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

  // ------------------ Auth Methods ------------------

  /// Check if a user exists with the given email
  static Future<bool> userExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Create a new user and return their ID
  static Future<int> createUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'totalPoints': 0,
    });
  }

  /// Login user - verify credentials
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return result.first;
  }

  /// Get user by ID
  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return result.first;
  }

  // ------------------ User + Points Methods ------------------

  /// Ensure there is at least one default user row and return its id.
  static Future<int> ensureDefaultUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);

    if (result.isNotEmpty) {
      final row = result.first;
      final dynamic idValue = row['id'];
      if (idValue is int) return idValue;
      if (idValue is num) return idValue.toInt();
    }

    final id = await db.insert('users', {
      'name': 'Guest',
      'email': 'guest@example.com',
      'password': 'guest123',
      'totalPoints': 0,
    });
    return id;
  }

  /// Read current total points for the default user.
  static Future<int> getUserTotalPoints() async {
    final db = await database;
    final userId = await ensureDefaultUser();

    final result = await db.query(
      'users',
      columns: ['totalPoints'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final value = result.first['totalPoints'];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  /// Update total points for the default user.
  static Future<void> setUserTotalPoints(int points) async {
    final db = await database;
    final userId = await ensureDefaultUser();

    await db.update(
      'users',
      {'totalPoints': points},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ------------------ Utilities ------------------

  // clear all tables
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('journals');
    await db.delete('habits');
    await db.delete('home_status');
    await db.delete('users');
  }

  // Close the database
  static Future<void> close() async {
    final db = _database;
    db?.close();
    _database = null;
  }
  // In db_helper.dart, add this method:

/// Create a demo user with demo data if no users exist
static Future<void> initializeDemoData() async {
  final db = await database;
  
  // Check if we have any users
  final userCount = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) as c FROM users')
  ) ?? 0;
  
  if (userCount == 0) {
    // Create demo user
    final userId = await db.insert('users', {
      'name': 'Demo User',
      'email': 'demo@example.com',
      'password': 'demo123',
      'totalPoints': 100,
    });
    
    // Create demo data for the last 7 days
    final today = DateTime.now();
    final rnd = Random(1234);
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Insert home_status data
      await db.insert('home_status', {
        'date': dateStr,
        'userId': userId,
        'water_count': (rnd.nextDouble() * 3 + 5).toInt(), // 5-8 glasses
        'water_goal': 8,
        'detox_progress': rnd.nextDouble(),
        'mood_label': ['happy', 'ok', 'sad'][i % 3],
        'mood_image': '',
        'mood_time': '${(8 + i % 4)}:00',
      });
      
      // Add some journal entries
      if (i % 2 == 0) {
        await db.insert('journals', {
          'userId': userId,
          'date': dateStr,
          'mood': ['happy', 'ok'][i % 2],
          'text': 'Journal entry for $dateStr. Had a good day!',
          'imagePath': null,
          'voicePath': null,
        });
      }
    }
    
    // Add some habits
    final createdDateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await db.insert('habits', {
      'userId': userId,
      'title': 'Morning Meditation',
      'description': 'Meditate for 10 minutes',
      'frequency': 'daily',
      'status': 'active',
      'createdDate': createdDateStr,
      'lastUpdated': createdDateStr,
      'Doitat': '08:00',
      'points': 10,
    });
  }
}
  
}




 