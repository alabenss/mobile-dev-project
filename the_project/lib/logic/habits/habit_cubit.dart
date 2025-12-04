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
      // Check if habit with same title AND frequency already exists
      final exists = await _repository.habitExistsWithFrequency(
        habit.title, 
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

  /// Mark a habit as completed (awards points)
  Future<void> completeHabit(String title) async {
    try {
      await _repository.updateHabitStatus(title, 'completed');
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Mark a habit as skipped
  Future<void> skipHabit(String title) async {
    try {
      await _repository.updateHabitStatus(title, 'skipped');
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Reset a habit back to active
  Future<void> resetHabit(String title) async {
    try {
      await _repository.updateHabitStatus(title, 'active');
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String title) async {
    try {
      await _repository.deleteHabit(title);
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

  /// Get completed habits count
  Future<int> getCompletedCount() async {
    return await _repository.getCompletedHabitsCount();
  }

  /// Clear any error message
  void clearError() {
    emit(state.copyWith(error: null));
  }
}