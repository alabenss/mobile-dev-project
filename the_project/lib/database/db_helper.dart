import 'dart:math';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 5, // FINAL VERSION = 5
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Handle database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
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
      // --- Part 1: remove mood columns from home_status (old schema) ---
      // SQLite doesn't support DROP COLUMN, so recreate the table

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

      await db.execute('''
        INSERT INTO home_status_new (id, date, userId, water_count, water_goal, detox_progress)
        SELECT id, date, userId, water_count, water_goal, detox_progress
        FROM home_status;
      ''');

      await db.execute('DROP TABLE home_status;');
      await db.execute('ALTER TABLE home_status_new RENAME TO home_status;');

      // --- Part 2: create app_lock table ---
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_lock (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          lockType TEXT NOT NULL,
          lockValue TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id),
          UNIQUE(userId)
        )
      ''');
    }
  }

  // Create all the tables (final schema)
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

    // home_status table WITHOUT mood fields
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

    // Habits table
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

    // App Lock table
    await db.execute('''
      CREATE TABLE app_lock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        lockType TEXT NOT NULL,
        lockValue TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id),
        UNIQUE(userId)
      )
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
      'stars': 0,
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

  /// Login using email (alias)
  static Future<Map<String, dynamic>?> loginUserByEmail(String email, String password) async {
    return await loginUser(email, password);
  }

  /// Login using username (we will use the "name" column as username)
  static Future<Map<String, dynamic>?> loginUserByUsername(String username, String password) async {
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
      'stars': 0,
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
    String endDate,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''SELECT COUNT(*) as c FROM journals
         WHERE userId = ?
         AND substr(date, 1, 10) >= ?
         AND substr(date, 1, 10) <= ?''',
      [userId, startDate, endDate],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get all journals for a specific date (for debugging)
  static Future<List<Map<String, dynamic>>> getJournalsForDate(int userId, String date) async {
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
      return prefs.getInt('userId');
    } catch (_) {
      return null;
    }
  }

  // ------------------ Debug Methods ------------------

  /// Print all tables for debugging
  static Future<void> debugPrintAllTables() async {
    final db = await database;

    print('\n========== DATABASE DEBUG ==========');

    // Users
    print('\n--- USERS TABLE ---');
    final users = await db.query('users');
    for (var user in users) {
      print(
        'User: id=${user['id']}, name=${user['name']}, email=${user['email']}, points=${user['totalPoints']}, stars=${user['stars']}',
      );
    }

    // Home Status
    print('\n--- HOME_STATUS TABLE ---');
    final homeStatus = await db.query('home_status', orderBy: 'date DESC', limit: 20);
    for (var status in homeStatus) {
      print(
        'HomeStatus: date=${status['date']}, userId=${status['userId']}, water=${status['water_count']}, detox=${status['detox_progress']}',
      );
    }

    // Daily Moods
    print('\n--- DAILY_MOODS TABLE ---');
    final moods = await db.query('daily_moods', orderBy: 'date DESC', limit: 20);
    for (var mood in moods) {
      print(
        'Mood: date=${mood['date']}, userId=${mood['userId']}, label=${mood['moodLabel']}, image=${mood['moodImage']}',
      );
    }

    // Journals
    print('\n--- JOURNALS TABLE ---');
    final journals = await db.query('journals', orderBy: 'date DESC', limit: 20);
    for (var journal in journals) {
      final textPreview = journal['text']?.toString();
      final preview = textPreview != null && textPreview.isNotEmpty
          ? textPreview.substring(0, min(50, textPreview.length))
          : 'no text';
      print(
        'Journal: id=${journal['id']}, date=${journal['date']}, userId=${journal['userId']}, mood=${journal['mood']}, text=$preview...',
      );
    }

    // Habits
    print('\n--- HABITS TABLE ---');
    final habits = await db.query('habits', limit: 20);
    for (var habit in habits) {
      print(
        'Habit: id=${habit['id']}, userId=${habit['userId']}, title=${habit['title']}, status=${habit['status']}',
      );
    }

    print('\n====================================\n');
  }

  /// Debug: Print data for specific user
  static Future<void> debugPrintUserData(int userId) async {
    final db = await database;

    print('\n========== USER DATA DEBUG (userId: $userId) ==========');

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

  // ------------------ App Lock Methods ------------------

  /// Get app lock settings for a user
  static Future<Map<String, dynamic>?> getAppLock(int userId) async {
    final db = await database;
    final result = await db.query(
      'app_lock',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  /// Save app lock settings
  static Future<void> saveAppLock({
    required int userId,
    required String lockType,
    required String lockValue,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'app_lock',
      {
        'userId': userId,
        'lockType': lockType,
        'lockValue': lockValue,
        'createdAt': now,
        'updatedAt': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove app lock
  static Future<void> removeAppLock(int userId) async {
    final db = await database;
    await db.delete(
      'app_lock',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ------------------ Utilities ------------------

  /// Clear all tables
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('journals');
    await db.delete('habits');
    await db.delete('home_status');
    await db.delete('daily_moods');
    await db.delete('app_lock');
    await db.delete('users');
  }

  /// Close the database
  static Future<void> close() async {
    final db = _database;
    await db?.close();
    _database = null;
  }

  /// Create a demo user with demo data if no users exist
  /// Create a demo user with comprehensive demo data
static Future<int> createDemoUserWithData() async {
  final db = await database;

  // Check if demo user already exists
  final existingDemo = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: ['demo@riseapp.com'],
    limit: 1,
  );

  int userId;
  if (existingDemo.isNotEmpty) {
    userId = existingDemo.first['id'] as int;
    print('Demo user already exists with ID: $userId');
  } else {
    // Create demo user
    userId = await db.insert('users', {
      'name': 'Demo',
      'email': 'demo@riseapp.com',
      'password': 'demo123',
      'totalPoints': 450,
      'stars': 15,
    });
    print('Created demo user with ID: $userId');
  }

  // Clear existing demo data for this user
  await db.delete('home_status', where: 'userId = ?', whereArgs: [userId]);
  await db.delete('daily_moods', where: 'userId = ?', whereArgs: [userId]);
  await db.delete('journals', where: 'userId = ?', whereArgs: [userId]);
  await db.delete('habits', where: 'userId = ?', whereArgs: [userId]);
  await db.delete('app_lock', where: 'userId = ?', whereArgs: [userId]);

  final today = DateTime.now();
  final rnd = Random(42); // Fixed seed for consistent demo data

  // Mood data
  final moodLabels = ['happy', 'good', 'grateful', 'angry', 'sad'];
  final moodImages = [
    'assets/images/happy.png',
    'assets/images/good.png',
    'assets/images/grateful.png',
    'assets/images/angry.png',
    'assets/images/sad.png',
  ];

  // Journal prompts for variety
  final journalEntries = [
    'Started my day with a morning walk. The fresh air really helped clear my mind and set a positive tone for the day ahead.',
    'Had a productive work session today. Managed to complete two important tasks that I had been putting off. Feeling accomplished!',
    'Spent quality time with family this evening. Sometimes the simple moments are the most meaningful.',
    'Tried a new recipe for dinner tonight. It turned out better than expected! Cooking is becoming a therapeutic hobby.',
    'Feeling a bit overwhelmed with everything on my plate, but taking it one step at a time. Remember to breathe.',
    'Had an inspiring conversation with a friend today. It reminded me to focus on what truly matters in life.',
    'Completed my morning meditation and felt so centered. This habit is really making a difference in my daily life.',
    'Read an interesting article about personal growth. Key takeaway: progress over perfection.',
    'Enjoyed a peaceful afternoon in the park. Nature has a way of putting things into perspective.',
    'Reflected on my goals today. Feeling motivated to keep pushing forward despite the challenges.',
    'Had a challenging day but managed to stay positive. Proud of myself for not giving up.',
    'Discovered a great new podcast about mindfulness. Can\'t wait to listen to more episodes.',
  ];

  // Create data for the last 30 days
  for (int i = 29; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final isToday = i == 0;

    // Home status data
    final waterCount = isToday ? 3 : (rnd.nextInt(5) + 4); // 4-8 glasses
    final detoxProgress = isToday ? 0.3 : (rnd.nextDouble() * 0.6 + 0.3); // 0.3-0.9

    await db.insert('home_status', {
      'date': dateStr,
      'userId': userId,
      'water_count': waterCount,
      'water_goal': 8,
      'detox_progress': detoxProgress,
    });

    // Daily mood (mostly positive moods)
    final moodIndex = isToday ? 1 : (rnd.nextInt(10) < 7 ? rnd.nextInt(2) : rnd.nextInt(3) + 2);
    final actualMoodIndex = moodIndex.clamp(0, 4);
    
    await db.insert('daily_moods', {
      'userId': userId,
      'date': dateStr,
      'moodImage': moodImages[actualMoodIndex],
      'moodLabel': moodLabels[actualMoodIndex],
      'createdAt': date.toIso8601String(),
      'updatedAt': date.toIso8601String(),
    });

    // Add journal entries (about 60% of days)
    if (rnd.nextInt(10) < 6) {
      final entryIndex = rnd.nextInt(journalEntries.length);
      final hour = rnd.nextInt(12) + 8; // 8 AM - 8 PM
      final minute = rnd.nextInt(60);
      final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      await db.insert('journals', {
        'userId': userId,
        'date': dateStr,
        'time': timeStr,
        'mood': moodImages[actualMoodIndex],
        'text': journalEntries[entryIndex],
        'title': isToday ? 'Today\'s Thoughts' : null,
        'imagePath': null,
        'voicePath': null,
        'backgroundImage': null,
        'fontFamily': null,
        'textColor': null,
        'fontSize': null,
        'attachedImages': null,
        'stickers': null,
      });
    }
  }

  // Create varied habits
  final now = DateTime.now();
  final createdDateStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final habits = [
    {
      'title': 'Morning Meditation',
      'description': 'Start the day with 10 minutes of mindfulness meditation',
      'frequency': 'daily',
      'status': 'active',
      'Doitat': '07:00',
      'points': 10,
    },
    {
      'title': 'Drink 8 Glasses of Water',
      'description': 'Stay hydrated throughout the day',
      'frequency': 'daily',
      'status': 'active',
      'Doitat': '09:00',
      'points': 5,
    },
    {
      'title': 'Evening Reading',
      'description': 'Read for at least 30 minutes before bed',
      'frequency': 'daily',
      'status': 'active',
      'Doitat': '21:00',
      'points': 10,
    },
    {
      'title': 'Exercise',
      'description': 'Get at least 30 minutes of physical activity',
      'frequency': 'daily',
      'status': 'active',
      'Doitat': '06:30',
      'points': 15,
    },
    {
      'title': 'Gratitude Journal',
      'description': 'Write down three things you\'re grateful for',
      'frequency': 'daily',
      'status': 'active',
      'Doitat': '22:00',
      'points': 8,
    },
    {
      'title': 'Weekly Review',
      'description': 'Review your week and plan for the next one',
      'frequency': 'weekly',
      'status': 'active',
      'Doitat': '18:00',
      'points': 20,
    },
    {
      'title': 'Deep Work Session',
      'description': 'Focus on important tasks without distractions',
      'frequency': 'daily',
      'status': 'active',
      'Doitat': '10:00',
      'points': 15,
    },
    {
      'title': 'Healthy Breakfast',
      'description': 'Start your day with a nutritious meal',
      'frequency': 'daily',
      'status': 'active',
      'Doitat': '08:00',
      'points': 5,
    },
  ];

  for (var habit in habits) {
    await db.insert('habits', {
      'userId': userId,
      'title': habit['title'],
      'description': habit['description'],
      'frequency': habit['frequency'],
      'status': habit['status'],
      'createdDate': createdDateStr,
      'lastUpdated': createdDateStr,
      'Doitat': habit['Doitat'],
      'points': habit['points'],
    });
  }

  print('Demo data created successfully for user: $userId');
  return userId;
}

/// Initialize demo data if no users exist (kept for backward compatibility)
static Future<void> initializeDemoData() async {
  final db = await database;

  final userCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) as c FROM users'),
      ) ??
      0;

  if (userCount != 0) return;

  await createDemoUserWithData();
}
}
