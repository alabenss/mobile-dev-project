// lib/logic/statistics/stats_state.dart
import 'package:equatable/equatable.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';

abstract class StatsState extends Equatable {
  final StatsRange range;

  const StatsState(this.range);

  @override
  List<Object?> get props => [range];
}

class StatsInitial extends StatsState {
  const StatsInitial() : super(StatsRange.weekly);
}

class StatsLoading extends StatsState {
  const StatsLoading(super.range);
}

class StatsError extends StatsState {
  final String message;
  const StatsError(super.range, this.message);

  @override
  List<Object?> get props => [range, message];
}

class StatsLoaded extends StatsState {
  final List<double> waterData;
  final List<double> moodData;
  final int journalingCount;
  final Map<String, double> screenTime;
  final List<String> labels;

  const StatsLoaded({
    required StatsRange range,
    required this.waterData,
    required this.moodData,
    required this.journalingCount,
    required this.screenTime,
    required this.labels,
  }) : super(range);

  @override
  List<Object?> get props =>
      [range, waterData, moodData, journalingCount, screenTime, labels];
}
