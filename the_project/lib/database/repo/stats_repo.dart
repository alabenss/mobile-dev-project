import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:the_project/database/db_helper.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsData {
  final List<double> waterData;
  final List<double> moodData;
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
  Future<int> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('currentUserId');
      
      if (userId == null) {
        print('⚠️ No currentUserId found in shared preferences');
        final defaultId = await DBHelper.ensureDefaultUser();
        await prefs.setInt('currentUserId', defaultId);
        print('✅ Created and using default user: $defaultId');
        return defaultId;
      }
      
      final db = await DBHelper.database;
      final user = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      
      if (user.isEmpty) {
        print('⚠️ User $userId not found in database, using default');
        final defaultId = await DBHelper.ensureDefaultUser();
        await prefs.setInt('currentUserId', defaultId);
        return defaultId;
      }
      
      print('✅ Using current user ID: $userId');
      return userId;
    } catch (e) {
      print('❌ Error getting current user ID: $e');
      final defaultId = await DBHelper.ensureDefaultUser();
      return defaultId;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _moodLabelToValue(String? label) {
    if (label == null || label.isEmpty) return 0.5;
    final l = label.toLowerCase();

    if (l.contains('happy') || l.contains('joy') || l.contains('joyeux') ||
        l.contains('bien') || l.contains('great') || l.contains('excited') ||
        l.contains('energetic') || l.contains('good') || l.contains('excellent') ||
        l.contains('amazing') || l.contains('fantastic')) {
      return 0.85;
    }

    if (l.contains('ok') || l.contains('neut') || l.contains('moyen') ||
        l.contains('average') || l.contains('confus') || l.contains('confused') ||
        l.contains('mix') || l.contains('calm') || l.contains('normal') ||
        l.contains('fine') || l.contains('alright') || l.contains('balanced')) {
      return 0.6;
    }

    if (l.contains('sad') || l.contains('bad') || l.contains('triste') ||
        l.contains('low') || l.contains('mauvais') || l.contains('tired') ||
        l.contains('angry') || l.contains('anxious') || l.contains('stressed') ||
        l.contains('depressed') || l.contains('worried')) {
      return 0.35;
    }

    return 0.5;
  }

  String _weekdayFr(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Lun';
      case DateTime.tuesday: return 'Mar';
      case DateTime.wednesday: return 'Mer';
      case DateTime.thursday: return 'Jeu';
      case DateTime.friday: return 'Ven';
      case DateTime.saturday: return 'Sam';
      case DateTime.sunday:
      default: return 'Dim';
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
                    'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '???';
  }

  /// DEBUG: Print all rows from home_status for today
  Future<void> _debugHomeStatus(Database db, int userId, String todayStr) async {
    print('\n🔍 DEBUG: Checking home_status table for date: $todayStr');
    
    // Get all rows for this user
    final allRows = await db.query(
      'home_status',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    print('📊 Total home_status rows for user $userId: ${allRows.length}');
    for (final row in allRows) {
      print('   📅 Date: ${row['date']}, Water: ${row['water_count']}, Mood: ${row['mood_label']}');
    }
    
    // Try to get today's row specifically
    final todayRows = await db.query(
      'home_status',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
    );
    
    print('🎯 Rows matching today ($todayStr): ${todayRows.length}');
    if (todayRows.isNotEmpty) {
      final row = todayRows.first;
      print('   ✅ Found today\'s data:');
      print('      Water: ${row['water_count']}');
      print('      Mood: ${row['mood_label']}');
      print('      Date: ${row['date']}');
    } else {
      print('   ❌ No data found for today!');
    }
  }

  /// DEBUG: Print all rows from daily_moods for today
  Future<void> _debugDailyMoods(Database db, int userId, String todayStr) async {
    print('\n🔍 DEBUG: Checking daily_moods table for date: $todayStr');
    
    final allRows = await db.query(
      'daily_moods',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    print('📊 Total daily_moods rows for user $userId: ${allRows.length}');
    for (final row in allRows) {
      print('   📅 Date: ${row['date']}, Mood: ${row['moodLabel']}');
    }
    
    final todayRows = await db.query(
      'daily_moods',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, todayStr],
    );
    
    print('🎯 Rows matching today ($todayStr): ${todayRows.length}');
    if (todayRows.isNotEmpty) {
      final row = todayRows.first;
      print('   ✅ Found today\'s mood: ${row['moodLabel']}');
    } else {
      print('   ❌ No mood data found for today!');
    }
  }

  Future<Map<String, double>> _getWaterDataForRange(
      Database db, int userId, String from, String to) async {
    final map = <String, double>{};
    try {
      final rows = await db.query(
        'home_status',
        where: 'userId = ? AND date >= ? AND date <= ?',
        whereArgs: [userId, from, to],
      );
      print('💧 Found ${rows.length} water records for user $userId from $from to $to');
      for (final r in rows) {
        final dateStr = r['date'] as String;
        final waterCount = r['water_count'] as num?;
        map[dateStr] = waterCount?.toDouble() ?? 0.0;
        print('   💧 $dateStr: ${map[dateStr]} glasses');
      }
    } catch (e) {
      print('❌ Error loading water data: $e');
    }
    return map;
  }

  Future<Map<String, double>> _getCombinedMoodForRange(
      Database db, int userId, String from, String to) async {
    final map = <String, double>{};
    
    try {
      final dailyMoodRows = await db.query(
        'daily_moods',
        where: 'userId = ? AND date >= ? AND date <= ?',
        whereArgs: [userId, from, to],
      );
      print('😊 Found ${dailyMoodRows.length} mood records from daily_moods');
      
      for (final r in dailyMoodRows) {
        final dateStr = r['date'] as String;
        final label = r['moodLabel'] as String?;
        final value = _moodLabelToValue(label);
        map[dateStr] = value;
        print('   😊 $dateStr: "$label" -> $value (from daily_moods)');
      }

      final journalRows = await db.query(
        'journals',
        where: 'userId = ? AND substr(date, 1, 10) >= ? AND substr(date, 1, 10) <= ? AND mood IS NOT NULL',
        whereArgs: [userId, from, to],
      );
      print('📝 Found ${journalRows.length} mood records from journals');
      
      for (final r in journalRows) {
        final dateStr = (r['date'] as String).substring(0, 10);
        
        if (!map.containsKey(dateStr)) {
          final label = r['mood'] as String?;
          final value = _moodLabelToValue(label);
          map[dateStr] = value;
          print('   📝 $dateStr: "$label" -> $value (from journals)');
        }
      }

      final homeStatusRows = await db.query(
        'home_status',
        where: 'userId = ? AND date >= ? AND date <= ? AND mood_label IS NOT NULL',
        whereArgs: [userId, from, to],
      );
      print('🏠 Found ${homeStatusRows.length} mood records from home_status');
      
      for (final r in homeStatusRows) {
        final dateStr = r['date'] as String;
        
        if (!map.containsKey(dateStr)) {
          final label = r['mood_label'] as String?;
          final value = _moodLabelToValue(label);
          map[dateStr] = value;
          print('   🏠 $dateStr: "$label" -> $value (from home_status)');
        }
      }
      
    } catch (e) {
      print('❌ Error loading combined mood data: $e');
    }
    
    print('✅ Total mood entries: ${map.length}');
    return map;
  }

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
      final count = Sqflite.firstIntValue(result) ?? 0;
      print('📖 Journal count: $count entries from $from to $to');
      return count;
    } catch (e) {
      print('❌ Error getting journal count for range: $e');
      return 0;
    }
  }

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
      final count = Sqflite.firstIntValue(result) ?? 0;
      print('📖 Journal count for $dayStr: $count entries');
      return count;
    } catch (e) {
      print('❌ Error getting journal count for day: $e');
      return 0;
    }
  }

  StatsData _generateEmptyData(StatsRange range) {
    final today = DateTime.now();

    switch (range) {
      case StatsRange.today:
        return StatsData(
          waterData: [0.0],
          moodData: [0.5],
          journalingCount: 0,
          screenTime: _getSimulatedScreenTime(),
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
          screenTime: _getSimulatedScreenTime(),
          labels: labels,
        );
      case StatsRange.monthly:
        return StatsData(
          waterData: List.filled(4, 0.0),
          moodData: List.filled(4, 0.5),
          journalingCount: 0,
          screenTime: _getSimulatedScreenTime(),
          labels: ['W1', 'W2', 'W3', 'W4'],
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 0.0),
          moodData: List.filled(12, 0.5),
          journalingCount: 0,
          screenTime: _getSimulatedScreenTime(),
          labels: List.generate(12, (i) => _monthName(i + 1)),
        );
    }
  }

  Map<String, double> _getSimulatedScreenTime() {
    final rnd = Random();
    return {
      'social': 1.2 + rnd.nextDouble() * 1.0,
      'entertainment': 2.1 + rnd.nextDouble() * 1.0,
      'productivity': 3.0 + rnd.nextDouble() * 1.0,
    };
  }

  Future<StatsData> loadForRange(StatsRange range) async {
    try {
      print('\n🔄 ==================== LOADING STATS ====================');
      print('📅 Range: $range');
      final db = await DBHelper.database;
      final userId = await _getCurrentUserId();
      final today = DateTime.now();
      final todayStr = _formatDate(today);
      print('📅 Today\'s date: $todayStr');
      print('👤 User ID: $userId');

      switch (range) {
        case StatsRange.today:
          return await _loadTodayData(db, userId, today);
        case StatsRange.weekly:
          return await _loadWeeklyData(db, userId, today);
        case StatsRange.monthly:
          return await _loadMonthlyData(db, userId, today);
        case StatsRange.yearly:
          return await _loadYearlyData(db, userId, today);
      }
    } catch (e) {
      print('❌ Error loading stats for range $range: $e');
      print('Stack trace: ${StackTrace.current}');
      return _generateEmptyData(range);
    }
  }

  Future<StatsData> _loadTodayData(
      Database db, int userId, DateTime today) async {
    final todayStr = _formatDate(today);
    print('\n📅 ==================== LOADING TODAY ====================');
    print('📅 Date: $todayStr');
    print('👤 User: $userId');
    
    // DEBUG: Check what's actually in the database
    await _debugHomeStatus(db, userId, todayStr);
    await _debugDailyMoods(db, userId, todayStr);
    
    double todayWater = 0.0;
    double todayMood = 0.5;

    // Get water data
    final waterMap = await _getWaterDataForRange(db, userId, todayStr, todayStr);
    todayWater = waterMap[todayStr] ?? 0.0;
    print('💧 Final water value: $todayWater');

    // Get combined mood data
    final moodMap = await _getCombinedMoodForRange(db, userId, todayStr, todayStr);
    todayMood = moodMap[todayStr] ?? 0.5;
    print('😊 Final mood value: $todayMood');

    // Journal count
    final journalCount = await _getJournalCountForDay(db, userId, todayStr);

    print('✅ ==================== TODAY SUMMARY ====================');
    print('💧 Water: $todayWater glasses');
    print('😊 Mood: $todayMood');
    print('📖 Journals: $journalCount');
    print('=========================================================\n');
    
    return StatsData(
      waterData: [todayWater],
      moodData: [todayMood],
      journalingCount: journalCount,
      screenTime: _getSimulatedScreenTime(),
      labels: ['Today'],
    );
  }

  Future<StatsData> _loadWeeklyData(
      Database db, int userId, DateTime today) async {
    final from = today.subtract(const Duration(days: 6));
    final fromStr = _formatDate(from);
    final toStr = _formatDate(today);
    
    print('\n📅 Loading WEEKLY data for user $userId from $fromStr to $toStr');

    final waterMap = await _getWaterDataForRange(db, userId, fromStr, toStr);
    final moodMap = await _getCombinedMoodForRange(db, userId, fromStr, toStr);
    final journalCount = await _getJournalCountForRange(db, userId, fromStr, toStr);

    final waterData = <double>[];
    final moodData = <double>[];
    final labels = <String>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = _formatDate(date);

      waterData.add(waterMap[dateStr] ?? 0.0);
      moodData.add(moodMap[dateStr] ?? 0.5);
      labels.add(_weekdayFr(date.weekday));
    }

    print('✅ WEEKLY Summary - ${waterData.length} days, $journalCount journals\n');

    return StatsData(
      waterData: waterData,
      moodData: moodData,
      journalingCount: journalCount,
      screenTime: _getSimulatedScreenTime(),
      labels: labels,
    );
  }

  Future<StatsData> _loadMonthlyData(
      Database db, int userId, DateTime today) async {
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = DateTime(today.year, today.month + 1, 0);
    final fromStr = _formatDate(startOfMonth);
    final toStr = _formatDate(endOfMonth);
    
    print('\n📅 Loading MONTHLY data for user $userId from $fromStr to $toStr');

    final waterMap = await _getWaterDataForRange(db, userId, fromStr, toStr);
    final moodMap = await _getCombinedMoodForRange(db, userId, fromStr, toStr);
    final journalCount = await _getJournalCountForRange(db, userId, fromStr, toStr);

    final waterData = List<double>.filled(4, 0.0);
    final moodData = List<double>.filled(4, 0.5);
    final waterCounts = List<int>.filled(4, 0);
    final moodCounts = List<int>.filled(4, 0);
    final labels = <String>['W1', 'W2', 'W3', 'W4'];

    for (final entry in waterMap.entries) {
      final date = DateTime.parse(entry.key);
      final weekIndex = ((date.day - 1) / 7).floor().clamp(0, 3);
      waterData[weekIndex] += entry.value;
      waterCounts[weekIndex]++;
    }

    for (int i = 0; i < 4; i++) {
      if (waterCounts[i] > 0) {
        waterData[i] /= waterCounts[i];
      }
    }

    for (final entry in moodMap.entries) {
      final date = DateTime.parse(entry.key);
      final weekIndex = ((date.day - 1) / 7).floor().clamp(0, 3);
      moodData[weekIndex] += entry.value;
      moodCounts[weekIndex]++;
    }

    for (int i = 0; i < 4; i++) {
      if (moodCounts[i] > 0) {
        moodData[i] /= moodCounts[i];
      }
    }

    print('✅ MONTHLY Summary - 4 weeks, $journalCount journals\n');

    return StatsData(
      waterData: waterData,
      moodData: moodData,
      journalingCount: journalCount,
      screenTime: _getSimulatedScreenTime(),
      labels: labels,
    );
  }

  Future<StatsData> _loadYearlyData(
      Database db, int userId, DateTime today) async {
    final startOfYear = DateTime(today.year, 1, 1);
    final endOfYear = DateTime(today.year, 12, 31);
    final fromStr = _formatDate(startOfYear);
    final toStr = _formatDate(endOfYear);
    
    print('\n📅 Loading YEARLY data for user $userId from $fromStr to $toStr');

    final waterMap = await _getWaterDataForRange(db, userId, fromStr, toStr);
    final moodMap = await _getCombinedMoodForRange(db, userId, fromStr, toStr);
    final journalCount = await _getJournalCountForRange(db, userId, fromStr, toStr);

    final waterData = List<double>.filled(12, 0.0);
    final moodData = List<double>.filled(12, 0.5);
    final waterCounts = List<int>.filled(12, 0);
    final moodCounts = List<int>.filled(12, 0);
    final labels = List<String>.generate(12, (i) => _monthName(i + 1));

    for (final entry in waterMap.entries) {
      try {
        final date = DateTime.parse(entry.key);
        final monthIndex = date.month - 1;
        if (monthIndex >= 0 && monthIndex < 12) {
          waterData[monthIndex] += entry.value;
          waterCounts[monthIndex]++;
        }
      } catch (e) {
        print('⚠️ Error parsing date ${entry.key}: $e');
      }
    }

    for (int i = 0; i < 12; i++) {
      if (waterCounts[i] > 0) {
        waterData[i] /= waterCounts[i];
      }
    }

    for (final entry in moodMap.entries) {
      try {
        final date = DateTime.parse(entry.key);
        final monthIndex = date.month - 1;
        if (monthIndex >= 0 && monthIndex < 12) {
          moodData[monthIndex] += entry.value;
          moodCounts[monthIndex]++;
        }
      } catch (e) {
        print('⚠️ Error parsing mood date ${entry.key}: $e');
      }
    }

    for (int i = 0; i < 12; i++) {
      if (moodCounts[i] > 0) {
        moodData[i] /= moodCounts[i];
      }
    }

    print('✅ YEARLY Summary - 12 months, $journalCount journals\n');

    return StatsData(
      waterData: waterData,
      moodData: moodData,
      journalingCount: journalCount,
      screenTime: _getSimulatedScreenTime(),
      labels: labels,
    );
  }
}


