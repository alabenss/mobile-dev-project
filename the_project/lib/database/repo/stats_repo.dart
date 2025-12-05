import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:the_project/database/db_helper.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';

class StatsData {
  final List<double> waterData;
  final List<double> moodData; // 0..1
  final int journalingCount;
  final Map<String, double> screenTime;
  final List<String> labels;

  StatsData({
    required this.waterData,
    required this.moodData,
    required this.journalingCount,
    required this.screenTime,
    required this.labels,
  });
}

class StatsRepo {
  // Format date as yyyy-MM-dd (same as home_status / daily_moods)
  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _moodLabelToValue(String? label) {
    if (label == null || label.isEmpty) return 0.5;
    final l = label.toLowerCase();

    // Positive
    if (l.contains('happy') ||
        l.contains('joy') ||
        l.contains('joyeux') ||
        l.contains('bien') ||
        l.contains('great')) {
      return 0.85;
    }

    // Neutral / medium / confused / mixed
    if (l.contains('ok') ||
        l.contains('neut') ||
        l.contains('moyen') ||
        l.contains('average') ||
        l.contains('confus') ||
        l.contains('confused') ||
        l.contains('mix')) {
      return 0.6;
    }

    // Negative
    if (l.contains('sad') ||
        l.contains('bad') ||
        l.contains('triste') ||
        l.contains('low') ||
        l.contains('mauvais')) {
      return 0.35;
    }

    return 0.5;
  }

