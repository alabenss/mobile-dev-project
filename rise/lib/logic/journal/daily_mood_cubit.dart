import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_mood_state.dart';
import '../../database/repo/daily_mood_repository.dart';

class DailyMoodCubit extends Cubit<DailyMoodState> {
  final DailyMoodRepository _repository;

  DailyMoodCubit(this._repository) : super(DailyMoodState());

  /// Clears only in-memory mood state (does NOT delete anythingg from the database)
  /// (We are NOT calling this from UI)
  void resetInMemory() {
    emit(DailyMoodState());
  }

  /// Load today's mood from database for the logged-in user
  Future<void> loadTodayMood() async {
    emit(state.copyWith(status: DailyMoodStatus.loading));

    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: DailyMoodStatus.error,
          error: 'User not logged in',
          clearMood: true,
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
        clearMood: mood == null, // ✅ clears mood if this user has none
        clearError: true,
      ));
    } catch (e) {
      print('DailyMoodCubit: Error loading mood: $e');
      emit(state.copyWith(
        status: DailyMoodStatus.error,
        error: e.toString(),
        clearMood: true,
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

      // Reload mood after saving
      final updatedMood = await _repository.getTodayMood(userId);

      emit(state.copyWith(
        status: DailyMoodStatus.loaded,
        todayMood: updatedMood,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// ✅ This is required because your UI calls clearTodayMood()
  /// It deletes today's mood for THIS logged-in user, then clears state.
  Future<void> clearTodayMood() async {
    await deleteTodayMood();
  }

  /// Delete today's mood for the logged-in user
  Future<void> deleteTodayMood() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not logged in'));
        return;
      }

      print('DailyMoodCubit: Deleting mood for userId: $userId');

      await _repository.deleteTodayMood(userId);

      emit(state.copyWith(
        status: DailyMoodStatus.loaded,
        clearMood: true,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Get userId from SharedPreferences (logged-in user)
  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Debug: Print all keys and values
      final allKeys = prefs.getKeys();
      print('DailyMoodCubit: All SharedPreferences keys: $allKeys');

      // Try different possible keys for userId
      int? userId;

      // Check for 'userId' key
      if (prefs.containsKey('userId')) {
        userId = prefs.getInt('userId');
        print('DailyMoodCubit: Found userId in "userId" key: $userId');
      }
      // Check for 'user_id' key
      else if (prefs.containsKey('user_id')) {
        userId = prefs.getInt('user_id');
        print('DailyMoodCubit: Found userId in "user_id" key: $userId');
      }
      // Check for 'id' key
      else if (prefs.containsKey('id')) {
        userId = prefs.getInt('id');
        print('DailyMoodCubit: Found userId in "id" key: $userId');
      }
      // Check for 'auth_user_id' key
      else if (prefs.containsKey('auth_user_id')) {
        userId = prefs.getInt('auth_user_id');
        print('DailyMoodCubit: Found userId in "auth_user_id" key: $userId');
      }
      // Check for 'loggedInUserId' key
      else if (prefs.containsKey('loggedInUserId')) {
        userId = prefs.getInt('loggedInUserId');
        print('DailyMoodCubit: Found userId in "loggedInUserId" key: $userId');
      }

      // Debug: Print the selected userId
      print('DailyMoodCubit: Selected userId: $userId');

      final allKeysAgain = prefs.getKeys();
      print('DailyMoodCubit: All SharedPreferences keys: $allKeysAgain');

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
