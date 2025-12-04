// lib/data/repo/home_repo.dart
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_helper.dart';

// Simple model used by the repo
class HomeStatus {
  final int waterCount;
  final int waterGoal;
  final double detoxProgress;

  final String? moodImage;
  final String? moodLabel;
  final DateTime? moodTime;

  const HomeStatus({
    required this.waterCount,
    required this.waterGoal,
    required this.detoxProgress,
    this.moodImage,
    this.moodLabel,
    this.moodTime,
  });
}

// Abstract repo: Cubit talks to this, not directly to DB
abstract class AbstractHomeRepo {
  Future<HomeStatus> loadTodayStatus();
  Future<void> saveStatus(HomeStatus status);

  // Singleton (like in the lectures)
  static AbstractHomeRepo? _instance;
  static AbstractHomeRepo getInstance() {
    _instance ??= HomeRepoDb();
    return _instance!;
  }
}

class HomeRepoDb implements AbstractHomeRepo {
  static const String tableName = 'home_status';

  /// Get the current logged-in user's ID
  Future<int> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId == null) {
      // Fallback to default user if no one is logged in
      return await DBHelper.ensureDefaultUser();
    }
    
    return userId;
  }

  // yyyy-MM-dd string for "today"
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<HomeStatus> loadTodayStatus() async {
    final Database db = await DBHelper.database;
    final userId = await _getCurrentUserId();
    final dateKey = _todayKey();

    final result = await db.query(
      tableName,
      where: 'date = ? AND userId = ?',
      whereArgs: [dateKey, userId],
      limit: 1,
    );

    if (result.isEmpty) {
      // default values for a new day
      return const HomeStatus(
        waterCount: 4,
        waterGoal: 8,
        detoxProgress: 0.35,
        moodImage: null,
        moodLabel: null,
        moodTime: null,
      );
    }

    final row = result.first;

    DateTime? parsedMoodTime;
    final moodTimeStr = row['mood_time'] as String?;
    if (moodTimeStr != null) {
      parsedMoodTime = DateTime.tryParse(moodTimeStr);
    }

    return HomeStatus(
      waterCount: row['water_count'] as int,
      waterGoal: row['water_goal'] as int,
      detoxProgress: (row['detox_progress'] as num).toDouble(),
      moodImage: row['mood_image'] as String?,
      moodLabel: row['mood_label'] as String?,
      moodTime: parsedMoodTime,
    );
  }

  @override
  Future<void> saveStatus(HomeStatus status) async {
    final Database db = await DBHelper.database;
    final userId = await _getCurrentUserId();
    final dateKey = _todayKey();

    await db.insert(
      tableName,
      {
        'date': dateKey,
        'userId': userId,
        'water_count': status.waterCount,
        'water_goal': status.waterGoal,
        'detox_progress': status.detoxProgress,
        'mood_label': status.moodLabel,
        'mood_image': status.moodImage,
        'mood_time': status.moodTime?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}