  String _weekdayFr(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mer';
      case DateTime.thursday:
        return 'Jeu';
      case DateTime.friday:
        return 'Ven';
      case DateTime.saturday:
        return 'Sam';
      case DateTime.sunday:
      default:
        return 'Dim';
    }
  }

  /// Generic count helper (for tables that do NOT have ISO date issues)
  Future<int> _getCount(Database db, String table,
      {String? where, List<Object?>? whereArgs}) async {
    try {
      final query =
          'SELECT COUNT(*) as c FROM $table${where != null ? ' WHERE $where' : ''}';
      final result = await db.rawQuery(query, whereArgs ?? []);
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting count from $table: $e');
      return 0;
    }
  }

  /// Specialised: journal count for a day (journals.date is ISO)
  Future<int> _getJournalCountForDay(
      Database db, int userId, String dayStr) async {
    try {
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as c FROM journals
        WHERE userId = ? AND substr(date, 1, 10) = ?
        ''',
        [userId, dayStr],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting journal count for day: $e');
      return 0;
    }
  }

  /// Specialised: journal count for a range of days (week)
  Future<int> _getJournalCountForRange(
      Database db, int userId, String from, String to) async {
    try {
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as c FROM journals
        WHERE userId = ?
        AND substr(date, 1, 10) >= ?
        AND substr(date, 1, 10) <= ?
        ''',
        [userId, from, to],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting journal count for range: $e');
      return 0;
    }
  }

  /// Load mood values from daily_moods for a date range
  Future<Map<String, double>> _getMoodValuesForRange(
      Database db, int userId, String from, String to) async {
    final map = <String, double>{};
    try {
      final rows = await db.query(
        'daily_moods',
        where: 'userId = ? AND date >= ? AND date <= ?',
        whereArgs: [userId, from, to],
      );
      for (final r in rows) {
        final dateStr = r['date'] as String;
        final label = r['moodLabel'] as String?;
        map[dateStr] = _moodLabelToValue(label);
      }
    } catch (e) {
      print('Error loading mood values from daily_moods: $e');
    }
    return map;
  }

  /// Generate empty placeholder data based on range
  StatsData _generateEmptyData(StatsRange range) {
    final today = DateTime.now();

    switch (range) {
      case StatsRange.today:
        return StatsData(
          waterData: [0.0],
          moodData: [0.5],
          journalingCount: 0,
          screenTime: {},
          labels: ['Today'],
        );
      case StatsRange.weekly:
        final labels = <String>[];
        for (int i = 6; i >= 0; i--) {
          final date = today.subtract(Duration(days: i));
          labels.add(_weekdayFr(date.weekday));
        }
        return StatsData(
          waterData: List.filled(7, 0.0),
          moodData: List.filled(7, 0.5),
          journalingCount: 0,
          screenTime: {},
          labels: labels,
        );
      case StatsRange.monthly:
        return StatsData(
          waterData: List.filled(12, 0.0),
          moodData: List.filled(12, 0.5),
          journalingCount: 0,
          screenTime: {},
          labels: [
            'W1',
            'W2',
            'W3',
            'W4',
            'W5',
            'W6',
            'W7',
            'W8',
            'W9',
            'W10',
            'W11',
            'W12'
          ],
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 0.0),
          moodData: List.filled(12, 0.5),
          journalingCount: 0,
          screenTime: {},
          labels: [
            'Jan',
            'Fév',
            'Mar',
            'Avr',
            'Mai',
            'Juin',
            'Juil',
            'Août',
            'Sep',
            'Oct',
            'Nov',
            'Déc'
          ],
        );
    }
  }

  Future<StatsData> loadWeeklyFromDb() async {
    try {
      final db = await DBHelper.database;

      // Default user
      final userId = await DBHelper.ensureDefaultUser();

      // Any home_status data?
      final countHome = await _getCount(
        db,
        'home_status',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (countHome == 0) {
        print('No home_status data for user $userId, returning empty weekly data');
        return _generateEmptyData(StatsRange.weekly);
      }

      final today = DateTime.now();
      final from = today.subtract(const Duration(days: 6));
      final fromStr = _formatDate(from);
      final toStr = _formatDate(today);

      final rows = await db.query(
        'home_status',
        where: 'date >= ? AND date <= ? AND userId = ?',
        whereArgs: [fromStr, toStr, userId],
        orderBy: 'date ASC',
      );

      // If no recent week data, take last 7 rows
      List<Map<String, dynamic>> effectiveRows = rows;
      String moodFrom = fromStr;
      String moodTo = toStr;

      if (rows.isEmpty) {
        final recentRows = await db.query(
          'home_status',
          where: 'userId = ?',
          whereArgs: [userId],
          orderBy: 'date DESC',
          limit: 7,
        );

        if (recentRows.isEmpty) {
          return _generateEmptyData(StatsRange.weekly);
        }

        effectiveRows = List<Map<String, dynamic>>.from(recentRows.reversed);
        moodFrom = effectiveRows.first['date'] as String;
        moodTo = effectiveRows.last['date'] as String;
      }

      // Load mood data from daily_moods for that period
      final moodMap =
          await _getMoodValuesForRange(db, userId, moodFrom, moodTo);

      return _processRows(effectiveRows, userId, moodMap: moodMap);
    } catch (e) {
      print('Error loading weekly data: $e');
      return _generateEmptyData(StatsRange.weekly);
    }
  }

  /// Process database rows into StatsData for weekly range
  Future<StatsData> _processRows(
    List<Map<String, dynamic>> rows,
    int userId, {
    Map<String, double>? moodMap,
  }) async {
    try {
      final db = await DBHelper.database;
      final water = <double>[];
      final mood = <double>[];
      final labels = <String>[];
      final today = DateTime.now();

      final dateMap = <String, Map<String, dynamic>>{};
      for (final r in rows) {
        final dateStr = r['date'] as String?;
        if (dateStr != null) {
          dateMap[dateStr] = r;
        }
      }

      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = _formatDate(date);

        final r = dateMap[dateStr];

        // Water from home_status
        if (r != null) {
          water.add((r['water_count'] as num?)?.toDouble() ?? 0.0);
        } else {
          water.add(0.0);
        }

        // Mood priority: daily_moods > home_status > default
        if (moodMap != null && moodMap.containsKey(dateStr)) {
          mood.add(moodMap[dateStr]!);
        } else if (r != null) {
          mood.add(_moodLabelToValue(r['mood_label'] as String?));
        } else {
          mood.add(0.5);
        }

        labels.add(_weekdayFr(date.weekday));
      }

      // Journaling count for the week (ISO date fix)
      final fromStr = _formatDate(today.subtract(const Duration(days: 6)));
      final toStr = _formatDate(today);
      final journalCount = await _getJournalCountForRange(
        db,
        userId,
        fromStr,
        toStr,
      );

      // Screen time (still simulated)
      final screenTime = <String, double>{
        'social': 1.2 + Random().nextDouble() * 1.0,
        'entertainment': 2.1 + Random().nextDouble() * 1.0,
        'productivity': 3.0 + Random().nextDouble() * 1.0,
      };

      return StatsData(
        waterData: water,
        moodData: mood,
        journalingCount: journalCount,
        screenTime: screenTime,
        labels: labels,
      );
    } catch (e) {
      print('Error processing rows: $e');
      return _generateEmptyData(StatsRange.weekly);
    }
  }

  Future<StatsData> loadForRange(StatsRange range) async {
    try {
      final weekly = await loadWeeklyFromDb();
      final db = await DBHelper.database;
      final userId = await DBHelper.ensureDefaultUser();
      final today = DateTime.now();
      final todayStr = _formatDate(today);

      switch (range) {
        case StatsRange.today:
          double todayWater = 0.0;
          double todayMood = 0.5;

          // Today water & fallback mood from home_status
          final todayRows = await db.query(
            'home_status',
            where: 'date = ? AND userId = ?',
            whereArgs: [todayStr, userId],
            limit: 1,
          );
          if (todayRows.isNotEmpty) {
            final row = todayRows.first;
            todayWater = (row['water_count'] as num?)?.toDouble() ?? 0.0;
            todayMood = _moodLabelToValue(row['mood_label'] as String?);
          }

          // Override mood from daily_moods if available
          final moodRows = await db.query(
            'daily_moods',
            where: 'userId = ? AND date = ?',
            whereArgs: [userId, todayStr],
            limit: 1,
          );
          if (moodRows.isNotEmpty) {
            final mLabel = moodRows.first['moodLabel'] as String?;
            todayMood = _moodLabelToValue(mLabel);
          }

          // Journal count (ISO date fix)
          final journalCount =
              await _getJournalCountForDay(db, userId, todayStr);

          return StatsData(
            waterData: [todayWater],
            moodData: [todayMood],
            journalingCount: journalCount,
            screenTime: weekly.screenTime,
            labels: ['Today'],
          );

        case StatsRange.weekly:
          return weekly;

        case StatsRange.monthly:
          if (weekly.waterData.isEmpty ||
              weekly.waterData.every((w) => w == 0.0)) {
            return _generateEmptyData(StatsRange.monthly);
          }

          final water = <double>[];
          final mood = <double>[];
          final labels = <String>[];

          for (int week = 0; week < 4; week++) {
            for (int day = 0; day < 7; day++) {
              if (day < weekly.waterData.length) {
                water.add(weekly.waterData[day] *
                    (0.8 + Random().nextDouble() * 0.4));
                mood.add(weekly.moodData[day]);
              } else {
                water.add(0.0);
                mood.add(0.5);
              }
            }
          }

          for (int i = 1; i <= 4; i++) {
            labels.add('W$i');
          }

          final monthlyJournalCount =
              (weekly.journalingCount * 4).clamp(0, 30);

          return StatsData(
            waterData: water.take(12).toList(),
            moodData: mood.take(12).toList(),
            journalingCount: monthlyJournalCount,
            screenTime: weekly.screenTime,
            labels: labels.take(12).toList(),
          );

        case StatsRange.yearly:
          if (weekly.waterData.isEmpty ||
              weekly.waterData.every((w) => w == 0.0)) {
            return _generateEmptyData(StatsRange.yearly);
          }

          final avgWater = weekly.waterData.reduce((a, b) => a + b) /
              weekly.waterData.length;
          final avgMood = weekly.moodData.reduce((a, b) => a + b) /
              weekly.moodData.length;

          final water = List<double>.filled(12, avgWater);
          final mood = List<double>.filled(12, avgMood);
          final labels = [
            'Jan',
            'Fév',
            'Mar',
            'Avr',
            'Mai',
            'Juin',
            'Juil',
            'Août',
            'Sep',
            'Oct',
            'Nov',
            'Déc'
          ];

          return StatsData(
            waterData: water,
            moodData: mood,
            journalingCount: weekly.journalingCount * 52,
            screenTime: weekly.screenTime,
            labels: labels,
          );
      }
    } catch (e) {
      print('Error loading stats for range $range: $e');
      return _generateEmptyData(range);
    }
  }
}
