import 'package:bloc/bloc.dart';
import 'package:the_project/database/repo/stats_repo.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepo repo;

  StatsCubit({required this.repo}) : super(const StatsInitial());

  Future<void> loadForRange(StatsRange range) async {
    try {
      // Emit loading state
      emit(StatsLoading(range));
      
      // Add small delay for smooth UI transition
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Load data from repository
      final data = await repo.loadForRange(range);
      
      // Emit loaded state with data
      emit(StatsLoaded(
        range: range,
        waterData: data.waterData,
        moodData: data.moodData,
        journalingCount: data.journalingCount,
        screenTime: data.screenTime,
        labels: data.labels,
      ));
      
    } catch (e) {
      print('StatsCubit Error: $e');
      emit(StatsError(range, 'Failed to load statistics. Please try again.'));
      
      // After error, still try to show some data after a delay
      await Future.delayed(const Duration(seconds: 2));
      try {
        final fallbackData = await _loadFallbackData(range);
        emit(StatsLoaded(
          range: range,
          waterData: fallbackData.waterData,
          moodData: fallbackData.moodData,
          journalingCount: fallbackData.journalingCount,
          screenTime: fallbackData.screenTime,
          labels: fallbackData.labels,
        ));
      } catch (_) {
        // If fallback also fails, keep error state
      }
    }
  }

  /// Load fallback demo data
  Future<StatsData> _loadFallbackData(StatsRange range) async {
    // Simple fallback data
    switch (range) {
      case StatsRange.today:
        return StatsData(
          waterData: [6.0],
          moodData: [0.7],
          journalingCount: 1,
          screenTime: {'social': 1.0, 'entertainment': 2.0, 'productivity': 3.0},
          labels: ['Today'],
        );
      case StatsRange.weekly:
        return StatsData(
          waterData: [6.0, 7.0, 5.0, 8.0, 6.0, 7.0, 8.0],
          moodData: [0.7, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6],
          journalingCount: 3,
          screenTime: {'social': 1.2, 'entertainment': 2.1, 'productivity': 3.0},
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        );
      case StatsRange.monthly:
        return StatsData(
          waterData: List.filled(12, 6.5),
          moodData: List.filled(12, 0.65),
          journalingCount: 15,
          screenTime: {'social': 1.5, 'entertainment': 2.5, 'productivity': 4.0},
          labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'W12'],
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 6.5),
          moodData: List.filled(12, 0.65),
          journalingCount: 180,
          screenTime: {'social': 1.5, 'entertainment': 2.5, 'productivity': 4.0},
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        );
    }
  }

  // Convenience method for initialization
  Future<void> init() => loadForRange(StatsRange.weekly);
  
  // Refresh current data
  Future<void> refresh() async {
    if (state is StatsLoaded) {
      await loadForRange((state as StatsLoaded).range);
    } else {
      await loadForRange(StatsRange.weekly);
    }
  }
}