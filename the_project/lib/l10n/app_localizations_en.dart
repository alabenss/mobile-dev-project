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
  String get noData => 'No data';

  @override
  String get noMoodData => 'No mood data available';

  @override
  String get noWaterData => 'No water data available';

  @override
  String get noScreenTimeData => 'No screen time data available';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodBalanced => 'Balanced';

  @override
  String get moodLow => 'Low';

  @override
  String get moodFeelingGreat => 'Feeling great';

  @override
  String get moodNice => 'Nice mood';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodFeelingLow => 'Feeling low';

  @override
  String get statsNoData => 'No data';

  @override
  String get statsNoMoodData => 'No mood data available';

  @override
  String get statsRefreshingData => 'Refreshing data...';

  @override
  String get statsLoading => 'Loading statistics...';

  @override
  String get statsErrorTitle => 'Oops! Something went wrong';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get statsEmptyTitle => 'No Data Yet';

  @override
  String get statsEmptySubtitle => 'Start using the app to see your statistics here';

  @override
  String get statsEmptyTrackMood => 'Track your mood daily';

  @override
  String get statsEmptyLogWater => 'Log your water intake';

  @override
  String get statsEmptyWriteJournal => 'Write journal entries';

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

  @override
  String get addNewHabit => 'Add New Habit';

  @override
  String get selectHabit => 'Select Habit';

  @override
  String get customHabitName => 'Custom Habit Name';

  @override
  String get customHabit => 'Custom Habit';

  @override
  String get frequency => 'Frequency';

  @override
  String get rewardPoints => 'Reward Points';

  @override
  String get pointsEarnedOnCompletion => 'Points earned on completion';

  @override
  String get customizeReward => 'Customize the reward for this habit';

  @override
  String get time => 'Time';

  @override
  String get selectTime => 'Select time';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String habitAlreadyExists(String frequency) {
    return 'This habit already exists with $frequency frequency!';
  }

  @override
  String get pointsMustBeGreaterThanZero => 'Points must be greater than 0!';

  @override
  String get habitDrinkWater => 'Drink Water';

  @override
  String get habitExercise => 'Exercise';

  @override
  String get habitMeditate => 'Meditate';

  @override
  String get habitRead => 'Read';

  @override
  String get habitSleepEarly => 'Sleep Early';

  @override
  String get habitStudy => 'Study';

  @override
  String get habitWalk => 'Walk';

  @override
  String get habitOther => 'Other';

  @override
  String get noHabitsYet => 'No habits yet!\nTap + to add your first habit';

  @override
  String get todaysHabits => 'Today\'s Habits';

  @override
  String get completed => 'Completed';

  @override
  String get skipped => 'Skipped';

  @override
  String get skipHabit => 'Skip Habit?';

  @override
  String skipHabitConfirmation(String habit) {
    return 'Are you sure you want to skip \"$habit\"?';
  }

  @override
  String get skip => 'Skip';

  @override
  String get deleteHabit => 'Delete Habit?';

  @override
  String deleteHabitConfirmation(String habit) {
    return 'Are you sure you want to permanently delete \"$habit\"?';
  }

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String habitCompleted(String habit) {
    return '$habit completed!';
  }

  @override
  String habitSkipped(String habit) {
    return '$habit skipped';
  }

  @override
  String habitDeleted(String habit) {
    return '🗑️ $habit deleted';
  }

  @override
  String get noDailyHabits => 'No daily habits yet';

  @override
  String get noWeeklyHabits => 'No weekly habits yet';

  @override
  String get noMonthlyHabits => 'No monthly habits yet';

  @override
  String get tapToAddHabit => 'Tap + button to add a habit';
}
