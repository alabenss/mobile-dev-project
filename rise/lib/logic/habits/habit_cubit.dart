import 'package:flutter_bloc/flutter_bloc.dart';
import 'habit_state.dart';
import '../../models/habit_model.dart';
import '../../database/repo/habit_repo.dart';

class HabitCubit extends Cubit<HabitState> {
  final HabitRepository _repository;

  HabitCubit(this._repository) : super(const HabitState());

  /// Load all habits for all frequencies (Daily, Weekly, Monthly) with date filtering
  /// This is the recommended method - fetches all habits with proper date filtering
  Future<void> loadHabits() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Fetch all three frequencies in parallel for better performance
      final results = await Future.wait([
        _repository.getHabitsByFrequencyAndDate('Daily'),
        _repository.getHabitsByFrequencyAndDate('Weekly'),
        _repository.getHabitsByFrequencyAndDate('Monthly'),
      ]);
      
      // Combine all habits
      final allHabits = <Habit>[];
      allHabits.addAll(results[0]); // Daily
      allHabits.addAll(results[1]); // Weekly
      allHabits.addAll(results[2]); // Monthly
      
      emit(state.copyWith(habits: allHabits, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Load habits filtered by specific frequency and date range
  Future<void> loadHabitsByFrequency(String frequency) async {
    emit(state.copyWith(isLoading: true));
    try {
      final habits = await _repository.getHabitsByFrequencyAndDate(frequency);
      
      // Update state with frequency-specific habits
      // Merge with existing habits from other frequencies
      final updatedHabits = <Habit>[];
      
      // Keep habits from other frequencies
      for (var habit in state.habits) {
        if (habit.frequency != frequency) {
          updatedHabits.add(habit);
        }
      }
      
      // Add newly fetched habits
      updatedHabits.addAll(habits);
      
      emit(state.copyWith(habits: updatedHabits, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    try {
      // Check if a habit already exists in the current period for this frequency
      final exists = await _repository.habitExistsInCurrentPeriod(habit.frequency);
      
      if (exists) {
        String periodName = 'day';
        if (habit.frequency == 'Weekly') periodName = 'week';
        if (habit.frequency == 'Monthly') periodName = 'month';
        
        emit(state.copyWith(
          error: 'You can only add one ${habit.frequency} habit per $periodName!'
        ));
        return;
      }

      // Insert into database
      await _repository.insertHabit(habit);
      
      // Reload all habits to ensure proper filtering
      await loadHabits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Mark a habit as completed (awards points) - uses habitKey
  Future<void> completeHabit(String habitKey) async {
    try {
      await _repository.updateHabitStatus(habitKey, 'completed');
      
      // Find the habit to determine its frequency
      final habit = state.habits.firstWhere(
        (h) => h.habitKey == habitKey,
        orElse: () => state.habits.first,
      );
      
      // Reload habits for that frequency
      await loadHabitsByFrequency(habit.frequency);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Mark a habit as skipped - uses habitKey
  Future<void> skipHabit(String habitKey) async {
    try {
      await _repository.updateHabitStatus(habitKey, 'skipped');
      
      // Find the habit to determine its frequency
      final habit = state.habits.firstWhere(
        (h) => h.habitKey == habitKey,
        orElse: () => state.habits.first,
      );
      
      // Reload habits for that frequency
      await loadHabitsByFrequency(habit.frequency);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Reset a habit back to active - uses habitKey
  Future<void> resetHabit(String habitKey) async {
    try {
      await _repository.updateHabitStatus(habitKey, 'active');
      
      // Find the habit to determine its frequency
      final habit = state.habits.firstWhere(
        (h) => h.habitKey == habitKey,
        orElse: () => state.habits.first,
      );
      
      // Reload habits for that frequency
      await loadHabitsByFrequency(habit.frequency);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Delete a habit - uses habitKey
  Future<void> deleteHabit(String habitKey) async {
    try {
      // Find the habit to determine its frequency before deleting
      final habit = state.habits.firstWhere(
        (h) => h.habitKey == habitKey,
        orElse: () => state.habits.first,
      );
      
      await _repository.deleteHabit(habitKey);
      
      // Reload habits for that frequency
      await loadHabitsByFrequency(habit.frequency);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Reset all daily habits (call this at the start of a new day)
  Future<void> resetDailyHabits() async {
    try {
      await _repository.resetDailyHabits();
      await loadHabitsByFrequency('Daily');
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Restore streak for a habit using points
  Future<bool> restoreStreak(String habitKey) async {
    try {
      final success = await _repository.restoreStreak(habitKey);
      if (success) {
        // Find the habit to determine its frequency
        final habit = state.habits.firstWhere(
          (h) => h.habitKey == habitKey,
          orElse: () => state.habits.first,
        );
        
        // Reload habits for that frequency
        await loadHabitsByFrequency(habit.frequency);
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

  void clearHabits() {
    emit(HabitState(
      habits: [],
      isLoading: false,
      error: null,
    ));
  }
}