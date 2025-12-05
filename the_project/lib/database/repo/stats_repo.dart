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
  // Format date as yyyy-MM-dd
  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _moodLabelToValue(String? label) {
    if (label == null || label.isEmpty) return 0.5;
    final l = label.toLowerCase();
    if (l.contains('happy') || l.contains('joy') || l.contains('bien') || l.contains('great')) {
      return 0.85;
    }
    if (l.contains('ok') || l.contains('neut') || l.contains('moyen') || l.contains('average')) {
      return 0.6;
    }
    if (l.contains('sad') || l.contains('bad') || l.contains('triste') || l.contains('low')) {
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

  /// Helper method to get count safely
  Future<int> _getCount(Database db, String table, {String? where, List<Object?>? whereArgs}) async {
    try {
      final query = 'SELECT COUNT(*) as c FROM $table${where != null ? ' WHERE $where' : ''}';
      final result = await db.rawQuery(query, whereArgs ?? []);
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting count from $table: $e');
      return 0;
    }
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
          labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'W12'],
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 0.0),
          moodData: List.filled(12, 0.5),
          journalingCount: 0,
          screenTime: {},
          labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'],
        );
    }
  }

  Future<StatsData> loadWeeklyFromDb() async {
    try {
      final db = await DBHelper.database;
      
      // Get default user ID
      final userId = await DBHelper.ensureDefaultUser();
      
      // Check if we have any data for this user
      final countHome = await _getCount(db, 'home_status', where: 'userId = ?', whereArgs: [userId]);
      
      if (countHome == 0) {
        print('No data found for user $userId, returning empty data');
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

      // If no recent data, get the most recent available
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
        
        return _processRows(List.from(recentRows.reversed), userId);
      }

      return _processRows(rows, userId);
    } catch (e) {
      print('Error loading weekly data: $e');
      return _generateEmptyData(StatsRange.weekly);
    }
  }

  /// Process database rows into StatsData
  Future<StatsData> _processRows(List<Map<String, dynamic>> rows, int userId) async {
    try {
      final db = await DBHelper.database;
      final water = <double>[];
      final mood = <double>[];
      final labels = <String>[];
      final today = DateTime.now();

      // Fill in missing days with zeros
      final dateMap = <String, Map<String, dynamic>>{};
      for (final r in rows) {
        final dateStr = r['date'] as String?;
        if (dateStr != null) {
          dateMap[dateStr] = r;
        }
      }

      // Generate data for last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = _formatDate(date);
        
        if (dateMap.containsKey(dateStr)) {
          final r = dateMap[dateStr]!;
          water.add((r['water_count'] as num?)?.toDouble() ?? 0.0);
          mood.add(_moodLabelToValue(r['mood_label'] as String?));
        } else {
          water.add(0.0);
          mood.add(0.5);
        }
        
        labels.add(_weekdayFr(date.weekday));
      }

      // Journaling count for the week
      final fromStr = _formatDate(today.subtract(Duration(days: 6)));
      final toStr = _formatDate(today);
      final journalCount = await _getCount(
        db, 
        'journals', 
        where: 'userId = ? AND date >= ? AND date <= ?',
        whereArgs: [userId, fromStr, toStr],
      );

      // Screen time data (simulated)
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
      
      switch (range) {
        case StatsRange.today:
          final db = await DBHelper.database;
          final userId = await DBHelper.ensureDefaultUser();
          final todayStr = _formatDate(DateTime.now());
          
          // Get today's data
          final todayRows = await db.query(
            'home_status',
            where: 'date = ? AND userId = ?',
            whereArgs: [todayStr, userId],
            limit: 1,
          );
          
          double todayWater = 0.0;
          double todayMood = 0.5;
          
          if (todayRows.isNotEmpty) {
            final row = todayRows.first;
            todayWater = (row['water_count'] as num?)?.toDouble() ?? 0.0;
            todayMood = _moodLabelToValue(row['mood_label'] as String?);
          }
          
          // Check journal entries for today
          final journalCount = await _getCount(
            db, 
            'journals', 
            where: 'userId = ? AND date = ?',
            whereArgs: [userId, todayStr],
          );
          
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
          // If we have no weekly data, return empty
          if (weekly.waterData.isEmpty || weekly.waterData.every((w) => w == 0.0)) {
            return _generateEmptyData(StatsRange.monthly);
          }
          
          // Simulate monthly data based on weekly pattern
          final water = <double>[];
          final mood = <double>[];
          final labels = <String>[];
          
          // Create 4 weeks of data
          for (int week = 0; week < 4; week++) {
            for (int day = 0; day < 7; day++) {
              if (day < weekly.waterData.length) {
                water.add(weekly.waterData[day] * (0.8 + Random().nextDouble() * 0.4));
                mood.add(weekly.moodData[day]);
              } else {
                water.add(0.0);
                mood.add(0.5);
              }
            }
          }
          
          // Create week labels
          for (int i = 1; i <= 4; i++) {
            labels.add('W$i');
          }
          
          final monthlyJournalCount = (weekly.journalingCount * 4).clamp(0, 30);
          
          return StatsData(
            waterData: water.take(12).toList(), // Take only 12 points for cleaner display
            moodData: mood.take(12).toList(),
            journalingCount: monthlyJournalCount,
            screenTime: weekly.screenTime,
            labels: labels.take(12).toList(),
          );

        case StatsRange.yearly:
          // If we have no weekly data, return empty
          if (weekly.waterData.isEmpty || weekly.waterData.every((w) => w == 0.0)) {
            return _generateEmptyData(StatsRange.yearly);
          }
          
          final avgWater = weekly.waterData.reduce((a, b) => a + b) / weekly.waterData.length;
          final avgMood = weekly.moodData.reduce((a, b) => a + b) / weekly.moodData.length;

          final water = List<double>.filled(12, avgWater);
          final mood = List<double>.filled(12, avgMood);
          final labels = [
            'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
            'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
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