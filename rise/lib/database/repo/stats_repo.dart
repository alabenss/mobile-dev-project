// lib/data/repo/stats_repo.dart
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../views/widgets/stats/range_selector_widget.dart';

class StatsData {
  final List<double> waterData;
  final List<double> moodData; // 0..1
  final int journalingCount;
  final List<int> journalCounts;
  final Map<String, double> screenTime;
  final List<String> labels;

  StatsData({
    required this.waterData,
    required this.moodData,
    required this.journalingCount,
    required this.journalCounts,
    required this.screenTime,
    required this.labels,
  });
}

class StatsRepo {
  final ApiService _api = ApiService.instance;

  /// Get current logged-in user ID
  Future<int?> _getCurrentUserId() async {
    try {
      return await _api.getCurrentUserId();
    } catch (e) {
      print('StatsRepo: Error getting userId: $e');
      return null;
    }
  }

  /// Format date as yyyy-MM-dd
  String _formatDate(DateTime d) => _api.formatDate(d);

  /// Convert mood label to numeric value
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

  /// Get mood value for a specific date (combines daily_moods and journals)
  Future<double> _getMoodForDate(int userId, String dateStr) async {
    try {
      final moodValues = <double>[];
      
      // Get mood from daily_moods
      final moodResponse = await _api.get(
        ApiConfig.MOODS_TODAY,
        params: {
          'userId': userId.toString(),
          'date': dateStr,
        },
      );

      if (moodResponse['success'] == true && moodResponse['mood'] != null) {
        final label = moodResponse['mood']['mood_label'] as String?;
        moodValues.add(_moodLabelToValue(label));
      }

      // Get moods from journals for this date
      final journalsResponse = await _api.get(
        ApiConfig.JOURNALS_GET,
        params: {'userId': userId.toString()},
      );

      if (journalsResponse['success'] == true && journalsResponse['journals'] != null) {
        final journals = journalsResponse['journals'] as List;
        for (var journal in journals) {
          final journalDate = journal['date'] as String?;
          if (journalDate != null && journalDate.startsWith(dateStr)) {
            final mood = journal['mood'] as String?;
            if (mood != null && mood.isNotEmpty) {
              moodValues.add(_moodLabelToValue(mood));
            }
          }
        }
      }

      // Return average or default
      if (moodValues.isEmpty) return 0.5;
      return moodValues.reduce((a, b) => a + b) / moodValues.length;
    } catch (e) {
      print('StatsRepo: Error getting mood for date $dateStr: $e');
      return 0.5;
    }
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

  /// Generate empty placeholder data
  StatsData _generateEmptyData(StatsRange range) {
    final today = DateTime.now();

    switch (range) {
      case StatsRange.today:
        return StatsData(
          waterData: [0.0],
          moodData: [0.5],
          journalingCount: 0,
          journalCounts: [0],
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
          journalCounts: List.filled(7, 0),
          screenTime: {'detox': 0.0},
          labels: labels,
        );
      case StatsRange.monthly:
        return StatsData(
          waterData: List.filled(4, 0.0),
          moodData: List.filled(4, 0.5),
          journalingCount: 0,
          journalCounts: List.filled(4, 0),
          screenTime: {'detox': 0.0},
          labels: ['W1', 'W2', 'W3', 'W4'],
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 0.0),
          moodData: List.filled(12, 0.5),
          journalingCount: 0,
          journalCounts: List.filled(12, 0),
          screenTime: {'detox': 0.0},
          labels: List.generate(12, (i) => _monthFr(i + 1)),
        );
    }
  }

