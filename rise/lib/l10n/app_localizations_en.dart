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
  String get selectHabit => 'Select a Habit';

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
  String get selectTime => 'Select Time';

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
  String get coloringDescription => 'Relax with mindful coloring.';

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
  String get noHabitsYet => 'No habits yet!\\nTap + to add your first habit';

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

  @override
  String get detoxProgress => 'Detox Progress';

  @override
  String get detoxExcellent => 'Excellent Progress!';

  @override
  String get detoxGood => 'Good Progress';

  @override
  String get detoxModerate => 'Moderate Progress';

  @override
  String get detoxLow => 'Keep Going';

  @override
  String get detoxStart => 'Just Starting';

  @override
  String get detoxInfo => 'Average detox progress for the selected period';

  @override
  String failedToLoadActivities(String error) {
    return 'Failed to load activities\\n$error';
  }

  @override
  String get breathingTitle => 'Breath';

  @override
  String get breathingDescription => 'Take a deep breath and let your body wind down\\nfor the day.';

  @override
  String get breathingStart => 'Start';

  @override
  String get breathingStop => 'Stop';

  @override
  String get bubblePopperTitle => 'Pop It';

  @override
  String get bubblePopperDescription => 'Find calm and focus as you pop away stress, one bubble at a time.';

  @override
  String get coloringTitle => 'Coloring';

  @override
  String get coloringSaved => 'Saved! (wire export later)';

  @override
  String get coloringPickColorTitle => 'Pick a color';

  @override
  String get coloringHue => 'Hue';

  @override
  String get coloringSaturation => 'Saturation';

  @override
  String get coloringBrightness => 'Brightness';

  @override
  String get coloringOpacity => 'Opacity';

  @override
  String get coloringUseColor => 'Use color';

  @override
  String get coloringTemplateSpace => 'Space';

  @override
  String get coloringTemplateGarden => 'Garden';

  @override
  String get coloringTemplateFish => 'Fish';

  @override
  String get coloringTemplateButterfly => 'Butterfly';

  @override
  String get coloringTemplateHouse => 'House';

  @override
  String get coloringTemplateMandala => 'Mandala';

  @override
  String coloringLoadError(String error) {
    return 'Error loading coloring page:\\n$error';
  }

  @override
  String get growPlantTitle => 'Grow the plant';

  @override
  String get growPlantHeadline => 'Nurture your plant with water and sunlight.\\nSpend activity points to help it grow!';

  @override
  String growPlantStars(int count) {
    return 'Stars: $count';
  }

  @override
  String get growPlantStage => 'Stage';

  @override
  String growPlantAvailablePoints(int count) {
    return 'Available points: $count';
  }

  @override
  String get growPlantGetPoints => 'Get points';

  @override
  String get growPlantWaterLabel => 'Water';

  @override
  String get growPlantSunlightLabel => 'Sunlight';

  @override
  String growPlantWaterAction(int cost) {
    return 'Water ($cost)';
  }

  @override
  String growPlantSunAction(int cost) {
    return 'Sun ($cost)';
  }

  @override
  String growPlantWaterHelper(int cost) {
    return 'Spend $cost pts';
  }

  @override
  String growPlantSunHelper(int cost) {
    return 'Spend $cost pts';
  }

  @override
  String get growPlantTip => 'Tip: when both bars are full, your plant will grow to the next stage.';

  @override
  String get paintingTitle => 'Draw';

  @override
  String get paintingPrompt => 'Take a deep breath, pick your color, and let your creativity flow.';

  @override
  String get paintingSaved => 'Image Saved!.';

  @override
  String get paintingColorsTitle => 'Colors';

  @override
  String get paintingHue => 'Hue';

  @override
  String get paintingSaturation => 'Saturation';

  @override
  String get paintingValue => 'Value';

  @override
  String get paintingOpacity => 'Opacity';

  @override
  String get paintingUseColor => 'Use Color';

  @override
  String get puzzleTitle => 'Puzzle';

  @override
  String get puzzleInstruction => 'Slide the tiles to re-create the correct order.';

  @override
  String get puzzleShuffle => 'Shuffle';

  @override
  String get puzzleReset => 'Reset';

  @override
  String get puzzleSolved => 'Solved! 🎉';

  @override
  String get plantArticleTitle => 'The calming effect of plants';

  @override
  String get plantArticleIntro => 'Greenery does more than decorate your space — it relaxes your mind. Caring for a plant slows you down and brings your focus to the present moment.';

  @override
  String get plantArticleBenefitsTitle => 'Benefits at a glance';

  @override
  String get plantArticleBullet1 => 'Reduces stress and mental fatigue';

  @override
  String get plantArticleBullet2 => 'Improves focus and creativity';

  @override
  String get plantArticleBullet3 => 'Adds gentle, natural color to your room';

  @override
  String get plantArticleBullet4 => 'Creates a tiny daily ritual (water, prune, observe)';

  @override
  String get plantArticleQuote => '“To nurture a garden is to feed not just the body, but the soul.”';

  @override
  String get plantArticleTipTitle => 'Tip of the day';

  @override
  String get plantArticleTipBody => 'Place one small plant near where you work most. Check in with it once a day — a 30-second reset for your brain.';

  @override
  String get plantArticleFooter => 'Keep growing — one leaf at a time 🌿';

  @override
  String get sportArticleTitle => 'Boost your mood with sports';

  @override
  String get sportArticleHeroText => 'A little motion\\ncreates a lot of emotion 💪✨';

  @override
  String get sportArticleIntro => 'Moving your body is one of the fastest ways to lift your mood. Activity releases endorphins — your brain’s natural “feel-good” chemicals.';

  @override
  String get sportArticleEasyWaysTitle => 'Easy ways to start';

  @override
  String get sportArticleBullet1 => '5–10 minute walk after meals';

  @override
  String get sportArticleBullet2 => '1 song dance break while making coffee';

  @override
  String get sportArticleBullet3 => 'Light stretches while watching TV';

  @override
  String get sportArticleBullet4 => 'Invite a friend for a short jog or cycle';

  @override
  String get sportArticleQuote => 'Show up for 5 minutes. Most days, that’s all it takes to start.';

  @override
  String get sportArticleRememberTitle => 'Remember';

  @override
  String get sportArticleRememberBody => 'Pick a movement that makes you smile — not just one that makes you sweat. Joy builds consistency, and consistency lifts mood.';

  @override
  String get sportArticleStartActivityCta => 'Start an activity';

  @override
  String get journalSelectDay => 'Select a day to view journals';

  @override
  String get journalNoEntries => 'No journals for this day';

  @override
  String get journalDeleteTitle => 'Delete Journal';

  @override
  String get journalDeleteMessage => 'Are you sure you want to delete this journal entry?';

  @override
  String get journalDeleteSuccess => 'Journal deleted successfully';

  @override
  String get journalDeletedSuccessfully => 'Journal deleted successfully';

  @override
  String get journalUpdatedSuccessfully => 'Journal updated successfully';

  @override
  String get journalCannotCreateFuture => 'Cannot create journal for future dates';

  @override
  String get journalWriteTitle => 'Write Journal';

  @override
  String get journalSave => 'Save';

  @override
  String get journalTitle => 'Title';

  @override
  String get journalWriteMore => 'Write more here...';

  @override
  String get journalAddTitle => 'Please add a title';

  @override
  String get journalMoodTitle => 'How do you feel today?';

  @override
  String get journalSelectBackground => 'Select Background';

  @override
  String get journalNoBackground => 'No Background';

  @override
  String get journalSelectSticker => 'Select Sticker';

  @override
  String get journalTextStyle => 'Text Style';

  @override
  String get journalFontFamily => 'Font Family';

  @override
  String get journalTextColor => 'Text Color';

  @override
  String get journalFontSize => 'Font Size';

  @override
  String get journalApply => 'Apply';

  @override
  String get journalVoiceNote => 'Voice Note';

  @override
  String get journalVoiceRecording => 'Recording...';

  @override
  String get journalVoiceSaved => 'Recording saved';

  @override
  String get journalVoiceTapToStart => 'Tap to start recording';

  @override
  String get journalVoiceAddNote => 'Add Voice Note';

  @override
  String get journalVoicePermissionDenied => 'Microphone permission denied';

  @override
  String journalVoiceStartFailed(String error) {
    return 'Failed to start recording: $error';
  }

  @override
  String journalVoiceStopFailed(String error) {
    return 'Failed to stop recording: $error';
  }

  @override
  String journalVoicePlayFailed(String error) {
    return 'Failed to play recording: $error';
  }

  @override
  String get journalToolbarBackground => 'Background';

  @override
  String get journalToolbarAddImage => 'Add Image';

  @override
  String get journalToolbarStickers => 'Stickers';

  @override
  String get journalToolbarTextStyle => 'Text Style';

  @override
  String get journalToolbarVoiceNote => 'Voice note';

  @override
  String journalErrorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String get journalMoodHappy => 'Happy';

  @override
  String get journalMoodGood => 'Good';

  @override
  String get journalMoodExcited => 'Excited';

  @override
  String get journalMoodCalm => 'Calm';

  @override
  String get journalMoodSad => 'Sad';

  @override
  String get journalMoodTired => 'Tired';

  @override
  String get journalMoodAnxious => 'Anxious';

  @override
  String get journalMoodAngry => 'Angry';

  @override
  String get journalMoodConfused => 'Confused';

  @override
  String get journalMoodGrateful => 'Grateful';

  @override
  String get detoxCardTitle => 'Digital detox:';

  @override
  String get detoxCardPhoneLocked => 'Phone is locked';

  @override
  String get detoxCardDisableLock => 'Disable Lock';

  @override
  String get detoxCardComplete => 'complete';

  @override
  String get detoxCardReset => 'Reset';

  @override
  String get detoxCardLock30m => 'Lock 30m';

  @override
  String get exploreSectionTitle => 'Explore';

  @override
  String get explorePlantTitle => 'The calming effect of plants';

  @override
  String get exploreReadNow => 'Read Now';

  @override
  String get exploreSportsTitle => 'Boost your\\nmood with\\nsports';

  @override
  String homeHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeViewAllHabits => 'view all';

  @override
  String get phoneLockTitle => 'Phone is locked';

  @override
  String get phoneLockSubtitle => 'Take a break from your screen.\\nYour digital detox is in progress.';

  @override
  String get phoneLockStayStrong => 'Stay strong!';

  @override
  String get phoneLockDisableTitle => 'Disable Lock?';

  @override
  String get phoneLockDisableMessage => 'If you disable the lock early, your detox progress will not increase. Are you sure?';

  @override
  String get phoneLockStayLockedCta => 'Stay Locked';

  @override
  String get phoneLockDisableCta => 'Disable';

  @override
  String get phoneLockDisableButton => 'Disable Lock';

  @override
  String get waterIntakeTitle => 'Water intake:';

  @override
  String get waterGlassesUnit => 'glasses';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get journalMoodCardTitle => 'How do you feel today?';

  @override
  String get journalMoodCardToday => 'Today';

  @override
  String get journalMoodCardRetry => 'Retry';

  @override
  String get journalMoodCardFailedToLoad => 'Failed to load mood';

  @override
  String get journalCalendarMon => 'Mon';

  @override
  String get journalCalendarTue => 'Tue';

  @override
  String get journalCalendarWed => 'Wed';

  @override
  String get journalCalendarThu => 'Thu';

  @override
  String get journalCalendarFri => 'Fri';

  @override
  String get journalCalendarSat => 'Sat';

  @override
  String get journalCalendarSun => 'Sun';

  @override
  String get journalCalendarMonday => 'Monday';

  @override
  String get journalCalendarTuesday => 'Tuesday';

  @override
  String get journalCalendarWednesday => 'Wednesday';

  @override
  String get journalCalendarThursday => 'Thursday';

  @override
  String get journalCalendarFriday => 'Friday';

  @override
  String get journalCalendarSaturday => 'Saturday';

  @override
  String get journalCalendarSunday => 'Sunday';

  @override
  String get journalMonthJan => 'Jan';

  @override
  String get journalMonthFeb => 'Feb';

  @override
  String get journalMonthMar => 'Mar';

  @override
  String get journalMonthApr => 'Apr';

  @override
  String get journalMonthMay => 'May';

  @override
  String get journalMonthJun => 'Jun';

  @override
  String get journalMonthJul => 'Jul';

  @override
  String get journalMonthAug => 'Aug';

  @override
  String get journalMonthSep => 'Sep';

  @override
  String get journalMonthOct => 'Oct';

  @override
  String get journalMonthNov => 'Nov';

  @override
  String get journalMonthDec => 'Dec';

  @override
  String get journalMonthJanuary => 'January';

  @override
  String get journalMonthFebruary => 'February';

  @override
  String get journalMonthMarch => 'March';

  @override
  String get journalMonthApril => 'April';

  @override
  String get journalMonthMayFull => 'May';

  @override
  String get journalMonthJune => 'June';

  @override
  String get journalMonthJuly => 'July';

  @override
  String get journalMonthAugust => 'August';

  @override
  String get journalMonthSeptember => 'September';

  @override
  String get journalMonthOctober => 'October';

  @override
  String get journalMonthNovember => 'November';

  @override
  String get journalMonthDecember => 'December';

  @override
  String get quote1 => 'The best way to predict the future is to create it';

  @override
  String get quote2 => 'You are stronger than you think.';

  @override
  String get quote3 => 'Small steps every day lead to big changes.';

  @override
  String get quote4 => 'You don’t have to be perfect to be amazing.';

  @override
  String get quote5 => 'Believe you can and you’re halfway there.';

  @override
  String get quote6 => 'If you want to live a happy life, tie it to a goal, not to people or things.';

  @override
  String get quote7 => 'The only way to do great work is to love what you do.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoUserLoggedIn => 'No user logged in';

  @override
  String get profileEditPictureComingSoon => 'Profile picture editing coming soon!';

  @override
  String get profilePointsLabel => 'Points';

  @override
  String get profileStarsLabel => 'Stars';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileUsernameLabel => 'Username';

  @override
  String get profileJoinedLabel => 'Joined';

  @override
  String get profileJoinedRecently => 'Recently';

  @override
  String get profileAppLockTitle => 'App Lock';

  @override
  String get profileAppLockSubtitle => 'Set or change your app lock';

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get profileLogoutButton => 'Log Out';

  @override
  String get profileLogoutDialogTitle => 'Log Out';

  @override
  String get profileLogoutDialogContent => 'Are you sure you want to log out?';

  @override
  String get profileLogoutDialogCancel => 'Cancel';

  @override
  String get profileLogoutDialogConfirm => 'Log Out';

  @override
  String get profileEmailUpdated => 'Email updated!';

  @override
  String get profileUsernameUpdated => 'Username updated!';

  @override
  String get profileEditEmailTitle => 'Edit Email';

  @override
  String get profileEditUsernameTitle => 'Edit Username';

  @override
  String get profileDialogCancel => 'Cancel';

  @override
  String get profileDialogSave => 'Save';

  @override
  String get languageScreenTitle => 'Language';

  @override
  String get languageSystemDefaultTitle => 'System Default';

  @override
  String get languageSystemDefaultSubtitle => 'Follow device settings';

  @override
  String get languageAvailableLanguagesSectionTitle => 'Available Languages';

  @override
  String get languageSystemDefaultSnack => 'Language set to system default';

  @override
  String languageChangedSnack(String language) {
    return 'Language changed to $language';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Login to continue your journey';

  @override
  String get usernameOrEmail => 'Username or Email';

  @override
  String get enterUsernameOrEmail => 'Please enter your username or email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Please enter a password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpSubtitle => 'Start your wellness journey today';

  @override
  String get firstName => 'First Name';

  @override
  String get enterFirstName => 'Please enter your first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterLastName => 'Please enter your last name';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Please enter a username';

  @override
  String get usernameTooShort => 'Username must be at least 3 characters';

  @override
  String get usernameNoSpaces => 'Username cannot contain spaces';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get badHabit => 'Bad Habit';

  @override
  String get points => 'Points';

  @override
  String get remindMe => 'Remind Me';
}
