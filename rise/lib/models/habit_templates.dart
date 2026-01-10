// lib/models/habit_templates.dart
import 'package:flutter/material.dart';
import 'habit_model.dart';

class HabitTemplates {
  /// Get all available habit templates (predefined habits)
  static List<Map<String, dynamic>> getAllTemplates() {
    return [
      // Good habits
      {'key': 'drink_water', 'type': 'good', 'icon': Icons.water_drop},
      {'key': 'exercise', 'type': 'good', 'icon': Icons.fitness_center},
      {'key': 'read_book', 'type': 'good', 'icon': Icons.menu_book},
      {'key': 'meditate', 'type': 'good', 'icon': Icons.self_improvement},
      {'key': 'eat_healthy', 'type': 'good', 'icon': Icons.restaurant},
      {'key': 'sleep_early', 'type': 'good', 'icon': Icons.bedtime},
      {'key': 'study', 'type': 'good', 'icon': Icons.school},
      {'key': 'practice_instrument', 'type': 'good', 'icon': Icons.music_note},
      {'key': 'journal', 'type': 'good', 'icon': Icons.edit_note},
      {'key': 'walk', 'type': 'good', 'icon': Icons.directions_walk},
      {'key': 'stretch', 'type': 'good', 'icon': Icons.accessibility_new},
      {'key': 'clean_room', 'type': 'good', 'icon': Icons.cleaning_services},
      {'key': 'pray', 'type': 'good', 'icon': Icons.church},
      {'key': 'take_vitamins', 'type': 'good', 'icon': Icons.medication},
      {'key': 'brush_teeth', 'type': 'good', 'icon': Icons.clean_hands},
      
      // Bad habits
      {'key': 'smoke', 'type': 'bad', 'icon': Icons.smoke_free},
      {'key': 'junk_food', 'type': 'bad', 'icon': Icons.fastfood},
      {'key': 'social_media', 'type': 'bad', 'icon': Icons.phone_android},
      {'key': 'procrastinate', 'type': 'bad', 'icon': Icons.hourglass_empty},
      {'key': 'stay_up_late', 'type': 'bad', 'icon': Icons.nights_stay},
      {'key': 'skip_meals', 'type': 'bad', 'icon': Icons.no_meals},
      {'key': 'nail_biting', 'type': 'bad', 'icon': Icons.back_hand},
      {'key': 'excessive_caffeine', 'type': 'bad', 'icon': Icons.local_cafe},
    ];
  }

  /// Filter habits that can be added for a specific frequency
  /// Only shows habits that haven't been created in the current period
  static List<Map<String, dynamic>> getAvailableHabitsForFrequency(
    String frequency,
    List<Habit> existingHabits,
  ) {
    final allTemplates = getAllTemplates();
    
    // Get habit keys that already exist for this frequency in current period
    final existingKeys = existingHabits
        .where((h) => h.frequency == frequency)
        .map((h) => h.habitKey)
        .toSet();
    
    // Filter out habits that already exist
    return allTemplates
        .where((template) => !existingKeys.contains(template['key']))
        .toList();
  }

  /// Get localized display name for a habit key
  static String getDisplayName(String habitKey) {
    return habitKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Create a Habit object from a template
  static Habit createFromTemplate(
    Map<String, dynamic> template,
    String frequency, {
    TimeOfDay? time,
    bool reminder = false,
    int points = 10,
  }) {
    return Habit(
      title: getDisplayName(template['key']),
      habitKey: template['key'],
      icon: template['icon'] ?? Icons.check_circle,
      frequency: frequency,
      time: time,
      reminder: reminder,
      points: points,
      habitType: template['type'] ?? 'good',
      done: false,
      skipped: false,
      streakCount: 0,
      bestStreak: 0,
      isTask: true,
      taskCompletionCount: 0,
    );
  }
}