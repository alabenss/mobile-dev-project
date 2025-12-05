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
  String get moodNice => 'Nice';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodFeelingLow => 'Feeling low';

  @override
  String get statsNoData => 'No data';

  @override
  String get statsNoMoodData => 'No mood data available';

  @override
  String get appLockTitle => 'App Lock';

  @override
  String get appLockChooseType => 'Choose Lock Type:';

  @override
  String get appLockPin => 'PIN';

  @override
  String get appLockPinSubtitle => 'Secure with numeric PIN';

  @override
  String get appLockPattern => 'Pattern';

  @override
  String get appLockPatternSubtitle => 'Draw a pattern to unlock';

  @override
  String get appLockPassword => 'Password';

  @override
  String get appLockPasswordSubtitle => 'Use alphanumeric password';

  @override
  String get appLockRemoveExisting => 'Remove Existing Lock';

  @override
  String appLockSetYour(Object type) {
    return 'Set Your $type';
  }

  @override
  String appLockConfirmYour(Object type) {
    return 'Confirm Your $type';
  }

  @override
  String appLockCreateLock(Object type) {
    return 'Create your $type lock';
  }

  @override
  String appLockReenterLock(Object type) {
    return 'Re-enter your $type to confirm';
  }

  @override
  String get appLockEnterPin => 'Enter 4-6 digit PIN';

  @override
  String get appLockConfirmPin => 'Confirm your PIN';

  @override
  String get appLockDrawPattern => 'Draw your pattern';

  @override
  String get appLockDrawPatternAgain => 'Draw your pattern again';

  @override
  String appLockPointsSelected(Object count) {
    return 'Points selected: $count';
  }

  @override
  String get appLockRedrawPattern => 'Redraw Pattern';

  @override
  String get appLockEnterPassword => 'Enter password';

  @override
  String get appLockConfirmPassword => 'Confirm your password';

  @override
  String get appLockMismatch => 'Lock values don\'t match!';

  @override
  String get appLockContinue => 'Continue';

  @override
  String get appLockSaveLock => 'Save Lock';

  @override
  String get appLockSaved => 'App lock saved successfully';

  @override
  String get appLockSaveError => 'Failed to save app lock';

  @override
  String get appLockRemoved => 'App lock removed';

  @override
  String appLockEnterToUnlock(Object type) {
    return 'Enter $type to unlock';
  }

  @override
  String appLockWrongAttempt(Object type) {
    return 'Wrong $type! Try again';
  }

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String appLockForgotLock(Object type) {
    return 'Forgot $type?';
  }

  @override
  String get appLockVerifyIdentity => 'Verify your identity to reset the lock';

  @override
  String appLockCurrentType(Object type) {
    return 'Current lock: $type';
  }

  @override
  String get appLockChangeOrRemove => 'You can change or remove your current lock.';

  @override
  String get appLockEnabled => 'App Lock Enabled';

  @override
  String get appLockChangeLock => 'Change Lock';

  @override
  String get appLockRemove => 'Remove';

  @override
  String get appLockCurrentSettings => 'Current Settings';

  @override
  String get appLockRemoveConfirm => 'Remove App Lock?';

  @override
  String get appLockRemoveMessage => 'Are you sure you want to remove the app lock?';

  @override
  String get appLockCancel => 'Cancel';

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
  String get moodOk => 'Okay';

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
