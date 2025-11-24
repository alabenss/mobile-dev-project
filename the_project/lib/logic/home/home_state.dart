// lib/logic/home/home_state.dart
class HomeState {
  final int waterCount;
  final int waterGoal;
  final double detoxProgress;
  final bool habitWalk;
  final bool habitRead;

  final String? selectedMoodImage;
  final String? selectedMoodLabel;
  final DateTime? selectedMoodTime;

  const HomeState({
    this.waterCount = 4,
    this.waterGoal = 8,
    this.detoxProgress = 0.35,
    this.habitWalk = true,
    this.habitRead = false,
    this.selectedMoodImage,
    this.selectedMoodLabel,
    this.selectedMoodTime,
  });

  HomeState copyWith({
    int? waterCount,
    int? waterGoal,
    double? detoxProgress,
    bool? habitWalk,
    bool? habitRead,
    String? selectedMoodImage,
    String? selectedMoodLabel,
    DateTime? selectedMoodTime,
    bool clearMood = false,
  }) {
    return HomeState(
      waterCount: waterCount ?? this.waterCount,
      waterGoal: waterGoal ?? this.waterGoal,
      detoxProgress: detoxProgress ?? this.detoxProgress,
      habitWalk: habitWalk ?? this.habitWalk,
      habitRead: habitRead ?? this.habitRead,
      selectedMoodImage:
          clearMood ? null : (selectedMoodImage ?? this.selectedMoodImage),
      selectedMoodLabel:
          clearMood ? null : (selectedMoodLabel ?? this.selectedMoodLabel),
      selectedMoodTime:
          clearMood ? null : (selectedMoodTime ?? this.selectedMoodTime),
    );
  }
}
