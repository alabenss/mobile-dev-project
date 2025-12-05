import '../../views/widgets/journal/daily_mood_model.dart';

enum DailyMoodStatus {
  initial,
  loading,
  loaded,
  error,
}

class DailyMoodState {
  final DailyMoodStatus status;
  final DailyMoodModel? todayMood;
  final String? error;

  DailyMoodState({
    this.status = DailyMoodStatus.initial,
    this.todayMood,
    this.error,
  });

  DailyMoodState copyWith({
    DailyMoodStatus? status,
    DailyMoodModel? todayMood,
    bool clearMood = false,
    String? error,
    bool clearError = false,
  }) {
    return DailyMoodState(
      status: status ?? this.status,
      todayMood: clearMood ? null : (todayMood ?? this.todayMood),
      error: clearError ? null : (error ?? this.error),
    );
  }
}