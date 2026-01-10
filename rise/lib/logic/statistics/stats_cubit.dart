import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:the_project/database/repo/stats_repo.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepo repo;
  Timer? _refreshTimer;

  StatsCubit({required this.repo}) : super(const StatsInitial());

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> init() async {
    await loadForRange(StatsRange.weekly);
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state is StatsLoaded) {
        _silentRefresh();
      }
    });
  }

  Future<void> _silentRefresh() async {
    if (state is! StatsLoaded) return;
    
    try {
      final currentRange = (state as StatsLoaded).range;
      final data = await repo.loadForRange(currentRange);
      
      emit(StatsLoaded(
        range: currentRange,
        waterData: data.waterData,
        moodData: data.moodData,
        journalingCount: data.journalingCount,
        journalCounts: data.journalCounts,
        screenTime: data.screenTime,
        labels: data.labels,
        totalHabits: data.totalHabits,
        completedHabits: data.completedHabits,
        completionRate: data.completionRate,
        currentStreak: data.currentStreak,
        bestStreak: data.bestStreak,
        habitCompletionData: data.habitCompletionData,
        tasksConvertedToHabits: data.tasksConvertedToHabits,
      ));
    } catch (e) {
      print('Silent refresh failed: $e');
    }
  }

  Future<void> loadForRange(StatsRange range) async {
    try {
      emit(StatsLoading(range));
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      final data = await repo.loadForRange(range);
      
      emit(StatsLoaded(
        range: range,
        waterData: data.waterData,
        moodData: data.moodData,
        journalingCount: data.journalingCount,
        journalCounts: data.journalCounts,
        screenTime: data.screenTime,
        labels: data.labels,
        totalHabits: data.totalHabits,
        completedHabits: data.completedHabits,
        completionRate: data.completionRate,
        currentStreak: data.currentStreak,
        bestStreak: data.bestStreak,
        habitCompletionData: data.habitCompletionData,
        tasksConvertedToHabits: data.tasksConvertedToHabits,
      ));
      
    } catch (e) {
      print('StatsCubit Error: $e');
      emit(StatsError(range, 'Failed to load statistics. Please try again.'));
      
      await Future.delayed(const Duration(seconds: 2));
      try {
        final fallbackData = await _loadFallbackData(range);
        emit(StatsLoaded(
          range: range,
          waterData: fallbackData.waterData,
          moodData: fallbackData.moodData,
          journalingCount: fallbackData.journalingCount,
          journalCounts: fallbackData.journalCounts,
          screenTime: fallbackData.screenTime,
          labels: fallbackData.labels,
          totalHabits: fallbackData.totalHabits,
          completedHabits: fallbackData.completedHabits,
          completionRate: fallbackData.completionRate,
          currentStreak: fallbackData.currentStreak,
          bestStreak: fallbackData.bestStreak,
          habitCompletionData: fallbackData.habitCompletionData,
          tasksConvertedToHabits: fallbackData.tasksConvertedToHabits,
        ));
      } catch (_) {
      }
    }
  }

  Future<StatsData> _loadFallbackData(StatsRange range) async {
    switch (range) {
      case StatsRange.today:
        return StatsData(
          waterData: [6.0],
          moodData: [0.7],
          journalingCount: 1,
          journalCounts: [1],
          screenTime: {'social': 1.0, 'entertainment': 2.0, 'productivity': 3.0},
          labels: ['Today'],
          totalHabits: 5,
          completedHabits: 3,
          completionRate: 60.0,
          currentStreak: 2,
          bestStreak: 5,
          habitCompletionData: [60.0],
          tasksConvertedToHabits: 1,
        );
      case StatsRange.weekly:
        return StatsData(
          waterData: [6.0, 7.0, 5.0, 8.0, 6.0, 7.0, 8.0],
          moodData: [0.7, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6],
          journalingCount: 3,
          journalCounts: [0, 1, 0, 1, 0, 0, 1],
          screenTime: {'social': 1.2, 'entertainment': 2.1, 'productivity': 3.0},
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          totalHabits: 8,
          completedHabits: 5,
          completionRate: 62.5,
          currentStreak: 3,
          bestStreak: 7,
          habitCompletionData: [50.0, 60.0, 55.0, 70.0, 65.0, 60.0, 70.0],
          tasksConvertedToHabits: 2,
        );
      case StatsRange.monthly:
        return StatsData(
          waterData: List.filled(4, 6.5),
          moodData: List.filled(4, 0.65),
          journalingCount: 15,
          journalCounts: [3, 4, 5, 3],
          screenTime: {'social': 1.5, 'entertainment': 2.5, 'productivity': 4.0},
          labels: ['W1', 'W2', 'W3', 'W4'],
          totalHabits: 10,
          completedHabits: 7,
          completionRate: 70.0,
          currentStreak: 4,
          bestStreak: 10,
          habitCompletionData: [65.0, 70.0, 72.0, 68.0],
          tasksConvertedToHabits: 3,
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 6.5),
          moodData: List.filled(12, 0.65),
          journalingCount: 180,
          journalCounts: [15, 14, 16, 15, 14, 16, 15, 14, 16, 15, 14, 16],
          screenTime: {'social': 1.5, 'entertainment': 2.5, 'productivity': 4.0},
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
          totalHabits: 12,
          completedHabits: 9,
          completionRate: 75.0,
          currentStreak: 5,
          bestStreak: 15,
          habitCompletionData: [70.0, 72.0, 75.0, 73.0, 78.0, 80.0, 77.0, 75.0, 74.0, 76.0, 78.0, 75.0],
          tasksConvertedToHabits: 5,
        );
    }
  }

  Future<void> refresh() async {
    if (state is StatsLoaded) {
      await loadForRange((state as StatsLoaded).range);
    } else if (state is StatsError) {
      await loadForRange((state as StatsError).range);
    } else {
      await loadForRange(StatsRange.weekly);
    }
  }
}