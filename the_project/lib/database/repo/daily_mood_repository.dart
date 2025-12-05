import '../db_helper.dart';
import '../../views/widgets/journal/daily_mood_model.dart';

class DailyMoodRepository {
  /// Save or update today's mood for the user
  Future<void> saveTodayMood({
    required int userId,
    required String moodImage,
    required String moodLabel,
  }) async {
    print('DailyMoodRepository: Saving mood for userId: $userId');
    
    final db = await DBHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    print('DailyMoodRepository: Today date string: $todayStr');

    // Check if mood already exists for today
    final existing = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
      limit: 1,
    );

    print('DailyMoodRepository: Existing moods found: ${existing.length}');

    if (existing.isNotEmpty) {
      // Update existing mood
      print('DailyMoodRepository: Updating existing mood for userId: $userId');
      final result = await db.update(
        'daily_moods',
        {
          'moodImage': moodImage,
          'moodLabel': moodLabel,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'userId = ? AND date = ?',
        whereArgs: [userId, todayStr],
      );
      print('DailyMoodRepository: Update result - rows affected: $result');
    } else {
      // Insert new mood
      print('DailyMoodRepository: Inserting new mood for userId: $userId');
      final result = await db.insert('daily_moods', {
        'userId': userId,
        'date': todayStr,
        'moodImage': moodImage,
        'moodLabel': moodLabel,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('DailyMoodRepository: Insert result - new id: $result');
    }

    // Verify the save worked
    final verify = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
    );
    print('DailyMoodRepository: Verification - found ${verify.length} records');
    if (verify.isNotEmpty) {
      print('DailyMoodRepository: Saved mood data: ${verify.first}');
    }
  }

  /// Get today's mood for the user
  Future<DailyMoodModel?> getTodayMood(int userId) async {
    final db = await DBHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    print('DailyMoodRepository: Getting mood for userId: $userId, date: $todayStr');

    final results = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
      limit: 1,
    );

    print('DailyMoodRepository: Query returned ${results.length} results');
    
    if (results.isEmpty) {
      // DEBUG: Check if there are ANY moods for this user
      final allUserMoods = await db.query(
        'daily_moods',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      print('DailyMoodRepository: Total moods for userId $userId: ${allUserMoods.length}');
      if (allUserMoods.isNotEmpty) {
        print('DailyMoodRepository: User moods dates: ${allUserMoods.map((m) => m['date']).toList()}');
      }
      
      // DEBUG: Check if there are moods for today with ANY userId
      final allTodayMoods = await db.query(
        'daily_moods',
        where: 'date = ?',
        whereArgs: [todayStr],
      );
      print('DailyMoodRepository: Total moods for date $todayStr: ${allTodayMoods.length}');
      if (allTodayMoods.isNotEmpty) {
        print('DailyMoodRepository: Today moods userIds: ${allTodayMoods.map((m) => m['userId']).toList()}');
      }
      
      return null;
    }
    
    print('DailyMoodRepository: Found mood: ${results.first}');
    return DailyMoodModel.fromMap(results.first);
  }

  /// Get mood for a specific date
  Future<DailyMoodModel?> getMoodByDate(int userId, DateTime date) async {
    final db = await DBHelper.database;
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dateStr = _formatDate(dateOnly);

    final results = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, dateStr],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return DailyMoodModel.fromMap(results.first);
  }

  /// Delete today's mood
  Future<void> deleteTodayMood(int userId) async {
    print('DailyMoodRepository: Deleting mood for userId: $userId');
    
    final db = await DBHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    final result = await db.delete(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
    );
    
    print('DailyMoodRepository: Delete result - rows affected: $result');
  }

  /// Get all moods for a user
  Future<List<DailyMoodModel>> getAllMoods(int userId) async {
    final db = await DBHelper.database;
    final results = await db.query(
      'daily_moods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return results.map((row) => DailyMoodModel.fromMap(row)).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}