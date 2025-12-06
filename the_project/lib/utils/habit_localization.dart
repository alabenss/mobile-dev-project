import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/habit_model.dart';

/// Helper class to get localized habit titles
class HabitLocalization {
  /// Get the localized title for a habit based on its habitKey
  static String getLocalizedTitle(BuildContext context, Habit habit) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (habit.habitKey) {
      case Habit.keyDrinkWater:
        return l10n.habitDrinkWater;
      case Habit.keyExercise:
        return l10n.habitExercise;
      case Habit.keyMeditate:
        return l10n.habitMeditate;
      case Habit.keyRead:
        return l10n.habitRead;
      case Habit.keySleepEarly:
        return l10n.habitSleepEarly;
      case Habit.keyStudy:
        return l10n.habitStudy;
      case Habit.keyWalk:
        return l10n.habitWalk;
      case Habit.keyOther:
        return l10n.habitOther;
      default:
        // For custom habits, return the stored title
        return habit.title;
    }
  }

  /// Update a habit with its localized title
  static Habit localizeHabit(BuildContext context, Habit habit) {
    return habit.copyWith(
      title: getLocalizedTitle(context, habit),
    );
  }

  /// Localize a list of habits
  static List<Habit> localizeHabits(BuildContext context, List<Habit> habits) {
    return habits.map((habit) => localizeHabit(context, habit)).toList();
  }
}