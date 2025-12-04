// lib/logic/home/home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';
import '../../database/repo/home_repo.dart';
import '../../database/repo/habit_repo.dart';
import '../../models/habit_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final AbstractHomeRepo _repo;
  final HabitRepository _habitRepo;

  HomeCubit(this._repo, this._habitRepo) : super(const HomeState());

  // Load initial values (water, detox, mood, userName, and daily habits)
  Future<void> loadInitial({String? userName}) async {
    final status = await _repo.loadTodayStatus();
    
    // Get daily habits
    final dailyHabits = await _habitRepo.getHabitsByFrequency('Daily');
    
    emit(state.copyWith(
      waterCount: status.waterCount,
      waterGoal: status.waterGoal,
      detoxProgress: status.detoxProgress,
      selectedMoodImage: status.moodImage,
      selectedMoodLabel: status.moodLabel,
      selectedMoodTime: status.moodTime,
      userName: userName ?? state.userName,
      dailyHabits: dailyHabits,
    ));
  }

  Future<void> _persist() async {
    final status = HomeStatus(
      waterCount: state.waterCount,
      waterGoal: state.waterGoal,
      detoxProgress: state.detoxProgress,
      moodImage: state.selectedMoodImage,
      moodLabel: state.selectedMoodLabel,
      moodTime: state.selectedMoodTime,
    );
    await _repo.saveStatus(status);
  }

  // mood – now persisted
  Future<void> setMood(String moodImage, String moodLabel) async {
    final isReset = moodImage.isEmpty && moodLabel.isEmpty;
    if (isReset) {
      emit(state.copyWith(clearMood: true));
    } else {
      emit(state.copyWith(
        selectedMoodImage: moodImage,
        selectedMoodLabel: moodLabel,
        selectedMoodTime: DateTime.now(),
      ));
    }
    await _persist();
  }

  // water – persisted
  Future<void> incrementWater() async {
    if (state.waterCount < state.waterGoal) {
      emit(state.copyWith(waterCount: state.waterCount + 1));
      await _persist();
    }
  }

  Future<void> decrementWater() async {
    if (state.waterCount > 0) {
      emit(state.copyWith(waterCount: state.waterCount - 1));
      await _persist();
    }
  }

  // digital detox – persisted
  Future<void> increaseDetox() async {
    var newProgress = state.detoxProgress + 0.1;
    if (newProgress > 1) newProgress = 1;
    emit(state.copyWith(detoxProgress: newProgress));
    await _persist();
  }

  Future<void> resetDetox() async {
    emit(state.copyWith(detoxProgress: 0));
    await _persist();
  }

  // Toggle habit completion
  Future<void> toggleHabitCompletion(String title, bool currentStatus) async {
    if (currentStatus) {
      // If already done, reset it
      await _habitRepo.updateHabitStatus(title, 'active');
    } else {
      // Mark as completed
      await _habitRepo.updateHabitStatus(title, 'completed');
    }
    
    // Reload daily habits to reflect changes
    final dailyHabits = await _habitRepo.getHabitsByFrequency('Daily');
    emit(state.copyWith(dailyHabits: dailyHabits));
  }
  
  // Reload daily habits (call this when returning from habits screen)
  Future<void> reloadDailyHabits() async {
    final dailyHabits = await _habitRepo.getHabitsByFrequency('Daily');
    emit(state.copyWith(dailyHabits: dailyHabits));
  }
}