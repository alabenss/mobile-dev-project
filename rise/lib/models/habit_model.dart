import 'package:flutter/material.dart';

class Habit {
  final String title; // Displayed title (can be localized)
  final String habitKey; // Unique identifier (language-independent)
  final IconData icon;
  final String frequency;
  final TimeOfDay? time;
  final bool reminder;
  final int points;
  final bool done;
  final bool skipped;

  Habit({
    required this.title,
    String? habitKey, // Optional, will default to title
    required this.icon,
    required this.frequency,
    this.time,
    this.reminder = false,
    this.points = 10,
    this.done = false,
    this.skipped = false,
  }) : habitKey = habitKey ?? title.toLowerCase().replaceAll(' ', '_');

  // Get the icon code point for database storage
  int get iconCodePoint => icon.codePoint;

  // Create IconData from code point
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

  // Predefined habit keys for consistency
  static const String keyDrinkWater = 'drink_water';
  static const String keyExercise = 'exercise';
  static const String keyMeditate = 'meditate';
  static const String keyRead = 'read';
  static const String keySleepEarly = 'sleep_early';
  static const String keyStudy = 'study';
  static const String keyWalk = 'walk';
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
      case keyOther:
      default:
        return Icons.star_border;
    }
  }
}