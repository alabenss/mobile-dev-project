// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get statistics => 'Statistics';

  @override
  String get today => 'Today';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get waterStats => 'Water statistics';

  @override
  String get moodTracking => 'Mood tracking';

  @override
  String get journaling => 'Journaling';

  @override
  String get screenTime => 'Screen time';

  @override
  String glassesToday(int count) {
    return '$count glasses today';
  }

  @override
  String avgPerDay(int count) {
    return 'Avg. $count glasses / day';
  }

  @override
  String monthlyAvg(Object count) {
    return 'Monthly average $count glasses';
  }

  @override
  String yearlyAvg(Object count) {
    return 'Yearly average $count glasses';
  }

  @override
  String get youWroteToday => 'You wrote today';

  @override
  String get noEntryToday => 'No entry today';

  @override
  String daysLogged(int count) {
    return '$count days logged';
  }

  @override
  String entriesThisMonth(int count) {
    return '$count entries this month';
  }

  @override
  String totalEntries(int count) {
    return '$count entries total';
  }

  @override
  String get moodFeelingGreat => 'Feeling great';

  @override
  String get moodNice => 'Nice';

  @override
  String get moodOk => 'Okay';

  @override
  String get moodLow => 'Low';

  @override
  String get calm => 'Calm';

  @override
  String get balanced => 'Balanced';

  @override
  String get low => 'Low';

  @override
  String get social => 'Social';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get productivity => 'Productivity';

  @override
  String hoursPerDay(Object count) {
    return '$count h/day';
  }
}
