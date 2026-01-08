// lib/logic/home/home_state.dart
import '../../models/habit_model.dart';
import '../../models/article_preview.dart';

class HomeState {
  final int waterCount;
  final int waterGoal;
  final double detoxProgress;
  final String userName;
  final List<Habit> dailyHabits;

  // ✅ Explore articles
  final List<ArticlePreview> exploreArticles;
  final bool exploreLoading;
  final String? exploreError;

  // Timer fields
  final bool isPhoneLocked;
  final DateTime? lockEndTime;

  // Permission tracking
  final bool permissionDenied;

  const HomeState({
    this.waterCount = 0,
    this.waterGoal = 8,
    this.detoxProgress = 0,
    this.userName = 'Guest',
    this.dailyHabits = const [],

    this.exploreArticles = const [],
    this.exploreLoading = false,
    this.exploreError,

    this.isPhoneLocked = false,
    this.lockEndTime,
    this.permissionDenied = false,
  });

  HomeState copyWith({
    int? waterCount,
    int? waterGoal,
    double? detoxProgress,
    String? userName,
    List<Habit>? dailyHabits,

    List<ArticlePreview>? exploreArticles,
    bool? exploreLoading,
    String? exploreError,

    bool? isPhoneLocked,
    DateTime? lockEndTime,
    bool clearLock = false,
    bool? permissionDenied,
  }) {
    return HomeState(
      waterCount: waterCount ?? this.waterCount,
      waterGoal: waterGoal ?? this.waterGoal,
      detoxProgress: detoxProgress ?? this.detoxProgress,
      userName: userName ?? this.userName,
      dailyHabits: dailyHabits ?? this.dailyHabits,

      exploreArticles: exploreArticles ?? this.exploreArticles,
      exploreLoading: exploreLoading ?? this.exploreLoading,
      exploreError: exploreError,

      isPhoneLocked: clearLock ? false : (isPhoneLocked ?? this.isPhoneLocked),
      lockEndTime: clearLock ? null : (lockEndTime ?? this.lockEndTime),
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}
