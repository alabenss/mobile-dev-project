// lib/logic/statistics/stats_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:the_project/database/repo/stats_repo.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';

import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepo repo;

  StatsCubit({required this.repo}) : super(const StatsInitial());

  Future<void> loadForRange(StatsRange range) async {
    try {
      emit(StatsLoading(range));
      final data = await repo.loadForRange(range);
      emit(StatsLoaded(
        range: range,
        waterData: data.waterData,
        moodData: data.moodData,
        journalingCount: data.journalingCount,
        screenTime: data.screenTime,
        labels: data.labels,
      ));
    } catch (e) {
      emit(StatsError(range, e.toString()));
    }
  }

  // convenience for init
  Future<void> init() => loadForRange(StatsRange.weekly);
}
