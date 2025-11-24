// lib/logic/activities/activities_state.dart
import '../../database/repo/activities_repo.dart';

class ActivitiesState {
  final List<ActivityItem> activities;
  final bool isLoading;
  final String? error;

  const ActivitiesState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
  });

  ActivitiesState copyWith({
    List<ActivityItem>? activities,
    bool? isLoading,
    String? error, // pass null explicitly to clear error
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
