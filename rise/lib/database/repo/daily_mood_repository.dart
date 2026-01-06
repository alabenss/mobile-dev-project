// lib/data/repo/daily_mood_repository.dart
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../views/widgets/journal/daily_mood_model.dart';

class DailyMoodRepository {
  final ApiService _api = ApiService.instance;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Save or update today's mood for the user
  Future<void> saveTodayMood({
    required int userId,
    required String moodImage,
    required String moodLabel,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = _formatDate(today);

      print('DailyMoodRepository: Saving mood for userId: $userId, date: $todayStr');

      await _api.post(
        ApiConfig.MOODS_SAVE,
        {
          'userId': userId,
          'date': todayStr,
          'moodImage': moodImage,
          'moodLabel': moodLabel,
        },
      );

      print('DailyMoodRepository: Mood saved successfully');
    } catch (e) {
      print('DailyMoodRepository: Error saving mood: $e');
      rethrow;
    }
  }

  /// Get today's mood for the user
  Future<DailyMoodModel?> getTodayMood(int userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = _formatDate(today);

      print('DailyMoodRepository: Getting mood for userId: $userId, date: $todayStr');

      final response = await _api.get(
        ApiConfig.MOODS_TODAY,
        params: {
          'userId': userId.toString(),
          'date': todayStr,
        },
      );

      if (response['success'] == true && response['mood'] != null) {
        print('DailyMoodRepository: Found mood: ${response['mood']}');
        return DailyMoodModel.fromMap(response['mood']);
      }

      print('DailyMoodRepository: No mood found for today');
      return null;
    } catch (e) {
      print('DailyMoodRepository: Error getting mood: $e');
      return null;
    }
  }

  /// Get mood for a specific date
  Future<DailyMoodModel?> getMoodByDate(int userId, DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final dateStr = _formatDate(dateOnly);

      print('DailyMoodRepository: Getting mood for date: $dateStr');

      final response = await _api.get(
        ApiConfig.MOODS_TODAY,
        params: {
          'userId': userId.toString(),
          'date': dateStr,
        },
      );

      if (response['success'] == true && response['mood'] != null) {
        return DailyMoodModel.fromMap(response['mood']);
      }

      return null;
    } catch (e) {
      print('DailyMoodRepository: Error getting mood by date: $e');
      return null;
    }
  }

  /// Delete today's mood
  Future<void> deleteTodayMood(int userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = _formatDate(today);

      print('DailyMoodRepository: Deleting mood for userId: $userId, date: $todayStr');

      await _api.delete(
        ApiConfig.MOODS_DELETE,
        params: {
          'userId': userId.toString(),
          'date': todayStr,
        },
      );

      print('DailyMoodRepository: Mood deleted successfully');
    } catch (e) {
      print('DailyMoodRepository: Error deleting mood: $e');
      rethrow;
    }
  }

  /// Get all moods for a user
  Future<List<DailyMoodModel>> getAllMoods(int userId) async {
    try {
      print('DailyMoodRepository: Getting all moods for userId: $userId');

      final response = await _api.get(
        ApiConfig.MOODS_GET_ALL,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['moods'] != null) {
        final moodsList = response['moods'] as List;
        return moodsList.map((mood) => DailyMoodModel.fromMap(mood)).toList();
      }

      return [];
    } catch (e) {
      print('DailyMoodRepository: Error getting all moods: $e');
      return [];
    }
  }

  /// Get moods for a specific month
  Future<List<DailyMoodModel>> getMoodsByMonth(int userId, int month, int year) async {
    try {
      print('DailyMoodRepository: Getting moods for month: $month, year: $year');

      final response = await _api.get(
        ApiConfig.MOODS_GET_BY_MONTH,
        params: {
          'userId': userId.toString(),
          'month': month.toString(),
          'year': year.toString(),
        },
      );

      if (response['success'] == true && response['moods'] != null) {
        final moodsList = response['moods'] as List;
        return moodsList.map((mood) => DailyMoodModel.fromMap(mood)).toList();
      }

      return [];
    } catch (e) {
      print('DailyMoodRepository: Error getting moods by month: $e');
      return [];
    }
  }
}