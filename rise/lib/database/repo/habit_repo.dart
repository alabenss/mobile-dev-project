import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';
import '../../models/habit_model.dart';
import '../../services/notification_service.dart';

class HabitRepository {
  final NotificationService _notificationService = NotificationService();

  /// Get the current logged-in user's ID
  Future<int> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId == null) {
      return await DBHelper.ensureDefaultUser();
    }
    
    return userId;
  }

  /// Convert a Habit object to a Map for database storage
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
    };
  }

  /// Convert a database Map to a Habit object
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
    );
  }

  String _getLocalizedTitle(String habitKey) {
    return habitKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Insert a new habit into the database
  Future<int> insertHabit(Habit habit) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    final map = _habitToMap(habit);
    map['userId'] = userId;

    final id = await db.insert('habits', map);

    // Schedule notification if reminder is enabled
    if (habit.reminder && habit.time != null) {
      await _notificationService.scheduleHabitReminder(habit, userId);
    }

    return id;
  }

  /// Retrieve all habits from the database
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

  /// Get habits by frequency (Daily, Weekly, Monthly, Yearly)
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
          shouldShow = _isSameDay(lastUpdated, now);
          break;
          
        case 'weekly':
          shouldShow = _isSameWeek(lastUpdated, now);
          break;
          
        case 'monthly':
          shouldShow = _isSameMonth(lastUpdated, now);
          break;
          
        case 'yearly':
          shouldShow = _isSameYear(lastUpdated, now);
          break;
          
        default:
          shouldShow = true;
      }

      if (!shouldShow) {
        await db.update(
          'habits',
          {
            'status': 'active',
            'lastUpdated': now.toIso8601String(),
          },
          where: 'userId = ? AND title = ? AND frequency = ?',
          whereArgs: [userId, map['title'], frequency],
        );
        map['status'] = 'active';
        map['lastUpdated'] = now.toIso8601String();
      }

      habits.add(_mapToHabit(map, null));
    }

    return habits;
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
        case 'yearly':
          shouldReset = !_isSameYear(lastUpdated, now);
          break;
      }

      if (shouldReset && habitMap['status'] != 'active') {
        await db.update(
          'habits',
          {
            'status': 'active',
            'lastUpdated': now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [habitMap['id']],
        );

        // Reschedule notification if needed
        final habit = _mapToHabit(habitMap, null);
        if (habit.reminder && habit.time != null) {
          await _notificationService.scheduleHabitReminder(habit, userId);
        }
      }
    }
  }

  /// Update habit status
  Future<int> updateHabitStatus(String habitKeyOrTitle, String status) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

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

    return await db.update(
      'habits',
      {
        'status': status,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKeyOrTitle],
    );
  }

  /// Get a specific habit by habitKey
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

  /// Get a specific habit by title (kept for backward compatibility)
  Future<Habit?> getHabitByTitle(String title) async {
    return await getHabitByKey(title);
  }

  /// Delete a habit by habitKey
  Future<int> deleteHabit(String habitKey) async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

    // Cancel notification before deleting
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

    // Cancel all notifications
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

  /// Check if a habit exists using habitKey
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

  /// Check if a habit with the given key and frequency already exists
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

  /// Update habit reminder settings
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

    // Update notification
    final habit = await getHabitByKey(habitKey);
    if (habit != null) {
      if (reminder && time != null) {
        await _notificationService.scheduleHabitReminder(habit, userId);
      } else {
        await _notificationService.cancelHabitReminder(habit, userId);
      }
    }
  }

  /// Reschedule all habit notifications (useful after app restart)
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