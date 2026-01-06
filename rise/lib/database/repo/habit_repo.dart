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
    );
  }

  String _getLocalizedTitle(String habitKey) {
    return habitKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Insert a new habit
  Future<int> insertHabit(Habit habit) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Inserting habit for userId: $userId');

      final habitData = _habitToJson(habit);
      habitData['userId'] = userId;

      final response = await _api.post(ApiConfig.HABITS_ADD, habitData);

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

  /// Retrieve all habits
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

  /// Get habits by frequency (Daily, Weekly, Monthly, Yearly)
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
        final habits = habitsList.map((json) => _habitFromJson(json)).toList();

        // Client-side filtering/reset logic (if needed)
        final now = DateTime.now();
        final List<Habit> filteredHabits = [];

        for (var habit in habits) {
          // You can add client-side date checking here if needed
          filteredHabits.add(habit);
        }

        return filteredHabits;
      }

      return [];
    } catch (e) {
      print('HabitRepo: Error getting habits by frequency: $e');
      return [];
    }
  }

  /// Update habit status
  Future<int> updateHabitStatus(String habitKeyOrTitle, String status) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Updating habit status: $habitKeyOrTitle -> $status');

      // Award/remove points based on status
      if (status == 'completed') {
        final habit = await getHabitByKey(habitKeyOrTitle);
        if (habit != null) {
          await _awardPoints(habit.points);
        }
      }

      if (status == 'active') {
        final habit = await getHabitByKey(habitKeyOrTitle);
        if (habit != null) {
          await _awardPoints(-habit.points);
        }
      }

      await _api.put(ApiConfig.HABITS_UPDATE_STATUS, {
        'userId': userId,
        'title': habitKeyOrTitle,
        'status': status,
      });

      return 1;
    } catch (e) {
      print('HabitRepo: Error updating habit status: $e');
      return 0;
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

  /// Get today's habits
  Future<List<Habit>> getTodayHabits() async {
    return await getHabitsByFrequency('Daily');
  }

  /// Check if a habit exists
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

  /// Check if a habit with the given key and frequency already exists
  Future<bool> habitExistsWithFrequency(String habitKey, String frequency) async {
    try {
      final userId = await _getCurrentUserId();
      
      final response = await _api.get(
        ApiConfig.HABITS_CHECK_EXISTS,
        params: {
          'userId': userId.toString(),
          'title': habitKey,
          'frequency': frequency,
        },
      );

      if (response['success'] == true) {
        return response['exists'] as bool? ?? false;
      }

      return false;
    } catch (e) {
      print('HabitRepo: Error checking habit exists with frequency: $e');
      return false;
    }
  }

  /// Update habit reminder settings
  Future<void> updateHabitReminder(String habitKey, bool reminder, TimeOfDay? time) async {
    try {
      final userId = await _getCurrentUserId();
      
      print('HabitRepo: Updating reminder for habit: $habitKey');

      await _api.put(ApiConfig.HABITS_UPDATE, {
        'userId': userId,
        'habitId': habitKey, // This should ideally be the actual ID
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
      
      // You'll need to create a user points endpoint
      // For now, we'll call the user profile to get current points
      final profileResponse = await _api.get(
        ApiConfig.USER_PROFILE,
        params: {'userId': userId.toString()},
      );

      if (profileResponse['success'] == true && profileResponse['user'] != null) {
        final currentPoints = profileResponse['user']['total_points'] as int? ?? 0;
        final newPoints = currentPoints + points;

        // Update points (you'll need to add this endpoint)
        // await _api.put('/user.updatePoints', {'userId': userId, 'points': newPoints});
      }
    } catch (e) {
      print('HabitRepo: Error awarding points: $e');
    }
  }

  /// Get total habit points
  /// Get total habit points
  Future<int> getTotalHabitPoints() async {
    try {
      final habits = await getAllHabits();

      int total = 0;
      for (final habit in habits) {
        if (!habit.done) continue;

        // Handles int OR Future<int> safely
        final pts = await Future.value(habit.points);
        total += pts;
      }

      return total;
    } catch (e) {
      print('HabitRepo: Error getting total habit points: $e');
      return 0;
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
      final dailyHabits = await getHabitsByFrequency('Daily');
      for (var habit in dailyHabits) {
        if (habit.done || habit.skipped) {
          await updateHabitStatus(habit.habitKey, 'active');
        }
      }
    } catch (e) {
      print('HabitRepo: Error resetting daily habits: $e');
    }
  }

  Future<void> checkAndResetOldHabits() async {
    // This logic should ideally be handled by the backend
    // For now, we'll just refresh the data
    print('HabitRepo: checkAndResetOldHabits - handled by backend');
  }
}