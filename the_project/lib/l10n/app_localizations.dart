import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @waterStats.
  ///
  /// In en, this message translates to:
  /// **'Water statistics'**
  String get waterStats;

  /// No description provided for @moodTracking.
  ///
  /// In en, this message translates to:
  /// **'Mood tracking'**
  String get moodTracking;

  /// No description provided for @journaling.
  ///
  /// In en, this message translates to:
  /// **'Journaling'**
  String get journaling;

  /// No description provided for @screenTime.
  ///
  /// In en, this message translates to:
  /// **'Screen time'**
  String get screenTime;

  /// No description provided for @glassesToday.
  ///
  /// In en, this message translates to:
  /// **'{count} glasses today'**
  String glassesToday(int count);

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg. {count} glasses / day'**
  String avgPerDay(int count);

  /// No description provided for @monthlyAvg.
  ///
  /// In en, this message translates to:
  /// **'Monthly average {count} glasses'**
  String monthlyAvg(Object count);

  /// No description provided for @yearlyAvg.
  ///
  /// In en, this message translates to:
  /// **'Yearly average {count} glasses'**
  String yearlyAvg(Object count);

  /// No description provided for @youWroteToday.
  ///
  /// In en, this message translates to:
  /// **'You wrote today'**
  String get youWroteToday;

  /// No description provided for @noEntryToday.
  ///
  /// In en, this message translates to:
  /// **'No entry today'**
  String get noEntryToday;

  /// No description provided for @daysLogged.
  ///
  /// In en, this message translates to:
  /// **'{count} days logged'**
  String daysLogged(int count);

  /// No description provided for @entriesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} entries this month'**
  String entriesThisMonth(int count);

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'{count} entries total'**
  String totalEntries(int count);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noMoodData.
  ///
  /// In en, this message translates to:
  /// **'No mood data available'**
  String get noMoodData;

  /// No description provided for @noWaterData.
  ///
  /// In en, this message translates to:
  /// **'No water data available'**
  String get noWaterData;

  /// No description provided for @noScreenTimeData.
  ///
  /// In en, this message translates to:
  /// **'No screen time data available'**
  String get noScreenTimeData;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get moodBalanced;

  /// No description provided for @moodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get moodLow;

  /// No description provided for @moodFeelingGreat.
  ///
  /// In en, this message translates to:
  /// **'Feeling great'**
  String get moodFeelingGreat;

  /// No description provided for @moodNice.
  ///
  /// In en, this message translates to:
  /// **'Nice mood'**
  String get moodNice;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodFeelingLow.
  ///
  /// In en, this message translates to:
  /// **'Feeling low'**
  String get moodFeelingLow;

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get statsNoData;

  /// No description provided for @statsNoMoodData.
  ///
  /// In en, this message translates to:
  /// **'No mood data available'**
  String get statsNoMoodData;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLockTitle;

  /// No description provided for @appLockChooseType.
  ///
  /// In en, this message translates to:
  /// **'Choose Lock Type:'**
  String get appLockChooseType;

  /// No description provided for @appLockPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get appLockPin;

  /// No description provided for @appLockPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure with numeric PIN'**
  String get appLockPinSubtitle;

  /// No description provided for @appLockPattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get appLockPattern;

  /// No description provided for @appLockPatternSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Draw a pattern to unlock'**
  String get appLockPatternSubtitle;

  /// No description provided for @appLockPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get appLockPassword;

  /// No description provided for @appLockPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use alphanumeric password'**
  String get appLockPasswordSubtitle;

  /// No description provided for @appLockRemoveExisting.
  ///
  /// In en, this message translates to:
  /// **'Remove Existing Lock'**
  String get appLockRemoveExisting;

  /// No description provided for @appLockSetYour.
  ///
  /// In en, this message translates to:
  /// **'Set Your {type}'**
  String appLockSetYour(Object type);

  /// No description provided for @appLockConfirmYour.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your {type}'**
  String appLockConfirmYour(Object type);

  /// No description provided for @appLockCreateLock.
  ///
  /// In en, this message translates to:
  /// **'Create your {type} lock'**
  String appLockCreateLock(Object type);

  /// No description provided for @appLockReenterLock.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your {type} to confirm'**
  String appLockReenterLock(Object type);

  /// No description provided for @appLockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-6 digit PIN'**
  String get appLockEnterPin;

  /// No description provided for @appLockConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get appLockConfirmPin;

  /// No description provided for @appLockDrawPattern.
  ///
  /// In en, this message translates to:
  /// **'Draw your pattern'**
  String get appLockDrawPattern;

  /// No description provided for @appLockDrawPatternAgain.
  ///
  /// In en, this message translates to:
  /// **'Draw your pattern again'**
  String get appLockDrawPatternAgain;

  /// No description provided for @appLockPointsSelected.
  ///
  /// In en, this message translates to:
  /// **'Points selected: {count}'**
  String appLockPointsSelected(Object count);

  /// No description provided for @appLockRedrawPattern.
  ///
  /// In en, this message translates to:
  /// **'Redraw Pattern'**
  String get appLockRedrawPattern;

  /// No description provided for @appLockEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get appLockEnterPassword;

  /// No description provided for @appLockConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get appLockConfirmPassword;

  /// No description provided for @appLockMismatch.
  ///
  /// In en, this message translates to:
  /// **'Lock values don\'t match!'**
  String get appLockMismatch;

  /// No description provided for @appLockContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get appLockContinue;

  /// No description provided for @appLockSaveLock.
  ///
  /// In en, this message translates to:
  /// **'Save Lock'**
  String get appLockSaveLock;

  /// No description provided for @appLockSaved.
  ///
  /// In en, this message translates to:
  /// **'App lock saved successfully'**
  String get appLockSaved;

  /// No description provided for @appLockSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save app lock'**
  String get appLockSaveError;

  /// No description provided for @appLockRemoved.
  ///
  /// In en, this message translates to:
  /// **'App lock removed'**
  String get appLockRemoved;

  /// No description provided for @appLockEnterToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter {type} to unlock'**
  String appLockEnterToUnlock(Object type);

  /// No description provided for @appLockWrongAttempt.
  ///
  /// In en, this message translates to:
  /// **'Wrong {type}! Try again'**
  String appLockWrongAttempt(Object type);

  /// No description provided for @appLockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// No description provided for @appLockForgotLock.
  ///
  /// In en, this message translates to:
  /// **'Forgot {type}?'**
  String appLockForgotLock(Object type);

  /// No description provided for @appLockVerifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to reset the lock'**
  String get appLockVerifyIdentity;

  /// No description provided for @appLockCurrentType.
  ///
  /// In en, this message translates to:
  /// **'Current lock: {type}'**
  String appLockCurrentType(Object type);

  /// No description provided for @appLockChangeOrRemove.
  ///
  /// In en, this message translates to:
  /// **'You can change or remove your current lock.'**
  String get appLockChangeOrRemove;

  /// No description provided for @appLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'App Lock Enabled'**
  String get appLockEnabled;

  /// No description provided for @appLockChangeLock.
  ///
  /// In en, this message translates to:
  /// **'Change Lock'**
  String get appLockChangeLock;

  /// No description provided for @appLockRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get appLockRemove;

  /// No description provided for @appLockCurrentSettings.
  ///
  /// In en, this message translates to:
  /// **'Current Settings'**
  String get appLockCurrentSettings;

  /// No description provided for @appLockRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove App Lock?'**
  String get appLockRemoveConfirm;

  /// No description provided for @appLockRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the app lock?'**
  String get appLockRemoveMessage;

  /// No description provided for @appLockCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get appLockCancel;

  /// No description provided for @statsRefreshingData.
  ///
  /// In en, this message translates to:
  /// **'Refreshing data...'**
  String get statsRefreshingData;

  /// No description provided for @statsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get statsLoading;

  /// No description provided for @statsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get statsErrorTitle;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data Yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start using the app to see your statistics here'**
  String get statsEmptySubtitle;

  /// No description provided for @statsEmptyTrackMood.
  ///
  /// In en, this message translates to:
  /// **'Track your mood daily'**
  String get statsEmptyTrackMood;

  /// No description provided for @statsEmptyLogWater.
  ///
  /// In en, this message translates to:
  /// **'Log your water intake'**
  String get statsEmptyLogWater;

  /// No description provided for @statsEmptyWriteJournal.
  ///
  /// In en, this message translates to:
  /// **'Write journal entries'**
  String get statsEmptyWriteJournal;

  /// No description provided for @calm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get calm;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// No description provided for @hoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} h/day'**
  String hoursPerDay(Object count);

  /// No description provided for @addNewHabit.
  ///
  /// In en, this message translates to:
  /// **'Add New Habit'**
  String get addNewHabit;

  /// No description provided for @selectHabit.
  ///
  /// In en, this message translates to:
  /// **'Select Habit'**
  String get selectHabit;

  /// No description provided for @customHabitName.
  ///
  /// In en, this message translates to:
  /// **'Custom Habit Name'**
  String get customHabitName;

  /// No description provided for @customHabit.
  ///
  /// In en, this message translates to:
  /// **'Custom Habit'**
  String get customHabit;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @rewardPoints.
  ///
  /// In en, this message translates to:
  /// **'Reward Points'**
  String get rewardPoints;

  /// No description provided for @pointsEarnedOnCompletion.
  ///
  /// In en, this message translates to:
  /// **'Points earned on completion'**
  String get pointsEarnedOnCompletion;

  /// No description provided for @customizeReward.
  ///
  /// In en, this message translates to:
  /// **'Customize the reward for this habit'**
  String get customizeReward;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @habitAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This habit already exists with {frequency} frequency!'**
  String habitAlreadyExists(String frequency);

  /// No description provided for @pointsMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Points must be greater than 0!'**
  String get pointsMustBeGreaterThanZero;

  /// No description provided for @habitDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink Water'**
  String get habitDrinkWater;

  /// No description provided for @habitExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get habitExercise;

  /// No description provided for @habitMeditate.
  ///
  /// In en, this message translates to:
  /// **'Meditate'**
  String get habitMeditate;

  /// No description provided for @habitRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get habitRead;

  /// No description provided for @habitSleepEarly.
  ///
  /// In en, this message translates to:
  /// **'Sleep Early'**
  String get habitSleepEarly;

  /// No description provided for @habitStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get habitStudy;

  /// No description provided for @habitWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get habitWalk;

  /// No description provided for @habitOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get habitOther;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet!\nTap + to add your first habit'**
  String get noHabitsYet;

  /// No description provided for @todaysHabits.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Habits'**
  String get todaysHabits;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @skipHabit.
  ///
  /// In en, this message translates to:
  /// **'Skip Habit?'**
  String get skipHabit;

  /// No description provided for @skipHabitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to skip \"{habit}\"?'**
  String skipHabitConfirmation(String habit);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit?'**
  String get deleteHabit;

  /// No description provided for @deleteHabitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete \"{habit}\"?'**
  String deleteHabitConfirmation(String habit);

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @habitCompleted.
  ///
  /// In en, this message translates to:
  /// **'{habit} completed!'**
  String habitCompleted(String habit);

  /// No description provided for @habitSkipped.
  ///
  /// In en, this message translates to:
  /// **'{habit} skipped'**
  String habitSkipped(String habit);

  /// No description provided for @habitDeleted.
  ///
  /// In en, this message translates to:
  /// **'🗑️ {habit} deleted'**
  String habitDeleted(String habit);

  /// No description provided for @noDailyHabits.
  ///
  /// In en, this message translates to:
  /// **'No daily habits yet'**
  String get noDailyHabits;

  /// No description provided for @noWeeklyHabits.
  ///
  /// In en, this message translates to:
  /// **'No weekly habits yet'**
  String get noWeeklyHabits;

  /// No description provided for @noMonthlyHabits.
  ///
  /// In en, this message translates to:
  /// **'No monthly habits yet'**
  String get noMonthlyHabits;

  /// No description provided for @tapToAddHabit.
  ///
  /// In en, this message translates to:
  /// **'Tap + button to add a habit'**
  String get tapToAddHabit;

  /// No description provided for @detoxProgress.
  ///
  /// In en, this message translates to:
  /// **'Detox Progress'**
  String get detoxProgress;

  /// No description provided for @detoxExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent Progress!'**
  String get detoxExcellent;

  /// No description provided for @detoxGood.
  ///
  /// In en, this message translates to:
  /// **'Good Progress'**
  String get detoxGood;

  /// No description provided for @detoxModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Progress'**
  String get detoxModerate;

  /// No description provided for @detoxLow.
  ///
  /// In en, this message translates to:
  /// **'Keep Going'**
  String get detoxLow;

  /// No description provided for @detoxStart.
  ///
  /// In en, this message translates to:
  /// **'Just Starting'**
  String get detoxStart;

  /// No description provided for @detoxInfo.
  ///
  /// In en, this message translates to:
  /// **'Average detox progress for the selected period'**
  String get detoxInfo;

  /// No description provided for @failedToLoadActivities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load activities\\n{error}'**
  String failedToLoadActivities(String error);

  /// No description provided for @breathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breath'**
  String get breathingTitle;

  /// No description provided for @breathingDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a deep breath and let your body wind down\\nfor the day.'**
  String get breathingDescription;

  /// No description provided for @breathingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get breathingStart;

  /// No description provided for @breathingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get breathingStop;

  /// No description provided for @bubblePopperTitle.
  ///
  /// In en, this message translates to:
  /// **'Pop It'**
  String get bubblePopperTitle;

  /// No description provided for @bubblePopperDescription.
  ///
  /// In en, this message translates to:
  /// **'Find calm and focus as you pop away stress, one bubble at a time.'**
  String get bubblePopperDescription;

  /// No description provided for @coloringTitle.
  ///
  /// In en, this message translates to:
  /// **'Coloring'**
  String get coloringTitle;

  /// No description provided for @coloringSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved! (wire export later)'**
  String get coloringSaved;

  /// No description provided for @coloringPickColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get coloringPickColorTitle;

  /// No description provided for @coloringHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get coloringHue;

  /// No description provided for @coloringSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get coloringSaturation;

  /// No description provided for @coloringBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get coloringBrightness;

  /// No description provided for @coloringOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get coloringOpacity;

  /// No description provided for @coloringUseColor.
  ///
  /// In en, this message translates to:
  /// **'Use color'**
  String get coloringUseColor;

  /// No description provided for @coloringTemplateSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get coloringTemplateSpace;

  /// No description provided for @coloringTemplateGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get coloringTemplateGarden;

  /// No description provided for @coloringTemplateFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get coloringTemplateFish;

  /// No description provided for @coloringTemplateButterfly.
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get coloringTemplateButterfly;

  /// No description provided for @coloringTemplateHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get coloringTemplateHouse;

  /// No description provided for @coloringTemplateMandala.
  ///
  /// In en, this message translates to:
  /// **'Mandala'**
  String get coloringTemplateMandala;

  /// No description provided for @coloringLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading coloring page:\\n{error}'**
  String coloringLoadError(String error);

  /// No description provided for @growPlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Grow the plant'**
  String get growPlantTitle;

  /// No description provided for @growPlantHeadline.
  ///
  /// In en, this message translates to:
  /// **'Nurture your plant with water and sunlight.\\nSpend activity points to help it grow!'**
  String get growPlantHeadline;

  /// No description provided for @growPlantStars.
  ///
  /// In en, this message translates to:
  /// **'Stars: {count}'**
  String growPlantStars(int count);

  /// No description provided for @growPlantStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get growPlantStage;

  /// No description provided for @growPlantAvailablePoints.
  ///
  /// In en, this message translates to:
  /// **'Available points: {count}'**
  String growPlantAvailablePoints(int count);

  /// No description provided for @growPlantGetPoints.
  ///
  /// In en, this message translates to:
  /// **'Get points'**
  String get growPlantGetPoints;

  /// No description provided for @growPlantWaterLabel.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get growPlantWaterLabel;

  /// No description provided for @growPlantSunlightLabel.
  ///
  /// In en, this message translates to:
  /// **'Sunlight'**
  String get growPlantSunlightLabel;

  /// No description provided for @growPlantWaterAction.
  ///
  /// In en, this message translates to:
  /// **'Water ({cost})'**
  String growPlantWaterAction(int cost);

  /// No description provided for @growPlantSunAction.
  ///
  /// In en, this message translates to:
  /// **'Sun ({cost})'**
  String growPlantSunAction(int cost);

  /// No description provided for @growPlantWaterHelper.
  ///
  /// In en, this message translates to:
  /// **'Spend {cost} pts'**
  String growPlantWaterHelper(int cost);

  /// No description provided for @growPlantSunHelper.
  ///
  /// In en, this message translates to:
  /// **'Spend {cost} pts'**
  String growPlantSunHelper(int cost);

  /// No description provided for @growPlantTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: when both bars are full, your plant will grow to the next stage.'**
  String get growPlantTip;

  /// No description provided for @paintingTitle.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get paintingTitle;

  /// No description provided for @paintingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Take a deep breath, pick your color, and let your creativity flow.'**
  String get paintingPrompt;

  /// No description provided for @paintingSaved.
  ///
  /// In en, this message translates to:
  /// **'Image Saved!.'**
  String get paintingSaved;

  /// No description provided for @paintingColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get paintingColorsTitle;

  /// No description provided for @paintingHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get paintingHue;

  /// No description provided for @paintingSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get paintingSaturation;

  /// No description provided for @paintingValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get paintingValue;

  /// No description provided for @paintingOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get paintingOpacity;

  /// No description provided for @paintingUseColor.
  ///
  /// In en, this message translates to:
  /// **'Use Color'**
  String get paintingUseColor;

  /// No description provided for @puzzleTitle.
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get puzzleTitle;

  /// No description provided for @puzzleInstruction.
  ///
  /// In en, this message translates to:
  /// **'Slide the tiles to re-create the correct order.'**
  String get puzzleInstruction;

  /// No description provided for @puzzleShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get puzzleShuffle;

  /// No description provided for @puzzleReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get puzzleReset;

  /// No description provided for @puzzleSolved.
  ///
  /// In en, this message translates to:
  /// **'Solved! 🎉'**
  String get puzzleSolved;

  /// No description provided for @plantArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'The calming effect of plants'**
  String get plantArticleTitle;

  /// No description provided for @plantArticleIntro.
  ///
  /// In en, this message translates to:
  /// **'Greenery does more than decorate your space — it relaxes your mind. Caring for a plant slows you down and brings your focus to the present moment.'**
  String get plantArticleIntro;

  /// No description provided for @plantArticleBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits at a glance'**
  String get plantArticleBenefitsTitle;

  /// No description provided for @plantArticleBullet1.
  ///
  /// In en, this message translates to:
  /// **'Reduces stress and mental fatigue'**
  String get plantArticleBullet1;

  /// No description provided for @plantArticleBullet2.
  ///
  /// In en, this message translates to:
  /// **'Improves focus and creativity'**
  String get plantArticleBullet2;

  /// No description provided for @plantArticleBullet3.
  ///
  /// In en, this message translates to:
  /// **'Adds gentle, natural color to your room'**
  String get plantArticleBullet3;

  /// No description provided for @plantArticleBullet4.
  ///
  /// In en, this message translates to:
  /// **'Creates a tiny daily ritual (water, prune, observe)'**
  String get plantArticleBullet4;

  /// No description provided for @plantArticleQuote.
  ///
  /// In en, this message translates to:
  /// **'“To nurture a garden is to feed not just the body, but the soul.”'**
  String get plantArticleQuote;

  /// No description provided for @plantArticleTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip of the day'**
  String get plantArticleTipTitle;

  /// No description provided for @plantArticleTipBody.
  ///
  /// In en, this message translates to:
  /// **'Place one small plant near where you work most. Check in with it once a day — a 30-second reset for your brain.'**
  String get plantArticleTipBody;

  /// No description provided for @plantArticleFooter.
  ///
  /// In en, this message translates to:
  /// **'Keep growing — one leaf at a time 🌿'**
  String get plantArticleFooter;

  /// No description provided for @sportArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Boost your mood with sports'**
  String get sportArticleTitle;

  /// No description provided for @sportArticleHeroText.
  ///
  /// In en, this message translates to:
  /// **'A little motion\\ncreates a lot of emotion 💪✨'**
  String get sportArticleHeroText;

  /// No description provided for @sportArticleIntro.
  ///
  /// In en, this message translates to:
  /// **'Moving your body is one of the fastest ways to lift your mood. Activity releases endorphins — your brain’s natural “feel-good” chemicals.'**
  String get sportArticleIntro;

  /// No description provided for @sportArticleEasyWaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Easy ways to start'**
  String get sportArticleEasyWaysTitle;

  /// No description provided for @sportArticleBullet1.
  ///
  /// In en, this message translates to:
  /// **'5–10 minute walk after meals'**
  String get sportArticleBullet1;

  /// No description provided for @sportArticleBullet2.
  ///
  /// In en, this message translates to:
  /// **'1 song dance break while making coffee'**
  String get sportArticleBullet2;

  /// No description provided for @sportArticleBullet3.
  ///
  /// In en, this message translates to:
  /// **'Light stretches while watching TV'**
  String get sportArticleBullet3;

  /// No description provided for @sportArticleBullet4.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend for a short jog or cycle'**
  String get sportArticleBullet4;

  /// No description provided for @sportArticleQuote.
  ///
  /// In en, this message translates to:
  /// **'Show up for 5 minutes. Most days, that’s all it takes to start.'**
  String get sportArticleQuote;

  /// No description provided for @sportArticleRememberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get sportArticleRememberTitle;

  /// No description provided for @sportArticleRememberBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a movement that makes you smile — not just one that makes you sweat. Joy builds consistency, and consistency lifts mood.'**
  String get sportArticleRememberBody;

  /// No description provided for @sportArticleStartActivityCta.
  ///
  /// In en, this message translates to:
  /// **'Start an activity'**
  String get sportArticleStartActivityCta;

  /// No description provided for @journalSelectDay.
  ///
  /// In en, this message translates to:
  /// **'Select a day to view journals'**
  String get journalSelectDay;

  /// No description provided for @journalNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No journals for this day'**
  String get journalNoEntries;

  /// No description provided for @journalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Journal'**
  String get journalDeleteTitle;

  /// No description provided for @journalDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this journal entry?'**
  String get journalDeleteMessage;

  /// No description provided for @journalDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Journal deleted successfully'**
  String get journalDeleteSuccess;

  /// No description provided for @journalDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Journal deleted successfully'**
  String get journalDeletedSuccessfully;

  /// No description provided for @journalUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Journal updated successfully'**
  String get journalUpdatedSuccessfully;

  /// No description provided for @journalCannotCreateFuture.
  ///
  /// In en, this message translates to:
  /// **'Cannot create journal for future dates'**
  String get journalCannotCreateFuture;

  /// No description provided for @journalWriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Journal'**
  String get journalWriteTitle;

  /// No description provided for @journalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get journalSave;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get journalTitle;

  /// No description provided for @journalWriteMore.
  ///
  /// In en, this message translates to:
  /// **'Write more here...'**
  String get journalWriteMore;

  /// No description provided for @journalAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Please add a title'**
  String get journalAddTitle;

  /// No description provided for @journalMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today?'**
  String get journalMoodTitle;

  /// No description provided for @journalSelectBackground.
  ///
  /// In en, this message translates to:
  /// **'Select Background'**
  String get journalSelectBackground;

  /// No description provided for @journalNoBackground.
  ///
  /// In en, this message translates to:
  /// **'No Background'**
  String get journalNoBackground;

  /// No description provided for @journalSelectSticker.
  ///
  /// In en, this message translates to:
  /// **'Select Sticker'**
  String get journalSelectSticker;

  /// No description provided for @journalTextStyle.
  ///
  /// In en, this message translates to:
  /// **'Text Style'**
  String get journalTextStyle;

  /// No description provided for @journalFontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get journalFontFamily;

  /// No description provided for @journalTextColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get journalTextColor;

  /// No description provided for @journalFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get journalFontSize;

  /// No description provided for @journalApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get journalApply;

  /// No description provided for @journalVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice Note'**
  String get journalVoiceNote;

  /// No description provided for @journalVoiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get journalVoiceRecording;

  /// No description provided for @journalVoiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved'**
  String get journalVoiceSaved;

  /// No description provided for @journalVoiceTapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording'**
  String get journalVoiceTapToStart;

  /// No description provided for @journalVoiceAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add Voice Note'**
  String get journalVoiceAddNote;

  /// No description provided for @journalVoicePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get journalVoicePermissionDenied;

  /// No description provided for @journalVoiceStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start recording: {error}'**
  String journalVoiceStartFailed(String error);

  /// No description provided for @journalVoiceStopFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop recording: {error}'**
  String journalVoiceStopFailed(String error);

  /// No description provided for @journalVoicePlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to play recording: {error}'**
  String journalVoicePlayFailed(String error);

  /// No description provided for @journalToolbarBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get journalToolbarBackground;

  /// No description provided for @journalToolbarAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get journalToolbarAddImage;

  /// No description provided for @journalToolbarStickers.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get journalToolbarStickers;

  /// No description provided for @journalToolbarTextStyle.
  ///
  /// In en, this message translates to:
  /// **'Text Style'**
  String get journalToolbarTextStyle;

  /// No description provided for @journalToolbarVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get journalToolbarVoiceNote;

  /// No description provided for @journalErrorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String journalErrorPickingImage(String error);

  /// No description provided for @journalMoodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get journalMoodHappy;

  /// No description provided for @journalMoodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get journalMoodGood;

  /// No description provided for @journalMoodExcited.
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get journalMoodExcited;

  /// No description provided for @journalMoodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get journalMoodCalm;

  /// No description provided for @journalMoodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get journalMoodSad;

  /// No description provided for @journalMoodTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get journalMoodTired;

  /// No description provided for @journalMoodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get journalMoodAnxious;

  /// No description provided for @journalMoodAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get journalMoodAngry;

  /// No description provided for @journalMoodConfused.
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get journalMoodConfused;

  /// No description provided for @journalMoodGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get journalMoodGrateful;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
