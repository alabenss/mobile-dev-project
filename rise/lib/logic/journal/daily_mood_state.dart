import '../../views/widgets/journal/daily_mood_model.dart';

enum DailyMoodStatus {
  initial,
  loading,
  loaded,
  error,
}

class DailyMoodState {
  static const Object _unset = Object();

  final DailyMoodStatus status;
  final DailyMoodModel? todayMood;
  final String? error;

  const DailyMoodState({
    this.status = DailyMoodStatus.initial,
    this.todayMood,
    this.error,
  });

  DailyMoodState copyWith({
    DailyMoodStatus? status,

    /// IMPORTANT: allows passing `todayMood: null` to clear it.
    Object? todayMood = _unset,

    bool clearMood = false,
    String? error,
    bool clearError = false,
  }) {
    return DailyMoodState(
      status: status ?? this.status,

      // ✅ if clearMood => null
      // ✅ else if todayMood not provided => keep old
      // ✅ else (provided including null) => set it
      todayMood: clearMood
          ? null
          : (todayMood == _unset ? this.todayMood : todayMood as DailyMoodModel?),

      error: clearError ? null : (error ?? this.error),
    );
  }
}
