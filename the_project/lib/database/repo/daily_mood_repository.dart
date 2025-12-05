import '../db_helper.dart';
import '../../views/widgets/journal/daily_mood_model.dart';

class DailyMoodRepository {
  /// Save or update today's mood for the user
  Future<void> saveTodayMood({
    required int userId,
    required String moodImage,
    required String moodLabel,
  }) async {
    final db = await DBHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    // Check if mood already exists for today
    final existing = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Update existing mood
      await db.update(
        'daily_moods',
        {
          'moodImage': moodImage,
          'moodLabel': moodLabel,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'userId = ? AND date = ?',
        whereArgs: [userId, todayStr],
      );
    } else {
      // Insert new mood
      await db.insert('daily_moods', {
        'userId': userId,
        'date': todayStr,
        'moodImage': moodImage,
        'moodLabel': moodLabel,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Get today's mood for the user
  Future<DailyMoodModel?> getTodayMood(int userId) async {
    final db = await DBHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    final results = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
      limit: 1,
    );

    if (results.isEmpty) return null;
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
    final db = await DBHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    await db.delete(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
    );
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