import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // Get current logged-in user ID
  Future<int?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      print('StatsRepo: Retrieved userId from SharedPreferences: $userId');
      return userId;
    } catch (e) {
      print('StatsRepo: Error getting userId: $e');
      return null;
    }
  }

  // Format date as yyyy-MM-dd
  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _moodLabelToValue(String? label) {
    if (label == null || label.isEmpty) return 0.5;
    final l = label.toLowerCase();

    // Positive moods (0.75-1.0)
    if (l.contains('happy') || l.contains('joy') || l.contains('great') || 
        l.contains('excited') || l.contains('awesome') || l.contains('amazing')) {
      return 0.9;
    }
    
    // Good moods (0.6-0.75)
    if (l.contains('good') || l.contains('nice') || l.contains('calm') || 
        l.contains('peaceful') || l.contains('content') || l.contains('bien')) {
      return 0.7;
    }
    
    // Neutral moods (0.45-0.6)
    if (l.contains('ok') || l.contains('neutral') || l.contains('average') || 
        l.contains('meh') || l.contains('fine') || l.contains('moyen') || l.contains('confus')) {
      return 0.5;
    }
    
    // Low moods (0.25-0.45)
    if (l.contains('sad') || l.contains('low') || l.contains('tired') || 
        l.contains('anxious') || l.contains('stressed') || l.contains('triste')) {
      return 0.35;
    }
    
    // Very low moods (0.0-0.25)
    if (l.contains('bad') || l.contains('terrible') || l.contains('angry') || 
        l.contains('depressed') || l.contains('awful') || l.contains('mauvais')) {
      return 0.1;
    }

    return 0.5;
  }

  /// Get combined mood from both daily_moods and journals tables
  Future<double> _getMoodForDate(Database db, int userId, String dateStr) async {
    final moodValues = <double>[];
    
    // Get mood from daily_moods table
    final dailyMoodRows = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, dateStr],
      limit: 1,
    );
    if (dailyMoodRows.isNotEmpty) {
      final label = dailyMoodRows.first['moodLabel'] as String?;
      moodValues.add(_moodLabelToValue(label));
    }
    
    // Get moods from journals table (can be multiple journals per day)
    final journalRows = await db.query(
      'journals',
      columns: ['mood'],
      where: 'userId = ? AND substr(date, 1, 10) = ?',
      whereArgs: [userId, dateStr],
    );
    for (final row in journalRows) {
      final label = row['mood'] as String?;
      if (label != null && label.isNotEmpty) {
        moodValues.add(_moodLabelToValue(label));
      }
    }
    
    // Return average of all moods for this day, or 0.5 if no moods found
    if (moodValues.isEmpty) return 0.5;
    return moodValues.reduce((a, b) => a + b) / moodValues.length;
  }

  /// Get average detox progress for screen time
  Future<Map<String, double>> _getScreenTimeData(Database db, int userId, String startDate, String endDate) async {
    final detoxRows = await db.query(
      'home_status',
      columns: ['detox_progress'],
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startDate, endDate],
    );
    
    if (detoxRows.isEmpty) {
      return {'detox': 0.0};
    }
    
    double totalDetox = 0.0;
    for (final row in detoxRows) {
      totalDetox += (row['detox_progress'] as num?)?.toDouble() ?? 0.0;
    }
    
    final avgDetox = totalDetox / detoxRows.length;
    return {'detox': avgDetox};
  }

  String _weekdayFr(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return 'Day';
    }
  }

  String _monthFr(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return 'Month';
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
          screenTime: {'detox': 0.0},
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
          screenTime: {'detox': 0.0},
          labels: labels,
        );
      case StatsRange.monthly:
        return StatsData(
          waterData: List.filled(4, 0.0),
          moodData: List.filled(4, 0.5),
          journalingCount: 0,
          screenTime: {'detox': 0.0},
          labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 0.0),
          moodData: List.filled(12, 0.5),
          journalingCount: 0,
          screenTime: {'detox': 0.0},
          labels: List.generate(12, (i) => _monthFr(i + 1)),
        );
    }
  }

  /// Load data for today
  Future<StatsData> _loadTodayData(int userId) async {
    try {
      final db = await DBHelper.database;
      final today = DateTime.now();
      final todayStr = _formatDate(today);
      
      print('StatsRepo: Loading today data for date: $todayStr, userId: $userId');
      
      // Water data
      double water = 0.0;
      final waterRows = await db.query(
        'home_status',
        where: 'userId = ? AND date = ?',
        whereArgs: [userId, todayStr],
        limit: 1,
      );
      if (waterRows.isNotEmpty) {
        water = (waterRows.first['water_count'] as num?)?.toDouble() ?? 0.0;
        print('StatsRepo: Water count: $water');
      } else {
        print('StatsRepo: No water data found for today');
      }
      
      // Mood data (combined from both tables)
      final mood = await _getMoodForDate(db, userId, todayStr);
      print('StatsRepo: Combined mood: $mood');
      
      // Journal count
      int journalCount = await DBHelper.getJournalCountForRange(userId, todayStr, todayStr);
      print('StatsRepo: Journal count: $journalCount');
      
      // Screen time (detox average)
      final screenTime = await _getScreenTimeData(db, userId, todayStr, todayStr);
      
      return StatsData(
        waterData: [water],
        moodData: [mood],
        journalingCount: journalCount,
        screenTime: screenTime,
        labels: ['Today'],
      );
    } catch (e) {
      print('StatsRepo: Error loading today data: $e');
      return _generateEmptyData(StatsRange.today);
    }
  }

  /// Load data for weekly range (last 7 days)
  Future<StatsData> _loadWeeklyData(int userId) async {
    try {
      final db = await DBHelper.database;
      final today = DateTime.now();
      
      final waterData = <double>[];
      final moodData = <double>[];
      final labels = <String>[];
      int totalJournalCount = 0;
      
      print('StatsRepo: Loading weekly data for userId: $userId');
      
      final firstDay = today.subtract(const Duration(days: 6));
      final lastDay = today;
      
      // Get last 7 days including today
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = _formatDate(date);
        labels.add(_weekdayFr(date.weekday));
        
        // Water data
        double water = 0.0;
        final waterRows = await db.query(
          'home_status',
          where: 'userId = ? AND date = ?',
          whereArgs: [userId, dateStr],
          limit: 1,
        );
        if (waterRows.isNotEmpty) {
          water = (waterRows.first['water_count'] as num?)?.toDouble() ?? 0.0;
        }
        waterData.add(water);
        
        // Mood data (combined from both tables)
        final mood = await _getMoodForDate(db, userId, dateStr);
        moodData.add(mood);
        
        // Journal count for this day
        final count = await DBHelper.getJournalCountForRange(userId, dateStr, dateStr);
        totalJournalCount += count;
      }
      
      print('StatsRepo: Weekly totals - Water: $waterData, Mood: $moodData, Journals: $totalJournalCount');
      
      // Screen time (detox average for the week)
      final screenTime = await _getScreenTimeData(db, userId, _formatDate(firstDay), _formatDate(lastDay));
      
      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournalCount,
        screenTime: screenTime,
        labels: labels,
      );
    } catch (e) {
      print('StatsRepo: Error loading weekly data: $e');
      return _generateEmptyData(StatsRange.weekly);
    }
  }

  /// Load data for monthly range (last 4 weeks)
  Future<StatsData> _loadMonthlyData(int userId) async {
    try {
      final today = DateTime.now();
      final db = await DBHelper.database;
      
      final waterData = <double>[];
      final moodData = <double>[];
      final labels = <String>[];
      int totalJournalCount = 0;
      
      print('StatsRepo: Loading monthly data for userId: $userId');
      
      final firstDay = today.subtract(const Duration(days: 27)); // 4 weeks = 28 days
      
      // Group by weeks (4 weeks of 7 days each, going backwards from today)
      for (int week = 3; week >= 0; week--) {
        double weekWater = 0.0;
        double weekMood = 0.0;
        int daysWithWater = 0;
        int daysWithMood = 0;
        
        // Calculate days for this week
        for (int day = 0; day < 7; day++) {
          final daysAgo = (week * 7) + day;
          final date = today.subtract(Duration(days: daysAgo));
          final dateStr = _formatDate(date);
          
          // Water data
          final waterRows = await db.query(
            'home_status',
            where: 'userId = ? AND date = ?',
            whereArgs: [userId, dateStr],
            limit: 1,
          );
          if (waterRows.isNotEmpty) {
            final water = (waterRows.first['water_count'] as num?)?.toDouble() ?? 0.0;
            weekWater += water;
            daysWithWater++;
          }
          
          // Mood data (combined from both tables)
          final mood = await _getMoodForDate(db, userId, dateStr);
          weekMood += mood;
          daysWithMood++;
          
          // Journal count
          final count = await DBHelper.getJournalCountForRange(userId, dateStr, dateStr);
          totalJournalCount += count;
        }
        
        // Add weekly averages (insert at beginning to maintain chronological order)
        waterData.insert(0, daysWithWater > 0 ? weekWater / daysWithWater : 0.0);
        moodData.insert(0, daysWithMood > 0 ? weekMood / daysWithMood : 0.5);
        labels.insert(0, 'W${4 - week}');
      }
      
      print('StatsRepo: Monthly totals - Journals: $totalJournalCount');
      
      // Screen time (detox average for the month)
      final screenTime = await _getScreenTimeData(db, userId, _formatDate(firstDay), _formatDate(today));
      
      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournalCount,
        screenTime: screenTime,
        labels: labels,
      );
    } catch (e) {
      print('StatsRepo: Error loading monthly data: $e');
      return _generateEmptyData(StatsRange.monthly);
    }
  }

  /// Load data for yearly range (last 12 months)
  Future<StatsData> _loadYearlyData(int userId) async {
    try {
      final today = DateTime.now();
      final db = await DBHelper.database;
      
      final waterData = <double>[];
      final moodData = <double>[];
      final labels = <String>[];
      int totalJournalCount = 0;
      
      print('StatsRepo: Loading yearly data for userId: $userId');
      
      // Get data for each of the last 12 months
      for (int monthOffset = 11; monthOffset >= 0; monthOffset--) {
        // Calculate the target month
        int targetYear = today.year;
        int targetMonth = today.month - monthOffset;
        
        // Handle year wraparound
        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear -= 1;
        }
        
        final monthStart = DateTime(targetYear, targetMonth, 1);
        final monthEnd = DateTime(targetYear, targetMonth + 1, 0); // Last day of month
        
        final startStr = _formatDate(monthStart);
        final endStr = _formatDate(monthEnd);
        
        // Water data for month
        double monthWater = 0.0;
        int waterDays = 0;
        final waterRows = await db.query(
          'home_status',
          where: 'userId = ? AND date >= ? AND date <= ?',
          whereArgs: [userId, startStr, endStr],
        );
        for (final row in waterRows) {
          monthWater += (row['water_count'] as num?)?.toDouble() ?? 0.0;
          waterDays++;
        }
        
        // Mood data for month (combined from both tables)
        double monthMood = 0.0;
        int moodDays = 0;
        
        // Get all days in the month
        for (int day = monthStart.day; day <= monthEnd.day; day++) {
          final date = DateTime(targetYear, targetMonth, day);
          final dateStr = _formatDate(date);
          
          final mood = await _getMoodForDate(db, userId, dateStr);
          monthMood += mood;
          moodDays++;
        }
        
        // Journal count for month
        totalJournalCount += await DBHelper.getJournalCountForRange(userId, startStr, endStr);
        
        // Add monthly data
        waterData.add(waterDays > 0 ? monthWater / waterDays : 0.0);
        moodData.add(moodDays > 0 ? monthMood / moodDays : 0.5);
        labels.add(_monthFr(targetMonth));
      }
      
      print('StatsRepo: Yearly totals - Journals: $totalJournalCount');
      
      // Screen time (detox average for the year)
      final yearStart = DateTime(today.year - 1, today.month, today.day);
      final screenTime = await _getScreenTimeData(db, userId, _formatDate(yearStart), _formatDate(today));
      
      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournalCount,
        screenTime: screenTime,
        labels: labels,
      );
    } catch (e) {
      print('StatsRepo: Error loading yearly data: $e');
      return _generateEmptyData(StatsRange.yearly);
    }
  }

  /// Main method to load data for any range
  Future<StatsData> loadForRange(StatsRange range) async {
    try {
      // Get logged-in user ID from SharedPreferences
      final userId = await _getCurrentUserId();
      
      if (userId == null) {
        print('StatsRepo: No logged-in user found! Using fallback.');
        // Fallback to default user if no one is logged in
        final fallbackUserId = await DBHelper.ensureDefaultUser();
        print('StatsRepo: Using fallback userId: $fallbackUserId');
        
        // Debug print user data
        await DBHelper.debugPrintUserData(fallbackUserId);
        
        return await _loadDataForUser(fallbackUserId, range);
      }
      
      print('StatsRepo: Loading stats for range: $range, userId: $userId');
      
      // Debug print user data
      await DBHelper.debugPrintUserData(userId);
      
      return await _loadDataForUser(userId, range);
    } catch (e) {
      print('StatsRepo: Error loading stats for range $range: $e');
      return _generateEmptyData(range);
    }
  }

  /// Load data for a specific user and range
  Future<StatsData> _loadDataForUser(int userId, StatsRange range) async {
    switch (range) {
      case StatsRange.today:
        return await _loadTodayData(userId);
      case StatsRange.weekly:
        return await _loadWeeklyData(userId);
      case StatsRange.monthly:
        return await _loadMonthlyData(userId);
      case StatsRange.yearly:
        return await _loadYearlyData(userId);
    }
  }
}