  /// Load data for today
  Future<StatsData> _loadTodayData(int userId) async {
    try {
      final today = DateTime.now();
      final todayStr = _formatDate(today);
      
      print('StatsRepo: Loading today data for date: $todayStr');

      // Get water data
      double water = 0.0;
      try {
        final homeResponse = await _api.get(
          ApiConfig.HOME_STATUS_GET,
          params: {
            'userId': userId.toString(),
            'date': todayStr,
          },
        );

        if (homeResponse['success'] == true && homeResponse['status'] != null) {
          water = (homeResponse['status']['water_count'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        print('StatsRepo: Error getting water data: $e');
      }

      // Get mood data
      final mood = await _getMoodForDate(userId, todayStr);

      // Get journal count
      int journalCount = 0;
      try {
        final journalsResponse = await _api.get(
          ApiConfig.JOURNALS_GET,
          params: {'userId': userId.toString()},
        );

        if (journalsResponse['success'] == true && journalsResponse['journals'] != null) {
          final journals = journalsResponse['journals'] as List;
          journalCount = journals.where((j) {
            final date = j['date'] as String?;
            return date != null && date.startsWith(todayStr);
          }).length;
        }
      } catch (e) {
        print('StatsRepo: Error getting journal count: $e');
      }

      // Get detox progress
      double detox = 0.0;
      try {
        final homeResponse = await _api.get(
          ApiConfig.HOME_STATUS_GET,
          params: {
            'userId': userId.toString(),
            'date': todayStr,
          },
        );

        if (homeResponse['success'] == true && homeResponse['status'] != null) {
          detox = (homeResponse['status']['detox_progress'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        print('StatsRepo: Error getting detox data: $e');
      }

      return StatsData(
        waterData: [water],
        moodData: [mood],
        journalingCount: journalCount,
        journalCounts: [journalCount],
        screenTime: {'detox': detox},
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
      final today = DateTime.now();
      final waterData = <double>[];
      final moodData = <double>[];
      final journalCounts = <int>[];
      final labels = <String>[];
      int totalJournals = 0;
      double totalDetox = 0.0;

      print('StatsRepo: Loading weekly data');

      // Get all journals once
      List<dynamic> allJournals = [];
      try {
        final journalsResponse = await _api.get(
          ApiConfig.JOURNALS_GET,
          params: {'userId': userId.toString()},
        );
        if (journalsResponse['success'] == true && journalsResponse['journals'] != null) {
          allJournals = journalsResponse['journals'] as List;
        }
      } catch (e) {
        print('StatsRepo: Error fetching journals: $e');
      }

      // Get home status range
      final startDate = _formatDate(today.subtract(const Duration(days: 6)));
      final endDate = _formatDate(today);
      List<dynamic> allHomeStatus = [];
      try {
        final homeResponse = await _api.get(
          ApiConfig.HOME_GET_RANGE,
          params: {
            'userId': userId.toString(),
            'startDate': startDate,
            'endDate': endDate,
          },
        );
        if (homeResponse['success'] == true && homeResponse['statuses'] != null) {
          allHomeStatus = homeResponse['statuses'] as List;
        }
      } catch (e) {
        print('StatsRepo: Error fetching home status range: $e');
      }

      // Process each day
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = _formatDate(date);
        labels.add(_weekdayFr(date.weekday));

        // Water data
        double water = 0.0;
        final dayStatus = allHomeStatus.firstWhere(
          (s) => s['date'] == dateStr,
          orElse: () => null,
        );
        if (dayStatus != null) {
          water = (dayStatus['water_count'] as num?)?.toDouble() ?? 0.0;
          totalDetox += (dayStatus['detox_progress'] as num?)?.toDouble() ?? 0.0;
        }
        waterData.add(water);

        // Mood data
        final mood = await _getMoodForDate(userId, dateStr);
        moodData.add(mood);

        // Journal count
        final dayJournals = allJournals.where((j) {
          final jDate = j['date'] as String?;
          return jDate != null && jDate.startsWith(dateStr);
        }).length;
        journalCounts.add(dayJournals);
        totalJournals += dayJournals;
      }

      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournals,
        journalCounts: journalCounts,
        screenTime: {'detox': totalDetox},
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
      final waterData = <double>[];
      final moodData = <double>[];
      final journalCounts = <int>[];
      final labels = <String>[];
      int totalJournals = 0;
      double totalDetox = 0.0;

      print('StatsRepo: Loading monthly data');

      // Get all journals once
      List<dynamic> allJournals = [];
      try {
        final journalsResponse = await _api.get(
          ApiConfig.JOURNALS_GET,
          params: {'userId': userId.toString()},
        );
        if (journalsResponse['success'] == true && journalsResponse['journals'] != null) {
          allJournals = journalsResponse['journals'] as List;
        }
      } catch (e) {
        print('StatsRepo: Error fetching journals: $e');
      }

      // Get home status range
      final startDate = _formatDate(today.subtract(const Duration(days: 27)));
      final endDate = _formatDate(today);
      List<dynamic> allHomeStatus = [];
      try {
        final homeResponse = await _api.get(
          ApiConfig.HOME_GET_RANGE,
          params: {
            'userId': userId.toString(),
            'startDate': startDate,
            'endDate': endDate,
          },
        );
        if (homeResponse['success'] == true && homeResponse['statuses'] != null) {
          allHomeStatus = homeResponse['statuses'] as List;
        }
      } catch (e) {
        print('StatsRepo: Error fetching home status range: $e');
      }

      // Process each week (4 weeks)
      for (int week = 3; week >= 0; week--) {
        double weekWater = 0.0;
        double weekMood = 0.0;
        int weekJournals = 0;
        int daysWithWater = 0;

        for (int day = 0; day < 7; day++) {
          final daysAgo = (week * 7) + day;
          final date = today.subtract(Duration(days: daysAgo));
          final dateStr = _formatDate(date);

          // Water
          final dayStatus = allHomeStatus.firstWhere(
            (s) => s['date'] == dateStr,
            orElse: () => null,
          );
          if (dayStatus != null) {
            weekWater += (dayStatus['water_count'] as num?)?.toDouble() ?? 0.0;
            totalDetox += (dayStatus['detox_progress'] as num?)?.toDouble() ?? 0.0;
            daysWithWater++;
          }

          // Mood
          final mood = await _getMoodForDate(userId, dateStr);
          weekMood += mood;

          // Journals
          final dayJournals = allJournals.where((j) {
            final jDate = j['date'] as String?;
            return jDate != null && jDate.startsWith(dateStr);
          }).length;
          weekJournals += dayJournals;
        }

        waterData.insert(0, daysWithWater > 0 ? weekWater / daysWithWater : 0.0);
        moodData.insert(0, weekMood / 7);
        journalCounts.insert(0, weekJournals);
        totalJournals += weekJournals;
        labels.insert(0, 'W${4 - week}');
      }

      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournals,
        journalCounts: journalCounts,
        screenTime: {'detox': totalDetox},
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
      final waterData = <double>[];
      final moodData = <double>[];
      final journalCounts = <int>[];
      final labels = <String>[];
      int totalJournals = 0;
      double totalDetox = 0.0;

      print('StatsRepo: Loading yearly data');

      // Get all data once
      List<dynamic> allJournals = [];
      List<dynamic> allHomeStatus = [];

      try {
        final journalsResponse = await _api.get(
          ApiConfig.JOURNALS_GET,
          params: {'userId': userId.toString()},
        );
        if (journalsResponse['success'] == true && journalsResponse['journals'] != null) {
          allJournals = journalsResponse['journals'] as List;
        }
      } catch (e) {
        print('StatsRepo: Error fetching journals: $e');
      }

      // For yearly, we need to make multiple range calls or get all data
      // This is a simplified version - you might want to optimize
      for (int monthOffset = 11; monthOffset >= 0; monthOffset--) {
        int targetYear = today.year;
        int targetMonth = today.month - monthOffset;

        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear -= 1;
        }

        final monthStart = DateTime(targetYear, targetMonth, 1);
        final monthEnd = DateTime(targetYear, targetMonth + 1, 0);

        double monthWater = 0.0;
        double monthMood = 0.0;
        int monthJournals = 0;
        int waterDays = 0;
        int moodDays = 0;

        // Process each day in month
        for (int day = 1; day <= monthEnd.day; day++) {
          final date = DateTime(targetYear, targetMonth, day);
          final dateStr = _formatDate(date);

          // This would be more efficient with a single month query
          // For now, we filter from all data
          final dayJournals = allJournals.where((j) {
            final jDate = j['date'] as String?;
            return jDate != null && jDate.startsWith(dateStr);
          }).length;
          monthJournals += dayJournals;

          final mood = await _getMoodForDate(userId, dateStr);
          monthMood += mood;
          moodDays++;
        }

        waterData.add(waterDays > 0 ? monthWater / waterDays : 0.0);
        moodData.add(moodDays > 0 ? monthMood / moodDays : 0.5);
        journalCounts.add(monthJournals);
        totalJournals += monthJournals;
        labels.add(_monthFr(targetMonth));
      }

      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournals,
        journalCounts: journalCounts,
        screenTime: {'detox': totalDetox},
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
      final userId = await _getCurrentUserId();
      
      if (userId == null) {
        print('StatsRepo: No logged-in user found!');
        return _generateEmptyData(range);
      }
      
      print('StatsRepo: Loading stats for range: $range, userId: $userId');
      
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
    } catch (e) {
      print('StatsRepo: Error loading stats for range $range: $e');
      return _generateEmptyData(range);
    }
  }
}