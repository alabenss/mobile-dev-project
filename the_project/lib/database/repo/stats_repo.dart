// lib/database/repo/stats_repo.dart
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
  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _moodLabelToValue(String? label) {
    if (label == null) return 0.5;
    final l = label.toLowerCase();
    if (l.contains('happy') || l.contains('joy') || l.contains('bien')) {
      return 0.85;
    }
    if (l.contains('ok') || l.contains('neut') || l.contains('moyen')) {
      return 0.6;
    }
    if (l.contains('sad') || l.contains('bad') || l.contains('triste')) {
      return 0.35;
    }
    return 0.5;
  }

  String _weekdayFr(int weekday) {
    // Monday=1 ... Sunday=7
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

  Future<void> _seedIfEmpty(Database db) async {
    final countRes = await db.rawQuery('SELECT COUNT(*) as c FROM home_status');
    final int count =
        Sqflite.firstIntValue(countRes) ?? 0; // Sqflite helper, returns int?

    if (count > 0) return; // already have data

    final userId = await DBHelper.ensureDefaultUser();
    final today = DateTime.now();

    // Seed last 7 days
    const moods = ['triste', 'moyen', 'heureux'];
    final rnd = Random(1234);

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateStr = _fmt(date);

      final waterCount = 6 + rnd.nextInt(4); // 6..9
      final waterGoal = 8;
      final detox = 0.3 + rnd.nextDouble() * 0.5;
      final moodLabel = moods[i % moods.length];

      await db.insert('home_status', {
        'date': dateStr,
        'water_count': waterCount,
        'water_goal': waterGoal,
        'detox_progress': detox,
        'mood_label': moodLabel,
        'mood_image': '',
        'mood_time': '',
      });

      // Add a journal entry for about half of the days
      if (i % 2 == 0) {
        await db.insert('journals', {
          'userId': userId,
          'date': dateStr,
          'mood': moodLabel,
          'text': 'Entrée de journal démo $i',
          'imagePath': null,
          'voicePath': null,
        });
      }
    }
  }

  Future<StatsData> loadWeeklyFromDb() async {
    final db = await DBHelper.database;
    await _seedIfEmpty(db);

    final today = DateTime.now();
    final from = today.subtract(const Duration(days: 6));
    final fromStr = _fmt(from);
    final toStr = _fmt(today);

    final rows = await db.query(
      'home_status',
      where: 'date >= ? AND date <= ?',
      whereArgs: [fromStr, toStr],
      orderBy: 'date ASC',
    );

    final water = <double>[];
    final mood = <double>[];
    final labels = <String>[];

    for (final r in rows) {
      final dateStr = (r['date'] as String);
      final date = DateTime.tryParse(dateStr) ??
          DateTime.parse('$dateStr 00:00:00'); // fallback

      water.add((r['water_count'] as num).toDouble());
      mood.add(_moodLabelToValue(r['mood_label'] as String?));
      labels.add(_weekdayFr(date.weekday));
    }

    // Journaling count = number of journal entries in this period
    final journalCountRes = await db.rawQuery(
      'SELECT COUNT(*) as c FROM journals WHERE date >= ? AND date <= ?',
      [fromStr, toStr],
    );
    final journalingCount = Sqflite.firstIntValue(journalCountRes) ?? 0;

    // Basic dummy screen time (still satisfies \"dummy data\" requirement)
    final screenTime = <String, double>{
      'social': 1.2,
      'entertainment': 2.1,
      'productivity': 3.0,
    };

    return StatsData(
      waterData: water,
      moodData: mood,
      journalingCount: journalingCount,
      screenTime: screenTime,
      labels: labels,
    );
  }

  // For now, other ranges use transformed weekly data
  Future<StatsData> loadForRange(StatsRange range) async {
    final weekly = await loadWeeklyFromDb();

    switch (range) {
      case StatsRange.today:
        final lastWater =
            weekly.waterData.isNotEmpty ? weekly.waterData.last : 0.0;
        final lastMood =
            weekly.moodData.isNotEmpty ? weekly.moodData.last : 0.5;
        final todayWater = [lastWater];
        final todayMood = [lastMood];
        final labels = ['Aujourd\'hui'];
        final journalingToday =
            weekly.journalingCount > 0 ? 1 : 0; // simple approximation
        return StatsData(
          waterData: todayWater,
          moodData: todayMood,
          journalingCount: journalingToday,
          screenTime: weekly.screenTime,
          labels: labels,
        );

      case StatsRange.weekly:
        return weekly;

      case StatsRange.monthly:
        // Repeat weekly pattern ~4 times to simulate a month
        final repeat = 4;
        final water = <double>[];
        final mood = <double>[];
        final labels = <String>[];

        for (int r = 0; r < repeat; r++) {
          for (int i = 0; i < weekly.waterData.length; i++) {
            water.add(weekly.waterData[i]);
            mood.add(weekly.moodData[i]);
            labels.add('${r * weekly.waterData.length + i + 1}');
          }
        }
        return StatsData(
          waterData: water,
          moodData: mood,
          journalingCount: weekly.journalingCount * repeat,
          screenTime: weekly.screenTime,
          labels: labels,
        );

      case StatsRange.yearly:
        // 12 months: aggregate weekly average to fake monthly stats
        final avgWater = weekly.waterData.isNotEmpty
            ? weekly.waterData.reduce((a, b) => a + b) / weekly.waterData.length
            : 0.0;
        final avgMood = weekly.moodData.isNotEmpty
            ? weekly.moodData.reduce((a, b) => a + b) / weekly.moodData.length
            : 0.5;

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
          'Déc',
        ];

        return StatsData(
          waterData: water,
          moodData: mood,
          journalingCount: weekly.journalingCount * 12,
          screenTime: weekly.screenTime,
          labels: labels,
        );
    }
  }
}
