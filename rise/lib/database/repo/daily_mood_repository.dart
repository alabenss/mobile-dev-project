// lib/database/repo/daily_mood_repository.dart
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../views/widgets/journal/daily_mood_model.dart';
import '../../utils/timezone_helper.dart';

class DailyMoodRepository {
  final ApiService _api = ApiService.instance;

  /// Save or update today's mood for the user
  Future<void> saveTodayMood({
    required int userId,
    required String moodImage,
    required String moodLabel,
  }) async {
    try {
      // Get user's LOCAL today date (no time component)
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final todayStr = '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

      print('🕐 DEBUG - User local date: $todayStr');
      print('🕐 DEBUG - User local DateTime: $todayDate');
      print('💾 DailyMoodRepository: Saving mood for userId: $userId, date: $todayStr');

      await _api.post(
        ApiConfig.MOODS_SAVE,
        {
          'userId': userId,
          'date': todayStr,
          'moodImage': moodImage,
          'moodLabel': moodLabel,
        },
      );

      print('✅ DailyMoodRepository: Mood saved successfully for date: $todayStr');
    } catch (e) {
      print('❌ DailyMoodRepository: Error saving mood: $e');
      rethrow;
    }
  }

  /// Get today's mood for the user
  Future<DailyMoodModel?> getTodayMood(int userId) async {
    try {
      // Get user's LOCAL today date (no time component)
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final todayStr = '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

      print('🕐 DEBUG - Getting mood for LOCAL date: $todayStr');
      print('🔍 DailyMoodRepository: Getting mood for userId: $userId, date: $todayStr');

      final response = await _api.get(
        ApiConfig.MOODS_TODAY,
        params: {
          'userId': userId.toString(),
          'date': todayStr,
        },
      );

      print('📦 DEBUG - API Response: $response');

      if (response['success'] == true && response['mood'] != null) {
        print('✅ DailyMoodRepository: Found mood data');
        
        try {
          final mood = DailyMoodModel.fromMap(response['mood']);
          print('✅ DailyMoodRepository: Parsed mood successfully: ${mood.moodLabel}');
          print('🕐 DEBUG - Mood date from DB: ${mood.date}');
          print('🕐 DEBUG - Mood created_at (local): ${mood.createdAt}');
          print('🕐 DEBUG - Mood created_at (UTC): ${mood.createdAt.toUtc()}');
          return mood;
        } catch (e) {
          print('❌ DailyMoodRepository: Error parsing mood: $e');
          print('📦 Raw mood data: ${response['mood']}');
          return null;
        }
      }

      print('ℹ️ DailyMoodRepository: No mood found for today');
      return null;
    } catch (e) {
      print('❌ DailyMoodRepository: Error getting mood: $e');
      return null;
    }
  }

  /// Get mood for a specific date - NO CHANGES HERE
  Future<DailyMoodModel?> getMoodByDate(int userId, DateTime date) async {
    try {
      final dateStr = TimezoneHelper.formatDateForApi(date);

      print('🔍 DailyMoodRepository: Getting mood for date: $dateStr');

      final response = await _api.get(
        ApiConfig.MOODS_TODAY,
        params: {
          'userId': userId.toString(),
          'date': dateStr,
        },
      );

      if (response['success'] == true && response['mood'] != null) {
        try {
          return DailyMoodModel.fromMap(response['mood']);
        } catch (e) {
          print('❌ DailyMoodRepository: Error parsing mood by date: $e');
          return null;
        }
      }

      return null;
    } catch (e) {
      print('❌ DailyMoodRepository: Error getting mood by date: $e');
      return null;
    }
  }

  /// Delete today's mood - UPDATED to use local date
  Future<void> deleteTodayMood(int userId) async {
    try {
      // Get user's LOCAL today date (no time component)
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final todayStr = '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

      print('🗑️ DailyMoodRepository: Deleting mood for userId: $userId, date: $todayStr');

      await _api.delete(
        ApiConfig.MOODS_DELETE,
        params: {
          'userId': userId.toString(),
          'date': todayStr,
        },
      );

      print('✅ DailyMoodRepository: Mood deleted successfully for date: $todayStr');
    } catch (e) {
      print('❌ DailyMoodRepository: Error deleting mood: $e');
      rethrow;
    }
  }

  /// Get all moods for a user - NO CHANGES HERE
  Future<List<DailyMoodModel>> getAllMoods(int userId) async {
    try {
      print('📚 DailyMoodRepository: Getting all moods for userId: $userId');

      final response = await _api.get(
        ApiConfig.MOODS_GET_ALL,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['moods'] != null) {
        final moodsList = response['moods'] as List;
        final moods = <DailyMoodModel>[];
        
        for (var moodMap in moodsList) {
          try {
            moods.add(DailyMoodModel.fromMap(moodMap));
          } catch (e) {
            print('⚠️ DailyMoodRepository: Skipping invalid mood entry: $e');
          }
        }
        
        return moods;
      }

      return [];
    } catch (e) {
      print('❌ DailyMoodRepository: Error getting all moods: $e');
      return [];
    }
  }

  /// Get moods for a specific month - NO CHANGES HERE
  Future<List<DailyMoodModel>> getMoodsByMonth(int userId, int month, int year) async {
    try {
      print('📅 DailyMoodRepository: Getting moods for month: $month, year: $year');

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
        final moods = <DailyMoodModel>[];
        
        for (var moodMap in moodsList) {
          try {
            moods.add(DailyMoodModel.fromMap(moodMap));
          } catch (e) {
            print('⚠️ DailyMoodRepository: Skipping invalid mood entry: $e');
          }
        }
        
        return moods;
      }

      return [];
    } catch (e) {
      print('❌ DailyMoodRepository: Error getting moods by month: $e');
      return [];
    }
  }
}