// lib/data/repo/home_repo.dart
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_helper.dart';

// Simple model used by the repo
class HomeStatus {
  final int waterCount;
  final int waterGoal;
  final double detoxProgress;

  const HomeStatus({
    required this.waterCount,
    required this.waterGoal,
    required this.detoxProgress,
  });
}

// Abstract repo: Cubit talks to this, not directly to DB
abstract class AbstractHomeRepo {
  Future<HomeStatus> loadTodayStatus();
  Future<void> saveStatus(HomeStatus status);

  static AbstractHomeRepo getInstance() => _HomeRepoImpl();
}

class _HomeRepoImpl extends AbstractHomeRepo {
  @override
  Future<HomeStatus> loadTodayStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId == null) {
      // Return default values if no user is logged in
      return HomeStatus(
        waterCount: 0,
        waterGoal: 8,
        detoxProgress: 0,
      );
    }

    final db = await DBHelper.database;
    final today = _getTodayString();

    final result = await db.query(
      'home_status',
      where: 'date = ? AND userId = ?',
      whereArgs: [today, userId],
      limit: 1,
    );

    if (result.isEmpty) {
      // Create a new entry for today
      await db.insert('home_status', {
        'date': today,
        'userId': userId,
        'water_count': 0,
        'water_goal': 8,
        'detox_progress': 0.0,
      });

      return HomeStatus(
        waterCount: 0,
        waterGoal: 8,
        detoxProgress: 0,
      );
    }

    final row = result.first;
    return HomeStatus(
      waterCount: (row['water_count'] as int?) ?? 0,
      waterGoal: (row['water_goal'] as int?) ?? 8,
      detoxProgress: (row['detox_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Future<void> saveStatus(HomeStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId == null) return;

    final db = await DBHelper.database;
    final today = _getTodayString();

    await db.insert(
      'home_status',
      {
        'date': today,
        'userId': userId,
        'water_count': status.waterCount,
        'water_goal': status.waterGoal,
        'detox_progress': status.detoxProgress,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}