// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get today => 'اليوم';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get waterStats => 'إحصائيات الماء';

  @override
  String get moodTracking => 'تتبع المزاج';

  @override
  String get journaling => 'التدوين';

  @override
  String get screenTime => 'وقت الشاشة';

  @override
  String glassesToday(int count) {
    return '$count كأس اليوم';
  }

  @override
  String avgPerDay(int count) {
    return 'متوسط $count كأس / يوم';
  }

  @override
  String monthlyAvg(Object count) {
    return 'المتوسط الشهري $count كأس';
  }

  @override
  String yearlyAvg(Object count) {
    return 'المتوسط السنوي $count كأس';
  }

  @override
  String get youWroteToday => 'لقد كتبت اليوم';

  @override
  String get noEntryToday => 'لا يوجد مدخل اليوم';

  @override
  String daysLogged(int count) {
    return '$count يوم مسجل';
  }

  @override
  String entriesThisMonth(int count) {
    return '$count مدخل هذا الشهر';
  }

  @override
  String totalEntries(int count) {
    return '$count مدخل إجمالي';
  }

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get noMoodData => 'لا توجد بيانات عن المزاج';

  @override
  String get noWaterData => 'لا توجد بيانات عن الماء';

  @override
  String get noScreenTimeData => 'لا توجد بيانات عن وقت الشاشة';

  @override
  String get moodCalm => 'هادئ';

  @override
  String get moodBalanced => 'متوازن';

  @override
  String get moodLow => 'منخفض';

  @override
  String get moodFeelingGreat => 'شعور رائع';

  @override
  String get moodNice => 'مزاج جيد';

  @override
  String get moodOkay => 'حسن';

  @override
  String get moodFeelingLow => 'شعور منخفض';

  @override
  String get statsNoData => 'لا توجد بيانات';

  @override
  String get statsNoMoodData => 'لا توجد بيانات عن المزاج';

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
  String get statsRefreshingData => 'جاري تحديث البيانات...';

  @override
  String get statsLoading => 'جاري تحميل الإحصائيات...';

  @override
  String get statsErrorTitle => 'عذراً! حدث خطأ ما';

  @override
  String get commonTryAgain => 'حاول مرة أخرى';

  @override
  String get statsEmptyTitle => 'لا توجد بيانات بعد';

  @override
  String get statsEmptySubtitle => 'ابدأ باستخدام التطبيق لرؤية إحصائياتك هنا';

  @override
  String get statsEmptyTrackMood => 'تابع مزاجك يومياً';

  @override
  String get statsEmptyLogWater => 'سجل استهلاكك للماء';

  @override
  String get statsEmptyWriteJournal => 'اكتب في دفتر اليوميات';

  @override
  String get calm => 'هادئ';

  @override
  String get balanced => 'متوازن';

  @override
  String get low => 'منخفض';

  @override
  String get social => 'تواصل اجتماعي';

  @override
  String get entertainment => 'ترفيه';

  @override
  String get productivity => 'إنتاجية';

  @override
  String hoursPerDay(Object count) {
    return '$count ساعة/يوم';
  }

  @override
  String get addNewHabit => 'إضافة عادة جديدة';

  @override
  String get selectHabit => 'اختر العادة';

  @override
  String get customHabitName => 'اسم العادة المخصص';

  @override
  String get customHabit => 'عادة مخصصة';

  @override
  String get frequency => 'التكرار';

  @override
  String get rewardPoints => 'نقاط المكافأة';

  @override
  String get pointsEarnedOnCompletion => 'النقاط المكتسبة عند الإكمال';

  @override
  String get customizeReward => 'تخصيص المكافأة لهذه العادة';

  @override
  String get time => 'الوقت';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get setReminder => 'تعيين تذكير';

  @override
  String get cancel => 'إلغاء';

  @override
  String get add => 'إضافة';

  @override
  String habitAlreadyExists(String frequency) {
    return 'هذه العادة موجودة بالفمع تكرار $frequency!';
  }

  @override
  String get pointsMustBeGreaterThanZero => 'يجب أن تكون النقاط أكبر من 0!';

  @override
  String get habitDrinkWater => 'شرب الماء';

  @override
  String get habitExercise => 'ممارسة الرياضة';

  @override
  String get habitMeditate => 'التأمل';

  @override
  String get habitRead => 'القراءة';

  @override
  String get habitSleepEarly => 'النوم مبكراً';

  @override
  String get habitStudy => 'الدراسة';

  @override
  String get habitWalk => 'المشي';

  @override
  String get habitOther => 'أخرى';

  @override
  String get noHabitsYet => 'لا توجد عادات بعد!\nاضغط + لإضافة عادتك الأولى';

  @override
  String get todaysHabits => 'عادات اليوم';

  @override
  String get completed => 'مكتمل';

  @override
  String get skipped => 'تخطي';

  @override
  String get skipHabit => 'تخطي العادة؟';

  @override
  String skipHabitConfirmation(String habit) {
    return 'هل أنت متأكد أنك تريد تخطي \"$habit\"؟';
  }

  @override
  String get skip => 'تخطي';

  @override
  String get deleteHabit => 'حذف العادة؟';

  @override
  String deleteHabitConfirmation(String habit) {
    return 'هل أنت متأكد أنك تريد حذف \"$habit\" بشكل دائم؟';
  }

  @override
  String get actionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get delete => 'حذف';

  @override
  String habitCompleted(String habit) {
    return 'تم إكمال $habit!';
  }

  @override
  String habitSkipped(String habit) {
    return 'تم تخطي $habit';
  }

  @override
  String habitDeleted(String habit) {
    return '🗑️ تم حذف $habit';
  }

  @override
  String get noDailyHabits => 'لا توجد عادات يومية بعد';

  @override
  String get noWeeklyHabits => 'لا توجد عادات أسبوعية بعد';

  @override
  String get noMonthlyHabits => 'لا توجد عادات شهرية بعد';

  @override
  String get tapToAddHabit => 'اضغط على زر + لإضافة عادة';

  @override
  String get detoxProgress => 'تقدم التخلص من السموم';

  @override
  String get detoxExcellent => 'تقدم ممتاز!';

  @override
  String get detoxGood => 'تقدم جيد';

  @override
  String get detoxModerate => 'تقدم متوسط';

  @override
  String get detoxLow => 'استمر';

  @override
  String get detoxStart => 'البداية فقط';

  @override
  String get detoxInfo => 'متوسط تقدم التخلص من السموم للفترة المحددة';
}
