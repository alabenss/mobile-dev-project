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
  final List<int> journalCounts;
  final Map<String, double> screenTime;
  final List<String> labels;
  
  // NEW: Habit statistics fields
  final int totalHabits;
  final int completedHabits;
  final double completionRate;
  final int currentStreak;
  final int bestStreak;
  final List<double> habitCompletionData;
  final int tasksConvertedToHabits;

  const StatsLoaded({
    required StatsRange range,
    required this.waterData,
    required this.moodData,
    required this.journalingCount,
    required this.journalCounts,
    required this.screenTime,
    required this.labels,
    this.totalHabits = 0,
    this.completedHabits = 0,
    this.completionRate = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.habitCompletionData = const [],
    this.tasksConvertedToHabits = 0,
  }) : super(range);

  @override
  List<Object?> get props => [
    range, 
    waterData, 
    moodData, 
    journalingCount,
    journalCounts,
    screenTime, 
    labels,
    totalHabits,
    completedHabits,
    completionRate,
    currentStreak,
    bestStreak,
    habitCompletionData,
    tasksConvertedToHabits,
  ];
}