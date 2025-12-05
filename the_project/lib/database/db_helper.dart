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
      version: 4, // Increment version to trigger onUpgrade
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
    
    if (oldVersion < 3) {
      // Add new columns to journals table for enhanced features
      await db.execute('ALTER TABLE journals ADD COLUMN title TEXT');
      await db.execute('ALTER TABLE journals ADD COLUMN backgroundImage TEXT');
      await db.execute('ALTER TABLE journals ADD COLUMN fontFamily TEXT');
      await db.execute('ALTER TABLE journals ADD COLUMN textColor TEXT');
      await db.execute('ALTER TABLE journals ADD COLUMN fontSize REAL');
      await db.execute('ALTER TABLE journals ADD COLUMN attachedImages TEXT'); // JSON array
      await db.execute('ALTER TABLE journals ADD COLUMN stickers TEXT'); // JSON array
      await db.execute('ALTER TABLE journals ADD COLUMN time TEXT'); // Time of journal entry
    }

    if (oldVersion < 4) {
      // Create daily_moods table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_moods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          date TEXT NOT NULL,
          moodImage TEXT NOT NULL,
          moodLabel TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id),
          UNIQUE(userId, date)
        )
      ''');
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
        totalPoints INTEGER DEFAULT 0,
        stars INTEGER DEFAULT 0
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

    // Journals table with enhanced fields
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        time TEXT,
        mood TEXT,
        text TEXT,
        title TEXT,
        imagePath TEXT,
        voicePath TEXT,
        backgroundImage TEXT,
        fontFamily TEXT,
        textColor TEXT,
        fontSize REAL,
        attachedImages TEXT,
        stickers TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');

    // Daily moods table
    await db.execute('''
      CREATE TABLE daily_moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        moodImage TEXT NOT NULL,
        moodLabel TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id),
        UNIQUE(userId, date)
      );
    ''');
  }

  // ------------------ Auth Methods ------------------



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
    await db.delete('daily_moods'); // ADD THIS
    await db.delete('users');
  }

  // Close the database
  static Future<void> close() async {
    final db = _database;
    db?.close();
    _database = null;
  }

static Future<int> getUserStars(int userId) async {
  final db = await DBHelper.database;
  final result = await db.query(
    'users',
    columns: ['stars'],
    where: 'id = ?',
    whereArgs: [userId],
  );

  return result.first['stars'] as int;
}

static Future<void> updateUserStars(int userId, int newStars) async {
  final db = await DBHelper.database;
  await db.update(
    'users',
    {'stars': newStars},
    where: 'id = ?',
    whereArgs: [userId],
  );
}

static Future<Map<String, dynamic>?> loginUserByEmail(
      String email, String password) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Login by username
  static Future<Map<String, dynamic>?> loginUserByUsername(
      String username, String password) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  //check if a user exists by email or username
  static Future<bool> userExists(String emailOrUsername) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? OR name = ?',
      whereArgs: [emailOrUsername, emailOrUsername],
    );
    return result.isNotEmpty;
  }

  // Add these methods to your DBHelper class in db_helper.dart

/// Update user name
static Future<void> updateUserName(int userId, String newName) async {
  final db = await database;
  await db.update(
    'users',
    {'name': newName},
    where: 'id = ?',
    whereArgs: [userId],
  );
}

/// Update user email
static Future<void> updateUserEmail(int userId, String newEmail) async {
  final db = await database;
  await db.update(
    'users',
    {'email': newEmail},
    where: 'id = ?',
    whereArgs: [userId],
  );
}

/// Update user password
static Future<void> updateUserPassword(int userId, String newPassword) async {
  final db = await database;
  await db.update(
    'users',
    {'password': newPassword},
    where: 'id = ?',
    whereArgs: [userId],
  );
}

}