import 'package:flutter_bloc/flutter_bloc.dart';
import 'habit_state.dart';
import '../../models/habit_model.dart';
import '../../database/repo/habit_repo.dart';

class HabitCubit extends Cubit<HabitState> {
  final HabitRepository _repository;

  HabitCubit(this._repository) : super(const HabitState());

  /// Load all habits from the database
  Future<void> loadHabits() async {
    emit(state.copyWith(isLoading: true));
    try {
      final habits = await _repository.getAllHabits();
      emit(state.copyWith(habits: habits, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    try {
      // Check if habit with same habitKey AND frequency already exists
      final exists = await _repository.habitExistsWithFrequency(
        habit.habitKey, 
        habit.frequency
      );
      
      if (exists) {
        emit(state.copyWith(
          error: 'This habit already exists with ${habit.frequency} frequency!'
        ));
        return;
      }

      // Insert into database
      await _repository.insertHabit(habit);
      
      // Reload all habits
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Mark a habit as completed (awards points) - uses habitKey
  Future<void> completeHabit(String habitKey) async {
    try {
      await _repository.updateHabitStatus(habitKey, 'completed');
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Mark a habit as skipped - uses habitKey
  Future<void> skipHabit(String habitKey) async {
    try {
      await _repository.updateHabitStatus(habitKey, 'skipped');
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Reset a habit back to active - uses habitKey
  Future<void> resetHabit(String habitKey) async {
    try {
      await _repository.updateHabitStatus(habitKey, 'active');
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Delete a habit - uses habitKey
  Future<void> deleteHabit(String habitKey) async {
    try {
      await _repository.deleteHabit(habitKey);
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Reset all daily habits (call this at the start of a new day)
  Future<void> resetDailyHabits() async {
    try {
      await _repository.resetDailyHabits();
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Restore streak for a habit using points
  Future<bool> restoreStreak(String habitKey) async {
    try {
      final success = await _repository.restoreStreak(habitKey);
      if (success) {
        await loadHabits();
      }
      return success;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Get completed habits count
  Future<int> getCompletedCount() async {
    return await _repository.getCompletedHabitsCount();
  }

  /// Clear any error message
  void clearError() {
    emit(state.copyWith(error: null));
  }
}