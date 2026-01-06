import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';
import '../../models/habit_model.dart';
import '../../services/notification_service.dart';

class HabitRepository {
  NotificationService get _notificationService => NotificationService.instance;

  Future<int> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId == null) {
      return await DBHelper.ensureDefaultUser();
    }
    
    return userId;
  }

  Map<String, dynamic> _habitToMap(Habit habit) {
    return {
      'title': habit.habitKey,
      'description': habit.iconCodePoint.toString(),
      'frequency': habit.frequency,
      'status': habit.done ? 'completed' : (habit.skipped ? 'skipped' : 'active'),
      'createdDate': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'Doitat': habit.time != null
          ? '${habit.time!.hour.toString().padLeft(2, '0')}:${habit.time!.minute.toString().padLeft(2, '0')}'
          : null,
      'points': habit.points,
      'remindMe': habit.reminder ? 1 : 0,
      'habitType': habit.habitType,
      'streakCount': habit.streakCount,
      'bestStreak': habit.bestStreak,
      'isTask': habit.isTask ? 1 : 0,
      'taskCompletionCount': habit.taskCompletionCount,
      'lastCompletedDate': habit.lastCompletedDate?.toIso8601String(),
    };
  }

  Habit _mapToHabit(Map<String, dynamic> map, String? localizedTitle) {
    String habitKey = map['title'] as String;
    
    IconData icon;
    try {
      final iconCode = int.parse(map['description'] as String? ?? '0');
      if (iconCode > 0) {
        icon = Habit.iconFromCodePoint(iconCode);
      } else {
        icon = Habit.getIconForKey(habitKey);
      }
    } catch (e) {
      icon = Habit.getIconForKey(habitKey);
    }

    String displayTitle = localizedTitle ?? _getLocalizedTitle(habitKey);

    TimeOfDay? time;
    if (map['Doitat'] != null && map['Doitat'] != '') {
      final parts = (map['Doitat'] as String).split(':');
      if (parts.length == 2) {
        time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
    
    final status = (map['status'] as String?) ?? 'active';
    final remindMe = (map['remindMe'] as int?) ?? 0;
    final habitType = (map['habitType'] as String?) ?? 'good';
    final streakCount = (map['streakCount'] as int?) ?? 0;
    final bestStreak = (map['bestStreak'] as int?) ?? 0;
    final isTask = ((map['isTask'] as int?) ?? 1) == 1;
    final taskCompletionCount = (map['taskCompletionCount'] as int?) ?? 0;
    
    DateTime? lastCompletedDate;
    if (map['lastCompletedDate'] != null) {
      lastCompletedDate = DateTime.parse(map['lastCompletedDate'] as String);
    }

    return Habit(
      title: displayTitle,
      habitKey: habitKey,
      icon: icon,
      frequency: map['frequency'] as String,
      time: time,
      reminder: remindMe == 1,
      points: map['points'] as int? ?? 10,
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

  Future<int> insertHabit(Habit habit) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final map = _habitToMap(habit);
    map['userId'] = userId;

    final id = await db.insert('habits', map);

    if (habit.reminder && habit.time != null) {
      await _notificationService.scheduleHabitReminder(habit, userId);
    }

    return id;
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdDate DESC',
    );

    return maps.map((map) => _mapToHabit(map, null)).toList();
  }

  /// Get habits by frequency - ONLY show habits that should appear in this period
  Future<List<Habit>> getHabitsByFrequency(String frequency) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'userId = ? AND frequency = ?',
      whereArgs: [userId, frequency],
      orderBy: 'createdDate DESC',
    );

    final now = DateTime.now();
    final List<Habit> habits = [];

    for (var map in maps) {
      final lastUpdated = DateTime.parse(map['lastUpdated'] as String);
      
      bool shouldShow = false;

      switch (frequency.toLowerCase()) {
        case 'daily':
          // Only show if last updated TODAY
          shouldShow = _isSameDay(lastUpdated, now);
          break;
          
        case 'weekly':
          // Only show if last updated THIS WEEK
          shouldShow = _isSameWeek(lastUpdated, now);
          break;
          
        case 'monthly':
          // Only show if last updated THIS MONTH
          shouldShow = _isSameMonth(lastUpdated, now);
          break;
          
        default:
          shouldShow = true;
      }

      // If habit is from a previous period, reset it
      if (!shouldShow) {
        // Reset status but check streak
        await _handlePeriodTransition(db, userId, map, frequency, now);
        map['status'] = 'active';
        map['lastUpdated'] = now.toIso8601String();
      }

      habits.add(_mapToHabit(map, null));
    }

    return habits;
  }

  /// Handle streak when transitioning between periods
  Future<void> _handlePeriodTransition(
    Database db,
    int userId,
    Map<String, dynamic> habitMap,
    String frequency,
    DateTime now,
  ) async {
    final lastUpdated = DateTime.parse(habitMap['lastUpdated'] as String);
    final status = habitMap['status'] as String;
    final habitType = (habitMap['habitType'] as String?) ?? 'good';
    int currentStreak = (habitMap['streakCount'] as int?) ?? 0;
    int bestStreak = (habitMap['bestStreak'] as int?) ?? 0;
    final lastCompletedDateStr = habitMap['lastCompletedDate'] as String?;
    
    // Check if the streak should continue or break
    bool streakBroken = false;
    
    switch (frequency.toLowerCase()) {
      case 'daily':
        // For daily habits, check if it was completed yesterday
        final yesterday = now.subtract(const Duration(days: 1));
        if (lastCompletedDateStr != null) {
          final lastCompleted = DateTime.parse(lastCompletedDateStr);
          if (!_isSameDay(lastCompleted, yesterday)) {
            // Didn't complete yesterday, streak is broken
            if (habitType == 'good') {
              streakBroken = true;
            }
          } else if (status == 'completed' || (habitType == 'bad' && status == 'skipped')) {
            // Completed yesterday, increment streak
            currentStreak++;
            if (currentStreak > bestStreak) {
              bestStreak = currentStreak;
            }
          }
        } else if (habitType == 'good') {
          // Never completed, break streak if it was > 0
          streakBroken = currentStreak > 0;
        }
        break;
        
      case 'weekly':
        // For weekly habits, check if completed last week
        final lastWeek = now.subtract(const Duration(days: 7));
        if (lastCompletedDateStr != null) {
          final lastCompleted = DateTime.parse(lastCompletedDateStr);
          if (!_isSameWeek(lastCompleted, lastWeek)) {
            if (habitType == 'good') {
              streakBroken = true;
            }
          } else if (status == 'completed' || (habitType == 'bad' && status == 'skipped')) {
            currentStreak++;
            if (currentStreak > bestStreak) {
              bestStreak = currentStreak;
            }
          }
        } else if (habitType == 'good') {
          streakBroken = currentStreak > 0;
        }
        break;
        
      case 'monthly':
        // For monthly habits, check if completed last month
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        if (lastCompletedDateStr != null) {
          final lastCompleted = DateTime.parse(lastCompletedDateStr);
          if (!_isSameMonth(lastCompleted, lastMonth)) {
            if (habitType == 'good') {
              streakBroken = true;
            }
          } else if (status == 'completed' || (habitType == 'bad' && status == 'skipped')) {
            currentStreak++;
            if (currentStreak > bestStreak) {
              bestStreak = currentStreak;
            }
          }
        } else if (habitType == 'good') {
          streakBroken = currentStreak > 0;
        }
        break;
    }
    
    if (streakBroken) {
      currentStreak = 0;
    }

    await db.update(
      'habits',
      {
        'status': 'active',
        'lastUpdated': now.toIso8601String(),
        'streakCount': currentStreak,
        'bestStreak': bestStreak,
      },
      where: 'id = ?',
      whereArgs: [habitMap['id']],
    );

    final habit = _mapToHabit(habitMap, null);
    if (habit.reminder && habit.time != null) {
      await _notificationService.scheduleHabitReminder(habit, userId);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = _getMondayOfWeek(date1);
    final monday2 = _getMondayOfWeek(date2);
    return _isSameDay(monday1, monday2);
  }

  DateTime _getMondayOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(
      Duration(days: daysFromMonday),
    );
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  bool _isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  Future<void> checkAndResetOldHabits() async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();
    final now = DateTime.now();

    final List<Map<String, dynamic>> allHabits = await db.query(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    for (var habitMap in allHabits) {
      final lastUpdated = DateTime.parse(habitMap['lastUpdated'] as String);
      final frequency = habitMap['frequency'] as String;
      bool shouldReset = false;

      switch (frequency.toLowerCase()) {
        case 'daily':
          shouldReset = !_isSameDay(lastUpdated, now);
          break;
        case 'weekly':
          shouldReset = !_isSameWeek(lastUpdated, now);
          break;
        case 'monthly':
          shouldReset = !_isSameMonth(lastUpdated, now);
          break;
      }

      if (shouldReset && habitMap['status'] != 'active') {
        await _handlePeriodTransition(db, userId, habitMap, frequency, now);

        final habit = _mapToHabit(habitMap, null);
        if (habit.reminder && habit.time != null) {
          await _notificationService.scheduleHabitReminder(habit, userId);
        }
      }
    }
  }

  /// Update habit status with streak tracking and task-to-habit conversion
  Future<int> updateHabitStatus(String habitKeyOrTitle, String status) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

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
      // Don't decrement streak when resetting, just when period transitions
    }

    return await db.update(
      'habits',
      {
        'status': status,
        'lastUpdated': DateTime.now().toIso8601String(),
        'lastCompletedDate': (status == 'completed' || status == 'skipped') 
            ? DateTime.now().toIso8601String() 
            : habit.lastCompletedDate?.toIso8601String(),
        'streakCount': newStreak,
        'bestStreak': newBestStreak,
        'taskCompletionCount': newTaskCompletion,
        'isTask': newIsTask ? 1 : 0,
      },
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKeyOrTitle],
    );
  }

  /// Restore streak using points
  Future<bool> restoreStreak(String habitKey) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();
    
    final habit = await getHabitByKey(habitKey);
    if (habit == null || !habit.needsStreakRestoration) return false;
    
    // Check if user has enough points
    final userResult = await db.query(
      'users',
      columns: ['totalPoints'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (userResult.isEmpty) return false;
    
    final currentPoints = (userResult.first['totalPoints'] as int?) ?? 0;
    final restorationCost = habit.streakRestorationCost;
    
    if (currentPoints < restorationCost) return false;
    
    // Deduct points and restore streak
    await db.update(
      'users',
      {'totalPoints': currentPoints - restorationCost},
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    await db.update(
      'habits',
      {
        'streakCount': habit.bestStreak,
        'lastCompletedDate': DateTime.now().toIso8601String(),
      },
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKey],
    );
    
    return true;
  }

  Future<Habit?> getHabitByKey(String habitKey) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKey],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToHabit(maps.first, null);
  }

  Future<Habit?> getHabitByTitle(String title) async {
    return await getHabitByKey(title);
  }

  Future<int> deleteHabit(String habitKey) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final habit = await getHabitByKey(habitKey);
    if (habit != null && habit.reminder) {
      await _notificationService.cancelHabitReminder(habit, userId);
    }

    return await db.delete(
      'habits',
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKey],
    );
  }

  Future<int> deleteAllHabits() async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    await _notificationService.cancelAllNotifications();

    return await db.delete(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> getCompletedHabitsCount() async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM habits WHERE userId = ? AND status = ?',
      [userId, 'completed'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Habit>> getTodayHabits() async {
    return await getHabitsByFrequency('Daily');
  }

  Future<void> resetDailyHabits() async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    await db.update(
      'habits',
      {'status': 'active'},
      where: 'userId = ? AND frequency = ? AND status != ?',
      whereArgs: [userId, 'Daily', 'active'],
    );
  }

  Future<void> _awardPoints(int points) async {
    final userId = await _getCurrentUserId();
    final db = await DBHelper.database;
    
    final result = await db.query(
      'users',
      columns: ['totalPoints'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    int currentPoints = 0;
    if (result.isNotEmpty) {
      final value = result.first['totalPoints'];
      if (value is int) {
        currentPoints = value;
      } else if (value is num) {
        currentPoints = value.toInt();
      }
    }
    
    await db.update(
      'users',
      {'totalPoints': currentPoints + points},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> getTotalHabitPoints() async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final result = await db.rawQuery(
      'SELECT SUM(points) as total FROM habits WHERE userId = ? AND status = ?',
      [userId, 'completed'],
    );

    final value = result.first['total'];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Future<bool> habitExists(String habitKey) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final result = await db.query(
      'habits',
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKey],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<bool> habitExistsWithFrequency(String habitKey, String frequency) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final result = await db.query(
      'habits',
      where: 'userId = ? AND title = ? AND frequency = ?',
      whereArgs: [userId, habitKey, frequency],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> updateHabitReminder(String habitKey, bool reminder, TimeOfDay? time) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    await db.update(
      'habits',
      {
        'remindMe': reminder ? 1 : 0,
        'Doitat': time != null
            ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
            : null,
      },
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKey],
    );

    final habit = await getHabitByKey(habitKey);
    if (habit != null) {
      if (reminder && time != null) {
        await _notificationService.scheduleHabitReminder(habit, userId);
      } else {
        await _notificationService.cancelHabitReminder(habit, userId);
      }
    }
  }

  Future<void> rescheduleAllNotifications() async {
    final userId = await _getCurrentUserId();
    final allHabits = await getAllHabits();

    for (var habit in allHabits) {
      if (habit.reminder && habit.time != null) {
        await _notificationService.scheduleHabitReminder(habit, userId);
      }
    }
  }
}