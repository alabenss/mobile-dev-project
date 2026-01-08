// lib/logic/home/home_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';
import '../../database/repo/home_repo.dart';
import '../../database/repo/habit_repo.dart';
import '../../database/repo/articles_repo.dart';

class HomeCubit extends Cubit<HomeState> {
  final AbstractHomeRepo _repo;
  final HabitRepository _habitRepo;
  final ArticlesRepo _articlesRepo;

  Timer? _lockTimer;

  HomeCubit(this._repo, this._habitRepo, this._articlesRepo) : super(const HomeState());

  @override
  Future<void> close() {
    _lockTimer?.cancel();
    return super.close();
  }

  // ✅ Load initial values (water, detox, userName, daily habits, explore articles)
  Future<void> loadInitial({String? userName, String lang = 'en'}) async {
    emit(state.copyWith(exploreLoading: true, exploreError: null));

    final status = await _repo.loadTodayStatus();
    final dailyHabits = await _habitRepo.getHabitsByFrequency('Daily');

    try {
      final explore = await _articlesRepo.getAll(lang: lang);

      emit(state.copyWith(
        waterCount: status.waterCount,
        waterGoal: status.waterGoal,
        detoxProgress: status.detoxProgress,
        userName: userName ?? state.userName,
        dailyHabits: dailyHabits,
        exploreArticles: explore,
        exploreLoading: false,
        exploreError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        waterCount: status.waterCount,
        waterGoal: status.waterGoal,
        detoxProgress: status.detoxProgress,
        userName: userName ?? state.userName,
        dailyHabits: dailyHabits,
        exploreArticles: const [],
        exploreLoading: false,
        exploreError: e.toString(),
      ));
    }
  }

  Future<void> _persist() async {
    final status = HomeStatus(
      waterCount: state.waterCount,
      waterGoal: state.waterGoal,
      detoxProgress: state.detoxProgress,
    );
    await _repo.saveStatus(status);
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

  // digital detox – with in-app lock only
  Future<void> increaseDetox() async {
    final lockEndTime = DateTime.now().add(const Duration(minutes: 1));

    emit(state.copyWith(
      isPhoneLocked: true,
      lockEndTime: lockEndTime,
      permissionDenied: false,
    ));

    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.lockEndTime != null) {
        final now = DateTime.now();
        final difference = state.lockEndTime!.difference(now);

        if (difference.isNegative) {
          timer.cancel();
          await _completeDetoxSession();
        } else {
          emit(state.copyWith()); // update UI
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
    _lockTimer?.cancel();
    emit(state.copyWith(clearLock: true));
  }

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
      await _habitRepo.updateHabitStatus(title, 'active');
    } else {
      await _habitRepo.updateHabitStatus(title, 'completed');
    }

    final dailyHabits = await _habitRepo.getHabitsByFrequency('Daily');
    emit(state.copyWith(dailyHabits: dailyHabits));
  }

  Future<void> reloadDailyHabits() async {
    final dailyHabits = await _habitRepo.getHabitsByFrequency('Daily');
    emit(state.copyWith(dailyHabits: dailyHabits));
  }
}
