// lib/data/repo/stats_repo.dart
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../views/widgets/stats/range_selector_widget.dart';

class StatsData {
  final List<double> waterData;
  final List<double> moodData;
  final int journalingCount;
  final List<int> journalCounts;
  final Map<String, double> screenTime;
  final List<String> labels;
  
  // NEW: Habit statistics
  final int totalHabits;
  final int completedHabits;
  final double completionRate;
  final int currentStreak;
  final int bestStreak;
  final List<double> habitCompletionData; // completion rate per period
  final int tasksConvertedToHabits;

  StatsData({
    required this.waterData,
    required this.moodData,
    required this.journalingCount,
    required this.journalCounts,
    required this.screenTime,
    required this.labels,
    this.totalHabits = 0,
    this.completedHabits = 0,
    this.completionRate = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.habitCompletionData = const [],
    this.tasksConvertedToHabits = 0,
  });
}

class StatsRepo {
  final ApiService _api = ApiService.instance;

  Future<int?> _getCurrentUserId() async {
    try {
      return await _api.getCurrentUserId();
    } catch (e) {
      print('StatsRepo: Error getting userId: $e');
      return null;
    }
  }

  String _formatDate(DateTime d) => _api.formatDate(d);

  double _moodLabelToValue(String? label) {
    if (label == null || label.isEmpty) return 0.5;
    final l = label.toLowerCase();

    if (l.contains('happy') || l.contains('joy') || l.contains('great') || 
        l.contains('excited') || l.contains('awesome') || l.contains('amazing')) {
      return 0.9;
    }
    
    if (l.contains('good') || l.contains('nice') || l.contains('calm') || 
        l.contains('peaceful') || l.contains('content') || l.contains('bien')) {
      return 0.7;
    }
    
    if (l.contains('ok') || l.contains('neutral') || l.contains('average') || 
        l.contains('meh') || l.contains('fine') || l.contains('moyen') || l.contains('confus')) {
      return 0.5;
    }
    
    if (l.contains('sad') || l.contains('low') || l.contains('tired') || 
        l.contains('anxious') || l.contains('stressed') || l.contains('triste')) {
      return 0.35;
    }
    
    if (l.contains('bad') || l.contains('terrible') || l.contains('angry') || 
        l.contains('depressed') || l.contains('awful') || l.contains('mauvais')) {
      return 0.1;
    }

    return 0.5;
  }

  Future<double> _getMoodForDate(int userId, String dateStr) async {
    try {
      final moodValues = <double>[];
      
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

      if (moodValues.isEmpty) return 0.5;
      return moodValues.reduce((a, b) => a + b) / moodValues.length;
    } catch (e) {
      print('StatsRepo: Error getting mood for date $dateStr: $e');
      return 0.5;
    }
  }

  // NEW: Get habit statistics for a date range
  Future<Map<String, dynamic>> _getHabitStats(int userId, DateTime start, DateTime end) async {
    try {
      print('StatsRepo: Getting habit stats from $start to $end');
      
      final response = await _api.get(
        ApiConfig.HABITS_GET,
        params: {'userId': userId.toString()},
      );

      if (response['success'] != true || response['habits'] == null) {
        return {
          'totalHabits': 0,
          'completedHabits': 0,
          'completionRate': 0.0,
          'currentStreak': 0,
          'bestStreak': 0,
          'tasksConverted': 0,
        };
      }

      final habits = response['habits'] as List;
      int totalHabits = habits.length;
      int completedHabits = 0;
      int maxStreak = 0;
      int avgStreak = 0;
      int tasksConverted = 0;

      for (var habit in habits) {
        final status = habit['status'] as String?;
        final streakCount = (habit['streak_count'] as int?) ?? 0;
        final bestStreak = (habit['best_streak'] as int?) ?? 0;
        final isTask = habit['is_task'] == true || habit['is_task'] == 1;
        final taskCompletionCount = (habit['task_completion_count'] as int?) ?? 0;

        if (status == 'completed') {
          completedHabits++;
        }

        if (streakCount > avgStreak) {
          avgStreak = streakCount;
        }

        if (bestStreak > maxStreak) {
          maxStreak = bestStreak;
        }

        // Count habits that were tasks but became habits (task_completion >= 10)
        if (!isTask && taskCompletionCount >= 10) {
          tasksConverted++;
        }
      }

      final completionRate = totalHabits > 0 
          ? (completedHabits / totalHabits * 100).clamp(0.0, 100.0) 
          : 0.0;

      return {
        'totalHabits': totalHabits,
        'completedHabits': completedHabits,
        'completionRate': completionRate,
        'currentStreak': avgStreak,
        'bestStreak': maxStreak,
        'tasksConverted': tasksConverted,
      };
    } catch (e) {
      print('StatsRepo: Error getting habit stats: $e');
      return {
        'totalHabits': 0,
        'completedHabits': 0,
        'completionRate': 0.0,
        'currentStreak': 0,
        'bestStreak': 0,
        'tasksConverted': 0,
      };
    }
  }

