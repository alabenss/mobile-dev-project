import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_mood_state.dart';
import '../../database/repo/daily_mood_repository.dart';

class DailyMoodCubit extends Cubit<DailyMoodState> {
  final DailyMoodRepository _repository;

  DailyMoodCubit(this._repository) : super(DailyMoodState());

  /// Load today's mood from database for the logged-in user
  Future<void> loadTodayMood() async {
    emit(state.copyWith(status: DailyMoodStatus.loading));

    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: DailyMoodStatus.error,
          error: 'User not logged in',
        ));
        return;
      }

      print('DailyMoodCubit: Loading mood for userId: $userId');
      
      final mood = await _repository.getTodayMood(userId);
      
      if (mood != null) {
        print('DailyMoodCubit: Found mood for user $userId: ${mood.moodLabel}');
      } else {
        print('DailyMoodCubit: No mood found for user $userId');
      }
      
      emit(state.copyWith(
        status: DailyMoodStatus.loaded,
        todayMood: mood,
      ));
    } catch (e) {
      print('DailyMoodCubit: Error loading mood: $e');
      emit(state.copyWith(
        status: DailyMoodStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Save or update today's mood for the logged-in user
  Future<void> setTodayMood(String moodImage, String moodLabel) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not logged in'));
        return;
      }

      print('DailyMoodCubit: Saving mood for userId: $userId - $moodLabel');

      await _repository.saveTodayMood(
        userId: userId,
        moodImage: moodImage,
        moodLabel: moodLabel,
      );

      // Reload mood to get updated data
      await loadTodayMood();
    } catch (e) {
      print('DailyMoodCubit: Error saving mood: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Clear today's mood (reset) for the logged-in user
  Future<void> clearTodayMood() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not logged in'));
        return;
      }

      await _repository.deleteTodayMood(userId);
      
      emit(state.copyWith(
        status: DailyMoodStatus.loaded,
        clearMood: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Get userId from SharedPreferences (logged-in user)
  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      print('DailyMoodCubit: Retrieved userId from SharedPreferences: $userId');
      
      // DEBUG: Print all keys in SharedPreferences
      final allKeys = prefs.getKeys();
      print('DailyMoodCubit: All SharedPreferences keys: $allKeys');
      
      return userId;
    } catch (e) {
      print('DailyMoodCubit: Error getting userId: $e');
      return null;
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}