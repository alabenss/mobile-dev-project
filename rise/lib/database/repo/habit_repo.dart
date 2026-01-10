// lib/data/repo/habit_repo.dart
import 'package:flutter/material.dart';
import '../../models/habit_model.dart';
import '../../services/notification_service.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class HabitRepository {
  final ApiService _api = ApiService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  /// Get the current logged-in user's ID
  Future<int> _getCurrentUserId() async {
    return await _api.getCurrentUserId();
  }

  /// Convert a Habit object to JSON for API
  Map<String, dynamic> _habitToJson(Habit habit) {
    return {
      'title': habit.habitKey,
      'description': habit.iconCodePoint.toString(),
      'frequency': habit.frequency,
      'status': habit.done ? 'completed' : (habit.skipped ? 'skipped' : 'active'),
      'doItAt': habit.time != null
          ? '${habit.time!.hour.toString().padLeft(2, '0')}:${habit.time!.minute.toString().padLeft(2, '0')}'
          : null,
      'points': habit.points,
      'remindMe': habit.reminder,
      'habitType': habit.habitType,
      'streakCount': habit.streakCount,
      'bestStreak': habit.bestStreak,
      'isTask': habit.isTask,
      'taskCompletionCount': habit.taskCompletionCount,
      'lastCompletedDate': habit.lastCompletedDate?.toIso8601String(),
    };
  }

  /// Convert JSON from API to Habit object
  Habit _habitFromJson(Map<String, dynamic> json) {
    String habitKey = json['title'] as String;
    
    IconData icon;
    try {
      final iconCode = int.parse(json['description'] as String? ?? '0');
      if (iconCode > 0) {
        icon = Habit.iconFromCodePoint(iconCode);
      } else {
        icon = Habit.getIconForKey(habitKey);
      }
    } catch (e) {
      icon = Habit.getIconForKey(habitKey);
    }

    String displayTitle = _getLocalizedTitle(habitKey);

    TimeOfDay? time;
    final doItAt = json['do_it_at'] as String?;
    if (doItAt != null && doItAt.isNotEmpty) {
      final parts = doItAt.split(':');
      if (parts.length == 2) {
        time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
    
    final status = (json['status'] as String?) ?? 'active';
    final remindMe = json['remind_me'];
    final habitType = (json['habit_type'] as String?) ?? 'good';
    final streakCount = (json['streak_count'] as int?) ?? 0;
    final bestStreak = (json['best_streak'] as int?) ?? 0;
    final isTask = json['is_task'] == true || json['is_task'] == 1;
    final taskCompletionCount = (json['task_completion_count'] as int?) ?? 0;
    
    DateTime? lastCompletedDate;
    if (json['last_completed_date'] != null) {
      lastCompletedDate = DateTime.parse(json['last_completed_date'] as String);
    }
    
    return Habit(
      title: displayTitle,
      habitKey: habitKey,
      icon: icon,
      frequency: json['frequency'] as String,
      time: time,
      reminder: remindMe == true || remindMe == 1,
      points: json['points'] as int? ?? 10,
      done: status == 'completed',
      skipped: status == 'skipped',
      habitType: habitType,
      streakCount: streakCount,
      bestStreak: bestStreak,
      isTask: isTask,
      taskCompletionCount: taskCompletionCount,
      lastCompletedDate: lastCompletedDate,
    );
  }

  String _getLocalizedTitle(String habitKey) {
    return habitKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Check if a habit with this frequency already exists in the current period
  Future<bool> habitExistsInCurrentPeriod(String frequency) async {
    try {
      final userId = await _getCurrentUserId();
      
      final response = await _api.get(
        ApiConfig.HABITS_CHECK_EXISTS,
        params: {
          'userId': userId.toString(),
          'frequency': frequency,
        },
      );

      if (response['success'] == true) {
        return response['exists'] as bool? ?? false;
      }

      return false;
    } catch (e) {
      print('HabitRepo: Error checking habit exists in period: $e');
      return false;
    }
  }

  /// Insert a new habit
  Future<int> insertHabit(Habit habit) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Inserting habit for userId: $userId');

      final habitData = _habitToJson(habit);
      habitData['userId'] = userId;

      final response = await _api.post(ApiConfig.HABITS_ADD, habitData);

      // Check if the backend returned an error
      if (response['success'] == false) {
        throw Exception(response['error'] ?? 'Failed to add habit');
      }

      final habitId = response['habitId'] as int? ?? 0;

      // Schedule notification if reminder is enabled
      if (habit.reminder && habit.time != null) {
        await _notificationService.scheduleHabitReminder(habit, userId);
      }

      print('HabitRepo: Habit inserted with ID: $habitId');
      return habitId;
    } catch (e) {
      print('HabitRepo: Error inserting habit: $e');
      rethrow;
    }
  }

  /// Retrieve all habits (deprecated - use getHabitsByFrequencyAndDate instead)
  Future<List<Habit>> getAllHabits() async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Getting all habits for userId: $userId');

      final response = await _api.get(
        ApiConfig.HABITS_GET,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['habits'] != null) {
        final habitsList = response['habits'] as List;
        return habitsList.map((json) => _habitFromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('HabitRepo: Error getting all habits: $e');
      return [];
    }
  }

  /// Get habits by frequency (Daily, Weekly, Monthly) - deprecated
  Future<List<Habit>> getHabitsByFrequency(String frequency) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Getting habits by frequency: $frequency');

      final response = await _api.get(
        ApiConfig.HABITS_GET,
        params: {
          'userId': userId.toString(),
          'frequency': frequency,
        },
      );

      if (response['success'] == true && response['habits'] != null) {
        final habitsList = response['habits'] as List;
        return habitsList.map((json) => _habitFromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('HabitRepo: Error getting habits by frequency: $e');
      return [];
    }
  }

  /// Get habits by frequency with date filtering
  /// For Daily: returns habits from today
  /// For Weekly: returns habits from current week (Monday-Sunday)
  /// For Monthly: returns habits from current month
  Future<List<Habit>> getHabitsByFrequencyAndDate(String frequency) async {
    try {
      final userId = await _getCurrentUserId();
      final now = DateTime.now();
      
      String? startDate;
      String? endDate;
      
      switch (frequency) {
        case 'Daily':
          // Today only
          startDate = DateTime(now.year, now.month, now.day).toIso8601String();
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
          break;
          
        case 'Weekly':
          // Current week (Monday to Sunday)
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toIso8601String();
          endDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59).toIso8601String();
          break;
          
        case 'Monthly':
          // Current month
          startDate = DateTime(now.year, now.month, 1).toIso8601String();
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();
          break;
      }
      
      print('HabitRepo: Getting habits for $frequency from $startDate to $endDate');

      final response = await _api.get(
        ApiConfig.HABITS_GET,
        params: {
          'userId': userId.toString(),
          'frequency': frequency,
          'startDate': startDate!,
          'endDate': endDate!,
        },
      );

      if (response['success'] == true && response['habits'] != null) {
        final habitsList = response['habits'] as List;
        return habitsList.map((json) => _habitFromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('HabitRepo: Error getting habits by frequency and date: $e');
      return [];
    }
  }

  /// Get today's habits (filtered by date)
  Future<List<Habit>> getTodayHabits() async {
    return await getHabitsByFrequencyAndDate('Daily');
  }

  /// Get this week's habits
  Future<List<Habit>> getWeeklyHabits() async {
    return await getHabitsByFrequencyAndDate('Weekly');
  }

  /// Get this month's habits
  Future<List<Habit>> getMonthlyHabits() async {
    return await getHabitsByFrequencyAndDate('Monthly');
  }

  /// Update habit status with streak tracking and task-to-habit conversion
  Future<int> updateHabitStatus(String habitKeyOrTitle, String status) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Updating habit status: $habitKeyOrTitle -> $status');

      final habit = await getHabitByKey(habitKeyOrTitle);
      if (habit == null) return 0;

      int newStreak = habit.streakCount;
      int newBestStreak = habit.bestStreak;
      int newTaskCompletion = habit.taskCompletionCount;
      bool newIsTask = habit.isTask;

      // Handle completion
      if (status == 'completed') {
        await _awardPoints(habit.points);
        
        // For good habits, completion increments streak
        if (habit.habitType == 'good') {
          newStreak++;
          newTaskCompletion++;
          if (newStreak > newBestStreak) {
            newBestStreak = newStreak;
          }
        }
        
        // Check if task should become habit (10 consecutive completions)
        if (newIsTask && newTaskCompletion >= 10) {
          newIsTask = false;
          // Bonus points for establishing a habit!
          await _awardPoints(50);
        }
      }
      
      // Handle skipping
      else if (status == 'skipped') {
        // For bad habits, skipping increments streak
        if (habit.habitType == 'bad') {
          newStreak++;
          newTaskCompletion++;
          await _awardPoints(habit.points); // Award points for resisting
          if (newStreak > newBestStreak) {
            newBestStreak = newStreak;
          }
          
          // Check if task should become habit
          if (newIsTask && newTaskCompletion >= 10) {
            newIsTask = false;
            await _awardPoints(50);
          }
        }
        // For good habits, skipping breaks the streak
        else {
          newStreak = 0;
        }
      }
      
      // Handle reset (undoing completion)
      else if (status == 'active') {
        await _awardPoints(-habit.points);
      }

      await _api.put(ApiConfig.HABITS_UPDATE_STATUS, {
        'userId': userId,
        'title': habitKeyOrTitle,
        'status': status,
        'streakCount': newStreak,
        'bestStreak': newBestStreak,
        'taskCompletionCount': newTaskCompletion,
        'isTask': newIsTask,
        'lastCompletedDate': (status == 'completed' || status == 'skipped')
            ? DateTime.now().toIso8601String()
            : habit.lastCompletedDate?.toIso8601String(),
      });

      return 1;
    } catch (e) {
      print('HabitRepo: Error updating habit status: $e');
      return 0;
    }
  }

  /// Restore streak using points
  Future<bool> restoreStreak(String habitKey) async {
    try {
      final userId = await _getCurrentUserId();
      
      final habit = await getHabitByKey(habitKey);
      if (habit == null || !habit.needsStreakRestoration) return false;
      
      final response = await _api.post(ApiConfig.HABITS_RESTORE_STREAK, {
        'userId': userId,
        'habitKey': habitKey,
      });

      return response['success'] == true;
    } catch (e) {
      print('HabitRepo: Error restoring streak: $e');
      return false;
    }
  }

  /// Get a specific habit by habitKey
  Future<Habit?> getHabitByKey(String habitKey) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Getting habit by key: $habitKey');

      final response = await _api.get(
        ApiConfig.HABITS_GET_BY_TITLE,
        params: {
          'userId': userId.toString(),
          'title': habitKey,
        },
      );

      if (response['success'] == true && response['habit'] != null) {
        return _habitFromJson(response['habit']);
      }

      return null;
    } catch (e) {
      print('HabitRepo: Error getting habit by key: $e');
      return null;
    }
  }

  /// Get a specific habit by title (kept for backward compatibility)
  Future<Habit?> getHabitByTitle(String title) async {
    return await getHabitByKey(title);
  }

  /// Delete a habit by habitKey
  Future<int> deleteHabit(String habitKey) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Deleting habit: $habitKey');

      // Cancel notification before deleting
      final habit = await getHabitByKey(habitKey);
      if (habit != null && habit.reminder) {
        await _notificationService.cancelHabitReminder(habit, userId);
      }

      // Find the habit ID first
      final response = await _api.get(
        ApiConfig.HABITS_GET_BY_TITLE,
        params: {
          'userId': userId.toString(),
          'title': habitKey,
        },
      );

      if (response['success'] == true && response['habit'] != null) {
        final habitId = response['habit']['id'];
        
        await _api.delete(
          ApiConfig.HABITS_DELETE,
          params: {
            'id': habitId.toString(),
            'userId': userId.toString(),
          },
        );
      }

      return 1;
    } catch (e) {
      print('HabitRepo: Error deleting habit: $e');
      return 0;
    }
  }

  /// Get completed habits count
  Future<int> getCompletedHabitsCount() async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Getting completed habits count');

      final response = await _api.get(
        ApiConfig.HABITS_GET_COMPLETED,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true) {
        return response['count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      print('HabitRepo: Error getting completed habits count: $e');
      return 0;
    }
  }

  /// Check if a habit exists (deprecated)
  Future<bool> habitExists(String habitKey) async {
    try {
      final userId = await _getCurrentUserId();
      
      final response = await _api.get(
        ApiConfig.HABITS_CHECK_EXISTS,
        params: {
          'userId': userId.toString(),
          'title': habitKey,
        },
      );

      if (response['success'] == true) {
        return response['exists'] as bool? ?? false;
      }

      return false;
    } catch (e) {
      print('HabitRepo: Error checking habit exists: $e');
      return false;
    }
  }

  /// Check if a habit with the given key and frequency already exists (deprecated)
  Future<bool> habitExistsWithFrequency(String habitKey, String frequency) async {
    // Now we only check if any habit exists in the current period for this frequency
    return await habitExistsInCurrentPeriod(frequency);
  }

  /// Update habit reminder settings
  Future<void> updateHabitReminder(String habitKey, bool reminder, TimeOfDay? time) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Updating reminder for habit: $habitKey');

      await _api.put(ApiConfig.HABITS_UPDATE, {
        'userId': userId,
        'habitKey': habitKey,
        'remindMe': reminder,
        'doItAt': time != null
            ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
            : null,
      });

      // Update notification
      final habit = await getHabitByKey(habitKey);
      if (habit != null) {
        if (reminder && time != null) {
          await _notificationService.scheduleHabitReminder(habit, userId);
        } else {
          await _notificationService.cancelHabitReminder(habit, userId);
        }
      }
    } catch (e) {
      print('HabitRepo: Error updating habit reminder: $e');
      rethrow;
    }
  }

  /// Reschedule all habit notifications (useful after app restart)
  Future<void> rescheduleAllNotifications() async {
    try {
      final userId = await _getCurrentUserId();
      final allHabits = await getAllHabits();

      for (var habit in allHabits) {
        if (habit.reminder && habit.time != null) {
          await _notificationService.scheduleHabitReminder(habit, userId);
        }
      }
    } catch (e) {
      print('HabitRepo: Error rescheduling notifications: $e');
    }
  }

  /// Award points to user (internal helper)
  Future<void> _awardPoints(int points) async {
    try {
      final userId = await _getCurrentUserId();
      
      await _api.post(ApiConfig.USER_AWARD_POINTS, {
        'userId': userId,
        'points': points,
      });
    } catch (e) {
      print('HabitRepo: Error awarding points: $e');
    }
  }

  /// Get total habit points
  Future<int> getTotalHabitPoints() async {
    try {
      final habits = await getAllHabits();

      int total = 0;
      for (final habit in habits) {
        if (!habit.done) continue;
        total += habit.points;
      }

      return total;
    } catch (e) {
      print('HabitRepo: Error getting total habit points: $e');
      return 0;
    }
  }

  /// Check and reset old habits (backend should handle this)
  Future<void> checkAndResetOldHabits() async {
    try {
      final userId = await _getCurrentUserId();
      
      await _api.post(ApiConfig.HABITS_CHECK_RESET, {
        'userId': userId,
      });
      
      print('HabitRepo: Checked and reset old habits');
    } catch (e) {
      print('HabitRepo: Error checking and resetting old habits: $e');
    }
  }

  // Legacy methods for compatibility
  Future<int> deleteAllHabits() async {
    try {
      final habits = await getAllHabits();
      for (var habit in habits) {
        await deleteHabit(habit.habitKey);
      }
      return habits.length;
    } catch (e) {
      print('HabitRepo: Error deleting all habits: $e');
      return 0;
    }
  }

  Future<void> resetDailyHabits() async {
    try {
      final userId = await _getCurrentUserId();
      
      await _api.post(ApiConfig.HABITS_RESET_DAILY, {
        'userId': userId,
      });
    } catch (e) {
      print('HabitRepo: Error resetting daily habits: $e');
    }
  }
}