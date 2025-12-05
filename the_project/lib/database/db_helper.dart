import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      version: 5, // Increment version to trigger onUpgrade
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

    if (oldVersion < 5) {
      // Remove mood columns from home_status table
      // SQLite doesn't support DROP COLUMN directly, so we need to recreate the table
      
      // Create new table without mood columns
      await db.execute('''
        CREATE TABLE home_status_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          userId INTEGER,
          water_count INTEGER NOT NULL,
          water_goal INTEGER NOT NULL,
          detox_progress REAL NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id),
          UNIQUE(date, userId)
        );
      ''');
      
      // Copy data from old table (excluding mood columns)
      await db.execute('''
        INSERT INTO home_status_new (id, date, userId, water_count, water_goal, detox_progress)
        SELECT id, date, userId, water_count, water_goal, detox_progress
        FROM home_status;
      ''');
      
      // Drop old table
      await db.execute('DROP TABLE home_status;');
      
      // Rename new table to original name
      await db.execute('ALTER TABLE home_status_new RENAME TO home_status;');
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

    // home status table with userId (WITHOUT mood fields)
    await db.execute('''
      CREATE TABLE home_status(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        userId INTEGER,
        water_count INTEGER NOT NULL,
        water_goal INTEGER NOT NULL,
        detox_progress REAL NOT NULL,
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

    // Daily moods table (separate from home_status)
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

  /// Check if a user with this email already exists
  static Future<bool> userExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Login using email
  static Future<Map<String, dynamic>?> loginUserByEmail(
      String email, String password) async {
    // You already have loginUser(email, password), so reuse it:
    return await loginUser(email, password);
  }

  /// Login using username (we will use the "name" column as username)
  static Future<Map<String, dynamic>?> loginUserByUsername(
      String username, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

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

  // ------------------ Stars Methods ------------------

  /// Get current number of stars for a specific user
  static Future<int> getUserStars(int userId) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: ['stars'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final value = result.first['stars'];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  /// Update the number of stars for a specific user
  static Future<void> updateUserStars(int userId, int stars) async {
    final db = await database;

    await db.update(
      'users',
      {'stars': stars},
      where: 'id = ?',
      whereArgs: [userId],
    );
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

  // ------------------ Journal Methods ------------------

  /// Get journal count for a date range
  static Future<int> getJournalCountForRange(
    int userId, 
    String startDate, 
    String endDate
  ) async {
    final db = await database;
    
    print('DBHelper: Getting journal count for userId=$userId, startDate=$startDate, endDate=$endDate');
    
    final result = await db.rawQuery(
      '''SELECT COUNT(*) as c FROM journals 
         WHERE userId = ? 
         AND substr(date, 1, 10) >= ? 
         AND substr(date, 1, 10) <= ?''',
      [userId, startDate, endDate],
    );
    
    final count = Sqflite.firstIntValue(result) ?? 0;
    print('DBHelper: Journal count result: $count');
    
    return count;
  }

  /// Get all journals for a specific date (for debugging)
  static Future<List<Map<String, dynamic>>> getJournalsForDate(
    int userId,
    String date
  ) async {
    final db = await database;
    
    return await db.query(
      'journals',
      where: 'userId = ? AND substr(date, 1, 10) = ?',
      whereArgs: [userId, date],
    );
  }

  // ------------------ SharedPreferences Methods ------------------

  /// Get current logged-in user ID from SharedPreferences
  static Future<int?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      print('DBHelper: Current userId from SharedPreferences: $userId');
      return userId;
    } catch (e) {
      print('DBHelper: Error getting userId: $e');
      return null;
    }
  }

  // ------------------ Debug Methods ------------------

  /// Print all tables for debugging
  static Future<void> debugPrintAllTables() async {
    final db = await database;
    
    print('\n========== DATABASE DEBUG ==========');
    
    // Print Users
    print('\n--- USERS TABLE ---');
    final users = await db.query('users');
    for (var user in users) {
      print('User: id=${user['id']}, name=${user['name']}, email=${user['email']}, points=${user['totalPoints']}, stars=${user['stars']}');
    }
    
    // Print Home Status
    print('\n--- HOME_STATUS TABLE ---');
    final homeStatus = await db.query('home_status', orderBy: 'date DESC', limit: 20);
    for (var status in homeStatus) {
      print('HomeStatus: date=${status['date']}, userId=${status['userId']}, water=${status['water_count']}, detox=${status['detox_progress']}');
    }
    
    // Print Daily Moods
    print('\n--- DAILY_MOODS TABLE ---');
    final moods = await db.query('daily_moods', orderBy: 'date DESC', limit: 20);
    for (var mood in moods) {
      print('Mood: date=${mood['date']}, userId=${mood['userId']}, label=${mood['moodLabel']}, image=${mood['moodImage']}');
    }
    
    // Print Journals
    print('\n--- JOURNALS TABLE ---');
    final journals = await db.query('journals', orderBy: 'date DESC', limit: 20);
    for (var journal in journals) {
      final textPreview = journal['text']?.toString();
      final preview = textPreview != null && textPreview.isNotEmpty 
          ? textPreview.substring(0, min(50, textPreview.length))
          : 'no text';
      print('Journal: id=${journal['id']}, date=${journal['date']}, userId=${journal['userId']}, mood=${journal['mood']}, text=$preview...');
    }
    
    // Print Habits
    print('\n--- HABITS TABLE ---');
    final habits = await db.query('habits', limit: 20);
    for (var habit in habits) {
      print('Habit: id=${habit['id']}, userId=${habit['userId']}, title=${habit['title']}, status=${habit['status']}');
    }
    
    print('\n====================================\n');
  }

  /// Debug: Print data for specific user
  static Future<void> debugPrintUserData(int userId) async {
    final db = await database;
    
    print('\n========== USER DATA DEBUG (userId: $userId) ==========');
    
    // User info
    final user = await getUserById(userId);
    print('User: $user');
    
    // Home status
    print('\n--- Home Status (last 7 days) ---');
    final homeStatus = await db.query(
      'home_status',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 7,
    );
    for (var row in homeStatus) {
      print('  ${row['date']}: water=${row['water_count']}, detox=${row['detox_progress']}');
    }
    
    // Moods
    print('\n--- Moods (last 7 days) ---');
    final moods = await db.query(
      'daily_moods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 7,
    );
    for (var row in moods) {
      print('  ${row['date']}: ${row['moodLabel']}');
    }
    
    // Journals
    print('\n--- Journals (last 7 days) ---');
    final journals = await db.query(
      'journals',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 7,
    );
    for (var row in journals) {
      final textStr = row['text']?.toString();
      final preview = textStr != null && textStr.isNotEmpty
          ? textStr.substring(0, min(30, textStr.length))
          : 'no text';
      print('  ${row['date']}: ${row['mood']} - $preview...');
    }
    
    print('\n====================================\n');
  }

  // ------------------ Utilities ------------------

  // clear all tables
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('journals');
    await db.delete('habits');
    await db.delete('home_status');
    await db.delete('daily_moods');
    await db.delete('users');
  }

  // Close the database
  static Future<void> close() async {
    final db = _database;
    db?.close();
    _database = null;
  }

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
        'totalPoints': 0,
        'stars': 0,
      });
      
      // Create demo data for the last 7 days
      final today = DateTime.now();
      final rnd = Random(1234);
      
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        // For today, start with 0 water and 0 detox
        final isToday = i == 0;
        
        // Insert home_status data (WITHOUT mood fields)
        await db.insert('home_status', {
          'date': dateStr,
          'userId': userId,
          'water_count': isToday ? 0 : (rnd.nextDouble() * 3 + 5).toInt(),
          'water_goal': 8,
          'detox_progress': isToday ? 0.0 : rnd.nextDouble(),
        });
        
        // Add mood data to daily_moods table instead (but not for today)
        if (!isToday) {
          final moodLabels = ['happy', 'good', 'ok', 'low', 'sad'];
          await db.insert('daily_moods', {
            'userId': userId,
            'date': dateStr,
            'moodImage': 'assets/moods/mood_${i % 5}.png',
            'moodLabel': moodLabels[i % 5],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
        
        // Add some journal entries (but not for today)
        if (i % 2 == 0 && !isToday) {
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
      
      await db.insert('habits', {
        'userId': userId,
        'title': 'Read a Book',
        'description': 'Read for 20 minutes',
        'frequency': 'daily',
        'status': 'active',
        'createdDate': createdDateStr,
        'lastUpdated': createdDateStr,
        'Doitat': '20:00',
        'points': 10,
      });
      
      await db.insert('habits', {
        'userId': userId,
        'title': 'Weekly Review',
        'description': 'Review your week',
        'frequency': 'weekly',
        'status': 'active',
        'createdDate': createdDateStr,
        'lastUpdated': createdDateStr,
        'Doitat': '18:00',
        'points': 20,
      });
    }
  }
}