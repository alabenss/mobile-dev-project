import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_mood_state.dart';
import '../../database/repo/daily_mood_repository.dart';

class DailyMoodCubit extends Cubit<DailyMoodState> {
  final DailyMoodRepository _repository;

  DailyMoodCubit(this._repository) : super(DailyMoodState());

  /// Reset in-memory state only
  void resetInMemory() {
    emit(DailyMoodState());
  }

  /// Load today's mood from database
  Future<void> loadTodayMood() async {
    try {
      emit(state.copyWith(status: DailyMoodStatus.loading));

      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: DailyMoodStatus.error,
          error: 'User not logged in',
          clearMood: true,
        ));
        return;
      }

      print('🔄 DailyMoodCubit: Loading mood for userId: $userId');

      final mood = await _repository.getTodayMood(userId);

      if (mood != null) {
        print('✅ DailyMoodCubit: Mood loaded: ${mood.moodLabel}');
        emit(state.copyWith(
          status: DailyMoodStatus.loaded,
          todayMood: mood,
          clearError: true,
        ));
      } else {
        print('ℹ️ DailyMoodCubit: No mood found for today');
        emit(state.copyWith(
          status: DailyMoodStatus.loaded,
          clearMood: true,
          clearError: true,
        ));
      }
    } catch (e) {
      print('❌ DailyMoodCubit: Error loading mood: $e');
      emit(state.copyWith(
        status: DailyMoodStatus.error,
        error: 'Failed to load mood: $e',
        clearMood: true,
      ));
    }
  }

  /// Save or update today's mood
  Future<void> setTodayMood(String moodImage, String moodLabel) async {
    try {
      emit(state.copyWith(status: DailyMoodStatus.loading));

      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: DailyMoodStatus.error,
          error: 'User not logged in',
        ));
        return;
      }

      print('💾 DailyMoodCubit: Saving mood - userId: $userId, label: $moodLabel');

      // Save to backend
      await _repository.saveTodayMood(
        userId: userId,
        moodImage: moodImage,
        moodLabel: moodLabel,
      );

      print('✅ DailyMoodCubit: Mood saved to backend');

      // Reload to get the updated mood with timestamps
      await Future.delayed(const Duration(milliseconds: 300)); // Small delay for backend
      final updatedMood = await _repository.getTodayMood(userId);

      if (updatedMood != null) {
        print('✅ DailyMoodCubit: Mood reloaded successfully');
        emit(state.copyWith(
          status: DailyMoodStatus.loaded,
          todayMood: updatedMood,
          clearError: true,
        ));
      } else {
        print('⚠️ DailyMoodCubit: Mood saved but failed to reload');
        emit(state.copyWith(
          status: DailyMoodStatus.error,
          error: 'Mood saved but failed to reload',
        ));
      }
    } catch (e) {
      print('❌ DailyMoodCubit: Error saving mood: $e');
      emit(state.copyWith(
        status: DailyMoodStatus.error,
        error: 'Failed to save mood: $e',
      ));
    }
  }

  /// Clear today's mood (delete from backend)
  Future<void> clearTodayMood() async {
    await deleteTodayMood();
  }

  /// Delete today's mood
  Future<void> deleteTodayMood() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not logged in'));
        return;
      }

      print('🗑️ DailyMoodCubit: Deleting mood for userId: $userId');

      await _repository.deleteTodayMood(userId);

      print('✅ DailyMoodCubit: Mood deleted successfully');

      emit(state.copyWith(
        status: DailyMoodStatus.loaded,
        clearMood: true,
        clearError: true,
      ));
    } catch (e) {
      print('❌ DailyMoodCubit: Error deleting mood: $e');
      emit(state.copyWith(error: 'Failed to delete mood: $e'));
    }
  }

  /// Get userId from SharedPreferences
  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try different possible keys
      int? userId;
      
      if (prefs.containsKey('userId')) {
        userId = prefs.getInt('userId');
      } else if (prefs.containsKey('user_id')) {
        userId = prefs.getInt('user_id');
      } else if (prefs.containsKey('id')) {
        userId = prefs.getInt('id');
      } else if (prefs.containsKey('auth_user_id')) {
        userId = prefs.getInt('auth_user_id');
      } else if (prefs.containsKey('loggedInUserId')) {
        userId = prefs.getInt('loggedInUserId');
      }

      return userId;
    } catch (e) {
      print('❌ DailyMoodCubit: Error getting userId: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}