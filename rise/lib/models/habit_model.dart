import 'package:flutter/material.dart';

class Habit {
  final String title;
  final String habitKey;
  final IconData icon;
  final String frequency;
  final TimeOfDay? time;
  final bool reminder;
  final int points;
  final bool done;
  final bool skipped;
  final String habitType; // 'good' or 'bad'
  final int streakCount;
  final int bestStreak;
  final bool isTask; // true if still a task, false if it became a habit
  final int taskCompletionCount;
  final DateTime? lastCompletedDate;

  Habit({
    required this.title,
    String? habitKey,
    required this.icon,
    required this.frequency,
    this.time,
    this.reminder = false,
    this.points = 10,
    this.done = false,
    this.skipped = false,
    this.habitType = 'good', // default to good habit
    this.streakCount = 0,
    this.bestStreak = 0,
    this.isTask = true, // Start as task
    this.taskCompletionCount = 0,
    this.lastCompletedDate,
  }) : habitKey = habitKey ?? title.toLowerCase().replaceAll(' ', '_');

  int get iconCodePoint => icon.codePoint;

  static IconData iconFromCodePoint(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Habit copyWith({
    String? title,
    String? habitKey,
    IconData? icon,
    String? frequency,
    TimeOfDay? time,
    bool? reminder,
    int? points,
    bool? done,
    bool? skipped,
    String? habitType,
    int? streakCount,
    int? bestStreak,
    bool? isTask,
    int? taskCompletionCount,
    DateTime? lastCompletedDate,
  }) {
    return Habit(
      title: title ?? this.title,
      habitKey: habitKey ?? this.habitKey,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      reminder: reminder ?? this.reminder,
      points: points ?? this.points,
      done: done ?? this.done,
      skipped: skipped ?? this.skipped,
      habitType: habitType ?? this.habitType,
      streakCount: streakCount ?? this.streakCount,
      bestStreak: bestStreak ?? this.bestStreak,
      isTask: isTask ?? this.isTask,
      taskCompletionCount: taskCompletionCount ?? this.taskCompletionCount,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          habitKey == other.habitKey &&
          frequency == other.frequency;

  @override
  int get hashCode => habitKey.hashCode ^ frequency.hashCode;

  // Predefined habit keys
  static const String keyDrinkWater = 'drink_water';
  static const String keyExercise = 'exercise';
  static const String keyMeditate = 'meditate';
  static const String keyRead = 'read';
  static const String keySleepEarly = 'sleep_early';
  static const String keyStudy = 'study';
  static const String keyWalk = 'walk';
  static const String keyNoSocialMedia = 'no_social_media';
  static const String keyNoSmoking = 'no_smoking';
  static const String keyNoProcrastination = 'no_procrastination';
  static const String keyOther = 'other';

  // Get icon for a habit key
  static IconData getIconForKey(String key) {
    switch (key) {
      case keyDrinkWater:
        return Icons.local_drink;
      case keyExercise:
        return Icons.fitness_center;
      case keyMeditate:
        return Icons.self_improvement;
      case keyRead:
        return Icons.book;
      case keySleepEarly:
        return Icons.bedtime;
      case keyStudy:
        return Icons.school;
      case keyWalk:
        return Icons.directions_walk;
      case keyNoSocialMedia:
        return Icons.phone_disabled;
      case keyNoSmoking:
        return Icons.smoke_free;
      case keyNoProcrastination:
        return Icons.timer_off;
      case keyOther:
      default:
        return Icons.star_border;
    }
  }

  // Helper to check if habit needs streak restoration
  bool get needsStreakRestoration {
    if (lastCompletedDate == null) return false;
    
    final now = DateTime.now();
    final daysSinceLastCompletion = now.difference(lastCompletedDate!).inDays;
    
    // If more than 1 day has passed (for daily) and streak was > 0
    if (frequency.toLowerCase() == 'daily' && daysSinceLastCompletion > 1 && streakCount == 0) {
      return true;
    }
    
    // Similar logic for weekly/monthly
    if (frequency.toLowerCase() == 'weekly' && daysSinceLastCompletion > 7 && streakCount == 0) {
      return true;
    }
    
    if (frequency.toLowerCase() == 'monthly' && daysSinceLastCompletion > 30 && streakCount == 0) {
      return true;
    }
    
    return false;
  }

  // Cost to restore streak (10 points per day of streak)
  int get streakRestorationCost => bestStreak * 10;
}