import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';
import '../../models/habit_model.dart';

class HabitRepository {
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
      'title': habit.habitKey, // Store the key, not the localized title
      'description': habit.iconCodePoint.toString(), // Store icon code point here
      'frequency': habit.frequency,
      'status': habit.done ? 'completed' : (habit.skipped ? 'skipped' : 'active'),
      'createdDate': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'Doitat': habit.time != null
          ? '${habit.time!.hour.toString().padLeft(2, '0')}:${habit.time!.minute.toString().padLeft(2, '0')}'
          : null,
      'points': habit.points,
    };
  }

  /// Convert a database Map to a Habit object
  Habit _mapToHabit(Map<String, dynamic> map, String? localizedTitle) {
    // Get habit key from database (stored in 'title' field)
    String habitKey = map['title'] as String;
    
    // Get icon from code point stored in description, or use key-based icon
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

    // Use localized title if provided, otherwise use the key
    String displayTitle = localizedTitle ?? _getLocalizedTitle(habitKey);

    // Parse time if available
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

    return Habit(
      title: displayTitle,
      habitKey: habitKey,
      icon: icon,
      frequency: map['frequency'] as String,
      time: time,
      reminder: map['Doitat'] != null && map['Doitat'] != '',
      points: map['points'] as int? ?? 10,
      done: status == 'completed',
      skipped: status == 'skipped',
    );
  }

  /// Get localized title for a habit key (fallback if not provided)
  String _getLocalizedTitle(String habitKey) {
    // This will just return the key formatted nicely as fallback
    // The actual localization should happen in the UI layer
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

    return await db.insert('habits', map);
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

    for (var habit in allHabits) {
      final lastUpdated = DateTime.parse(habit['lastUpdated'] as String);
      final frequency = habit['frequency'] as String;
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

      if (shouldReset && habit['status'] != 'active') {
        await db.update(
          'habits',
          {
            'status': 'active',
            'lastUpdated': now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [habit['id']],
        );
      }
    }
  }

  /// Update habit status - accepts either habitKey or title for backward compatibility
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

    return await db.delete(
      'habits',
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, habitKey],
    );
  }

  Future<int> deleteAllHabits() async {
    final db = await DBHelper.database;
    final userId = await _getCurrentUserId();

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
}