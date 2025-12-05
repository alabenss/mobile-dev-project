// lib/logic/home/home_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';
import '../../database/repo/home_repo.dart';
import '../../database/repo/habit_repo.dart';

class HomeCubit extends Cubit<HomeState> {
  final AbstractHomeRepo _repo;
  final HabitRepository _habitRepo;
  Timer? _lockTimer;

  HomeCubit(this._repo, this._habitRepo) : super(const HomeState());

  @override
  Future<void> close() {
    _lockTimer?.cancel();
    return super.close();
  }

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

  // digital detox – with in-app lock only (simple and reliable)
  Future<void> increaseDetox() async {
    // Start the 1-minute lock
    final lockEndTime = DateTime.now().add(const Duration(minutes: 1));
    
    emit(state.copyWith(
      isPhoneLocked: true,
      lockEndTime: lockEndTime,
      permissionDenied: false,
    ));
    
    // Start timer to update and check completion
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.lockEndTime != null) {
        final now = DateTime.now();
        final difference = state.lockEndTime!.difference(now);
        
        if (difference.isNegative) {
          // Timer completed - increase progress
          timer.cancel();
          await _completeDetoxSession();
        } else {
          // Just emit to update UI
          emit(state.copyWith());
        }
      }
    });
  }

  Future<void> _completeDetoxSession() async {
    var newProgress = state.detoxProgress + 0.1;
    if (newProgress > 1) newProgress = 1;
    
    emit(state.copyWith(
      detoxProgress: newProgress,
      clearLock: true,
    ));
    
    await _persist();
  }

  Future<void> disableLock() async {
    // Cancel the timer and clear lock without changing progress
    _lockTimer?.cancel();
    
    emit(state.copyWith(clearLock: true));
  }

  // Clear permission denied flag
  void clearPermissionDenied() {
    emit(state.copyWith(permissionDenied: false));
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