  // NEW: Get habit completion data per period
  Future<List<double>> _getHabitCompletionData(
    int userId, 
    List<DateTime> dates,
  ) async {
    try {
      final response = await _api.get(
        ApiConfig.HABITS_GET,
        params: {'userId': userId.toString()},
      );

      if (response['success'] != true || response['habits'] == null) {
        return List.filled(dates.length, 0.0);
      }

      final habits = response['habits'] as List;
      final completionData = <double>[];

      for (var date in dates) {
        int totalForDate = 0;
        int completedForDate = 0;

        for (var habit in habits) {
          final lastCompletedStr = habit['last_completed_date'] as String?;
          if (lastCompletedStr != null) {
            try {
              final lastCompleted = DateTime.parse(lastCompletedStr);
              if (lastCompleted.year == date.year &&
                  lastCompleted.month == date.month &&
                  lastCompleted.day == date.day) {
                totalForDate++;
                final status = habit['status'] as String?;
                if (status == 'completed') {
                  completedForDate++;
                }
              }
            } catch (e) {
              // Skip invalid dates
            }
          }
        }

        final rate = totalForDate > 0 
            ? (completedForDate / totalForDate * 100).clamp(0.0, 100.0)
            : 0.0;
        completionData.add(rate);
      }

      return completionData;
    } catch (e) {
      print('StatsRepo: Error getting habit completion data: $e');
      return List.filled(dates.length, 0.0);
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
          habitCompletionData: [0.0],
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
          habitCompletionData: List.filled(7, 0.0),
        );
      case StatsRange.monthly:
        return StatsData(
          waterData: List.filled(4, 0.0),
          moodData: List.filled(4, 0.5),
          journalingCount: 0,
          journalCounts: List.filled(4, 0),
          screenTime: {'detox': 0.0},
          labels: ['W1', 'W2', 'W3', 'W4'],
          habitCompletionData: List.filled(4, 0.0),
        );
      case StatsRange.yearly:
        return StatsData(
          waterData: List.filled(12, 0.0),
          moodData: List.filled(12, 0.5),
          journalingCount: 0,
          journalCounts: List.filled(12, 0),
          screenTime: {'detox': 0.0},
          labels: List.generate(12, (i) => _monthFr(i + 1)),
          habitCompletionData: List.filled(12, 0.0),
        );
    }
  }

  Future<StatsData> _loadTodayData(int userId) async {
    try {
      final today = DateTime.now();
      final todayStr = _formatDate(today);
      
      print('StatsRepo: Loading today data for date: $todayStr');

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

      final mood = await _getMoodForDate(userId, todayStr);

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

      // NEW: Get habit stats for today
      final habitStats = await _getHabitStats(userId, today, today);
      final habitCompletionData = await _getHabitCompletionData(userId, [today]);

      return StatsData(
        waterData: [water],
        moodData: [mood],
        journalingCount: journalCount,
        journalCounts: [journalCount],
        screenTime: {'detox': detox},
        labels: ['Today'],
        totalHabits: habitStats['totalHabits'],
        completedHabits: habitStats['completedHabits'],
        completionRate: habitStats['completionRate'],
        currentStreak: habitStats['currentStreak'],
        bestStreak: habitStats['bestStreak'],
        habitCompletionData: habitCompletionData,
        tasksConvertedToHabits: habitStats['tasksConverted'],
      );
    } catch (e) {
      print('StatsRepo: Error loading today data: $e');
      return _generateEmptyData(StatsRange.today);
    }
  }

  Future<StatsData> _loadWeeklyData(int userId) async {
    try {
      final today = DateTime.now();
      final waterData = <double>[];
      final moodData = <double>[];
      final journalCounts = <int>[];
      final labels = <String>[];
      final dates = <DateTime>[];
      int totalJournals = 0;
      double totalDetox = 0.0;

      print('StatsRepo: Loading weekly data');

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

      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = _formatDate(date);
        labels.add(_weekdayFr(date.weekday));
        dates.add(date);

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

        final mood = await _getMoodForDate(userId, dateStr);
        moodData.add(mood);

        final dayJournals = allJournals.where((j) {
          final jDate = j['date'] as String?;
          return jDate != null && jDate.startsWith(dateStr);
        }).length;
        journalCounts.add(dayJournals);
        totalJournals += dayJournals;
      }

      // NEW: Get habit stats for the week
      final weekStart = today.subtract(const Duration(days: 6));
      final habitStats = await _getHabitStats(userId, weekStart, today);
      final habitCompletionData = await _getHabitCompletionData(userId, dates);

      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournals,
        journalCounts: journalCounts,
        screenTime: {'detox': totalDetox},
        labels: labels,
        totalHabits: habitStats['totalHabits'],
        completedHabits: habitStats['completedHabits'],
        completionRate: habitStats['completionRate'],
        currentStreak: habitStats['currentStreak'],
        bestStreak: habitStats['bestStreak'],
        habitCompletionData: habitCompletionData,
        tasksConvertedToHabits: habitStats['tasksConverted'],
      );
    } catch (e) {
      print('StatsRepo: Error loading weekly data: $e');
      return _generateEmptyData(StatsRange.weekly);
    }
  }

  Future<StatsData> _loadMonthlyData(int userId) async {
    try {
      final today = DateTime.now();
      final waterData = <double>[];
      final moodData = <double>[];
      final journalCounts = <int>[];
      final labels = <String>[];
      final weekDates = <DateTime>[];
      int totalJournals = 0;
      double totalDetox = 0.0;

      print('StatsRepo: Loading monthly data');

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

      for (int week = 3; week >= 0; week--) {
        double weekWater = 0.0;
        double weekMood = 0.0;
        int weekJournals = 0;
        int daysWithWater = 0;

        final weekStartDate = today.subtract(Duration(days: week * 7));
        weekDates.add(weekStartDate);

        for (int day = 0; day < 7; day++) {
          final daysAgo = (week * 7) + day;
          final date = today.subtract(Duration(days: daysAgo));
          final dateStr = _formatDate(date);

          final dayStatus = allHomeStatus.firstWhere(
            (s) => s['date'] == dateStr,
            orElse: () => null,
          );
          if (dayStatus != null) {
            weekWater += (dayStatus['water_count'] as num?)?.toDouble() ?? 0.0;
            totalDetox += (dayStatus['detox_progress'] as num?)?.toDouble() ?? 0.0;
            daysWithWater++;
          }

          final mood = await _getMoodForDate(userId, dateStr);
          weekMood += mood;

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

      // NEW: Get habit stats for the month
      final monthStart = today.subtract(const Duration(days: 27));
      final habitStats = await _getHabitStats(userId, monthStart, today);
      final habitCompletionData = await _getHabitCompletionData(userId, weekDates.reversed.toList());

      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournals,
        journalCounts: journalCounts,
        screenTime: {'detox': totalDetox},
        labels: labels,
        totalHabits: habitStats['totalHabits'],
        completedHabits: habitStats['completedHabits'],
        completionRate: habitStats['completionRate'],
        currentStreak: habitStats['currentStreak'],
        bestStreak: habitStats['bestStreak'],
        habitCompletionData: habitCompletionData,
        tasksConvertedToHabits: habitStats['tasksConverted'],
      );
    } catch (e) {
      print('StatsRepo: Error loading monthly data: $e');
      return _generateEmptyData(StatsRange.monthly);
    }
  }

  Future<StatsData> _loadYearlyData(int userId) async {
    try {
      final today = DateTime.now();
      final waterData = <double>[];
      final moodData = <double>[];
      final journalCounts = <int>[];
      final labels = <String>[];
      final monthDates = <DateTime>[];
      int totalJournals = 0;
      double totalDetox = 0.0;

      print('StatsRepo: Loading yearly data');

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

      for (int monthOffset = 11; monthOffset >= 0; monthOffset--) {
        int targetYear = today.year;
        int targetMonth = today.month - monthOffset;

        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear -= 1;
        }

        final monthStart = DateTime(targetYear, targetMonth, 1);
        final monthEnd = DateTime(targetYear, targetMonth + 1, 0);
        monthDates.add(monthStart);

        double monthWater = 0.0;
        double monthMood = 0.0;
        int monthJournals = 0;
        int waterDays = 0;
        int moodDays = 0;

        for (int day = 1; day <= monthEnd.day; day++) {
          final date = DateTime(targetYear, targetMonth, day);
          final dateStr = _formatDate(date);

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

      // NEW: Get habit stats for the year
      final yearStart = DateTime(today.year - 1, today.month, today.day);
      final habitStats = await _getHabitStats(userId, yearStart, today);
      final habitCompletionData = await _getHabitCompletionData(userId, monthDates);

      return StatsData(
        waterData: waterData,
        moodData: moodData,
        journalingCount: totalJournals,
        journalCounts: journalCounts,
        screenTime: {'detox': totalDetox},
        labels: labels,
        totalHabits: habitStats['totalHabits'],
        completedHabits: habitStats['completedHabits'],
        completionRate: habitStats['completionRate'],
        currentStreak: habitStats['currentStreak'],
        bestStreak: habitStats['bestStreak'],
        habitCompletionData: habitCompletionData,
        tasksConvertedToHabits: habitStats['tasksConverted'],
      );
    } catch (e) {
      print('StatsRepo: Error loading yearly data: $e');
      return _generateEmptyData(StatsRange.yearly);
    }
  }

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