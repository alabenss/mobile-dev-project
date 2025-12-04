import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../../models/habit_model.dart';

class HabitRepository {
  /// Convert a Habit object to a Map for database storage
  Map<String, dynamic> _habitToMap(Habit habit) {
    return {
      'title': habit.title,
      'description': '',
      'frequency': habit.frequency,
      'status': habit.done ? 'completed' : (habit.skipped ? 'skipped' : 'active'),
      'createdDate': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'Doitat': habit.time != null
          ? '${habit.time!.hour.toString().padLeft(2, '0')}:${habit.time!.minute.toString().padLeft(2, '0')}'
          : null,
      'points': habit.points, // Use the habit's points value
    };
  }

  /// Convert a database Map to a Habit object
  Habit _mapToHabit(Map<String, dynamic> map) {
    // Parse icon from title or use default
    IconData icon = _getIconForTitle(map['title'] as String);

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
      title: map['title'] as String,
      icon: icon,
      frequency: map['frequency'] as String,
      time: time,
      reminder: map['Doitat'] != null && map['Doitat'] != '',
      points: map['points'] as int? ?? 10, // Get points from database
      done: status == 'completed',
      skipped: status == 'skipped',
    );
  }

  /// Get appropriate icon based on habit title
  IconData _getIconForTitle(String title) {
    final Map<String, IconData> iconMap = {
      'Drink Water': Icons.local_drink,
      'Exercise': Icons.fitness_center,
      'Meditate': Icons.self_improvement,
      'Read': Icons.book,
      'Sleep Early': Icons.bedtime,
      'Study': Icons.school,
      'Walk': Icons.directions_walk,
    };

    return iconMap[title] ?? Icons.star_border;
  }

  /// Calculate points based on frequency
  int _getPointsForFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 10;
      case 'weekly':
        return 50;
      case 'monthly':
        return 200;
      case 'yearly':
        return 1000;
      default:
        return 10;
    }
  }

  /// Insert a new habit into the database
  Future<int> insertHabit(Habit habit) async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    final map = _habitToMap(habit);
    map['userId'] = userId;

    return await db.insert('habits', map);
  }

  /// Retrieve all habits from the database
  Future<List<Habit>> getAllHabits() async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdDate DESC',
    );

    return maps.map((map) => _mapToHabit(map)).toList();
  }

  /// Get habits by frequency (Daily, Weekly, Monthly, Yearly)
  Future<List<Habit>> getHabitsByFrequency(String frequency) async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'userId = ? AND frequency = ?',
      whereArgs: [userId, frequency],
      orderBy: 'createdDate DESC',
    );

    // Filter habits based on their period
    final now = DateTime.now();
    final List<Habit> habits = [];

    for (var map in maps) {
      final lastUpdated = DateTime.parse(map['lastUpdated'] as String);
      
      bool shouldShow = false;

      switch (frequency.toLowerCase()) {
        case 'daily':
          // Show if updated today
          shouldShow = _isSameDay(lastUpdated, now);
          break;
          
        case 'weekly':
          // Show if updated in current week
          shouldShow = _isSameWeek(lastUpdated, now);
          break;
          
        case 'monthly':
          // Show if updated in current month
          shouldShow = _isSameMonth(lastUpdated, now);
          break;
          
        case 'yearly':
          // Show if updated in current year
          shouldShow = _isSameYear(lastUpdated, now);
          break;
          
        default:
          shouldShow = true;
      }

      // If habit is from a previous period and was completed/skipped, reset it
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

      habits.add(_mapToHabit(map));
    }

    return habits;
  }

  /// Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if two dates are in the same week (Monday as start)
  bool _isSameWeek(DateTime date1, DateTime date2) {
    // Get Monday of the week for both dates
    final monday1 = _getMondayOfWeek(date1);
    final monday2 = _getMondayOfWeek(date2);
    return _isSameDay(monday1, monday2);
  }

  /// Get the Monday of the week for a given date
  DateTime _getMondayOfWeek(DateTime date) {
    // DateTime.weekday returns 1 for Monday, 7 for Sunday
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(
      Duration(days: daysFromMonday),
    );
  }

  /// Check if two dates are in the same month
  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Check if two dates are in the same year
  bool _isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  /// Check and reset habits from previous periods
  Future<void> checkAndResetOldHabits() async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();
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

      // Reset if from previous period
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

  /// Update habit status (active, completed, skipped)
  Future<int> updateHabitStatus(String title, String status) async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    // If completed, award points
    if (status == 'completed') {
      final habit = await getHabitByTitle(title);
      if (habit != null) {
        await _awardPoints(habit.points); // Use the habit's specific points
      }
    }

    return await db.update(
      'habits',
      {
        'status': status,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, title],
    );
  }

  /// Get a specific habit by title
  Future<Habit?> getHabitByTitle(String title) async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, title],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToHabit(maps.first);
  }

  /// Delete a habit by title
  Future<int> deleteHabit(String title) async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    return await db.delete(
      'habits',
      where: 'userId = ? AND title = ?',
      whereArgs: [userId, title],
    );
  }

  /// Delete all habits
  Future<int> deleteAllHabits() async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    return await db.delete(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Get count of completed habits
  Future<int> getCompletedHabitsCount() async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM habits WHERE userId = ? AND status = ?',
      [userId, 'completed'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get habits that are due today (based on frequency and last completed date)
  Future<List<Habit>> getTodayHabits() async {
    // This is a simplified version - you might want to add more logic
    // based on when habits were last completed
    return await getHabitsByFrequency('Daily');
  }

  /// Reset daily habit statuses (call this at the start of each day)
  Future<void> resetDailyHabits() async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    await db.update(
      'habits',
      {'status': 'active'},
      where: 'userId = ? AND frequency = ? AND status != ?',
      whereArgs: [userId, 'Daily', 'active'],
    );
  }

  /// Award points to user when completing a habit
  Future<void> _awardPoints(int points) async {
    final currentPoints = await DBHelper.getUserTotalPoints();
    await DBHelper.setUserTotalPoints(currentPoints + points);
  }

  /// Get total points earned from all completed habits
  Future<int> getTotalHabitPoints() async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

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

  /// Check if a habit with the given title already exists
  Future<bool> habitExists(String title) async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    final result = await db.query(
      'habits',
      where: 'userId = ? AND LOWER(title) = ?',
      whereArgs: [userId, title.toLowerCase()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Check if a habit with the given title and frequency already exists
  Future<bool> habitExistsWithFrequency(String title, String frequency) async {
    final db = await DBHelper.database;
    final userId = await DBHelper.ensureDefaultUser();

    final result = await db.query(
      'habits',
      where: 'userId = ? AND LOWER(title) = ? AND frequency = ?',
      whereArgs: [userId, title.toLowerCase(), frequency],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}