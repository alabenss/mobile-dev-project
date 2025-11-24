// lib/logic/home/home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';
import '../../database/repo/home_repo.dart';

class HomeCubit extends Cubit<HomeState> {
  final AbstractHomeRepo _repo;

  HomeCubit(this._repo) : super(const HomeState());

  // Load initial values (water, detox, mood) from DB
  Future<void> loadInitial() async {
    final status = await _repo.loadTodayStatus();
    emit(state.copyWith(
      waterCount: status.waterCount,
      waterGoal: status.waterGoal,
      detoxProgress: status.detoxProgress,
      selectedMoodImage: status.moodImage,
      selectedMoodLabel: status.moodLabel,
      selectedMoodTime: status.moodTime,
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

  // habits – still in memory only
  void toggleHabitWalk() {
    emit(state.copyWith(habitWalk: !state.habitWalk));
  }

  void toggleHabitRead() {
    emit(state.copyWith(habitRead: !state.habitRead));
  }
}
