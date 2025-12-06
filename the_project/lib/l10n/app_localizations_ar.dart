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
  String get coloringDescription => 'ارح تفكيرك ببعض التلوين';

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

  @override
  String failedToLoadActivities(String error) {
    return 'فشل تحميل الأنشطة\n$error';
  }

  @override
  String get breathingTitle => 'تنفّس';

  @override
  String get breathingDescription => 'خذ نفسًا عميقًا ودع جسمك يهدأ\nفي نهاية اليوم.';

  @override
  String get breathingStart => 'ابدأ';

  @override
  String get breathingStop => 'إيقاف';

  @override
  String get bubblePopperTitle => 'فرقع الفقاعات';

  @override
  String get bubblePopperDescription => 'ابحث عن الهدوء والتركيز بينما تفرّغ التوتر، فقاعة بعد أخرى.';

  @override
  String get coloringTitle => 'التلوين';

  @override
  String get coloringSaved => 'تم الحفظ! (سيتم إضافة التصدير لاحقًا)';

  @override
  String get coloringPickColorTitle => 'اختر لونًا';

  @override
  String get coloringHue => 'تدرج اللون';

  @override
  String get coloringSaturation => 'الإشباع';

  @override
  String get coloringBrightness => 'السطوع';

  @override
  String get coloringOpacity => 'الشفافية';

  @override
  String get coloringUseColor => 'استخدام اللون';

  @override
  String get coloringTemplateSpace => 'الفضاء';

  @override
  String get coloringTemplateGarden => 'الحديقة';

  @override
  String get coloringTemplateFish => 'سمكة';

  @override
  String get coloringTemplateButterfly => 'فراشة';

  @override
  String get coloringTemplateHouse => 'منزل';

  @override
  String get coloringTemplateMandala => 'ماندالا';

  @override
  String coloringLoadError(String error) {
    return 'حدث خطأ أثناء تحميل صفحة التلوين:\n$error';
  }

  @override
  String get growPlantTitle => 'نمِّ النبتة';

  @override
  String get growPlantHeadline => 'اعتنِ بنبتتك بالماء والضوء.\nاستخدم نقاط الأنشطة لمساعدتها على النمو!';

  @override
  String growPlantStars(int count) {
    return 'النجوم: $count';
  }

  @override
  String get growPlantStage => 'المرحلة';

  @override
  String growPlantAvailablePoints(int count) {
    return 'النقاط المتاحة: $count';
  }

  @override
  String get growPlantGetPoints => 'احصل على نقاط';

  @override
  String get growPlantWaterLabel => 'الماء';

  @override
  String get growPlantSunlightLabel => 'أشعة الشمس';

  @override
  String growPlantWaterAction(int cost) {
    return 'ماء ($cost)';
  }

  @override
  String growPlantSunAction(int cost) {
    return 'شمس ($cost)';
  }

  @override
  String growPlantWaterHelper(int cost) {
    return 'استخدم $cost نقطة';
  }

  @override
  String growPlantSunHelper(int cost) {
    return 'استخدم $cost نقطة';
  }

  @override
  String get growPlantTip => 'نصيحة: عندما يمتلئ الشريطان، ستنتقل نبتتك إلى المرحلة التالية.';

  @override
  String get paintingTitle => 'ارسم';

  @override
  String get paintingPrompt => 'خذ نفسًا عميقًا، اختر لونك، ودع إبداعك يتدفق.';

  @override
  String get paintingSaved => 'تم حفظ الصورة!';

  @override
  String get paintingColorsTitle => 'الألوان';

  @override
  String get paintingHue => 'تدرج اللون';

  @override
  String get paintingSaturation => 'الإشباع';

  @override
  String get paintingValue => 'القيمة';

  @override
  String get paintingOpacity => 'الشفافية';

  @override
  String get paintingUseColor => 'استخدام اللون';

  @override
  String get puzzleTitle => 'لغز';

  @override
  String get puzzleInstruction => 'حرّك القطع لإعادة ترتيبها بالترتيب الصحيح.';

  @override
  String get puzzleShuffle => 'خلط';

  @override
  String get puzzleReset => 'إعادة تعيين';

  @override
  String get puzzleSolved => 'تم الحل! 🎉';

  @override
  String get plantArticleTitle => 'التأثير المهدئ للنباتات';

  @override
  String get plantArticleIntro => 'النباتات لا تزيّن مكانك فقط — بل تهدّئ عقلك أيضًا.';

  @override
  String get plantArticleBenefitsTitle => 'الفوائد باختصار';

  @override
  String get plantArticleBullet1 => 'يقلل من التوتر والإرهاق الذهني';

  @override
  String get plantArticleBullet2 => 'يحسّن التركيز والإبداع';

  @override
  String get plantArticleBullet3 => 'يضيف لمسة لطيفة وطبيعية لمحيطك';

  @override
  String get plantArticleBullet4 => 'يخلق طقسًا يوميًا بسيطًا (سقي، تقليم، ملاحظة)';

  @override
  String get plantArticleQuote => '«العناية بالحديقة تغذي ليس الجسد فقط، بل الروح أيضًا.»';

  @override
  String get plantArticleTipTitle => 'نصيحة اليوم';

  @override
  String get plantArticleTipBody => 'ضع نبتة صغيرة بالقرب من المكان الذي تعمل فيه غالبًا...';

  @override
  String get plantArticleFooter => 'استمر في النمو — ورقة بعد أخرى 🌿';

  @override
  String get sportArticleTitle => 'حسِّن مزاجك بالرياضة';

  @override
  String get sportArticleHeroText => 'قليل من الحركة\nيخلق الكثير من الشعور 💪✨';

  @override
  String get sportArticleIntro => 'تحريك جسمك من أسرع الطرق لرفع مزاجك...';

  @override
  String get sportArticleEasyWaysTitle => 'طرق بسيطة للبدء';

  @override
  String get sportArticleBullet1 => 'مشي 5–10 دقائق بعد الوجبات';

  @override
  String get sportArticleBullet2 => 'استراحة رقص...';

  @override
  String get sportArticleBullet3 => 'تمددات خفيفة...';

  @override
  String get sportArticleBullet4 => 'ادعُ صديقًا...';

  @override
  String get sportArticleQuote => 'احضر فقط لمدة 5 دقائق...';

  @override
  String get sportArticleRememberTitle => 'تذكّر';

  @override
  String get sportArticleRememberBody => 'اختر حركة تجعلك تبتسم...';

  @override
  String get sportArticleStartActivityCta => 'ابدأ نشاطًا';

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
  String get detoxCardTitle => 'التحرر الرقمي:';

  @override
  String get detoxCardPhoneLocked => 'الهاتف مقفول';

  @override
  String get detoxCardDisableLock => 'إيقاف القفل';

  @override
  String get detoxCardComplete => 'مكتمل';

  @override
  String get detoxCardReset => 'إعادة التعيين';

  @override
  String get detoxCardLock30m => 'قفل لمدة 30 دقيقة';

  @override
  String get exploreSectionTitle => 'استكشف';

  @override
  String get explorePlantTitle => 'التأثير المهدئ للنباتات';

  @override
  String get exploreReadNow => 'اقرأ الآن';

  @override
  String get exploreSportsTitle => 'حسِّن\nمزاجك\nبالرياضة';

  @override
  String homeHello(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get homeViewAllHabits => 'عرض الكل';

  @override
  String get phoneLockTitle => 'الهاتف مقفول';

  @override
  String get phoneLockSubtitle => 'خذ استراحة من الشاشة.\nعملية التخلص من السموم الرقمية قيد التقدم.';

  @override
  String get phoneLockStayStrong => 'ابقَ قويًا!';

  @override
  String get phoneLockDisableTitle => 'إلغاء القفل؟';

  @override
  String get phoneLockDisableMessage => 'إذا ألغيت القفل مبكرًا...';

  @override
  String get phoneLockStayLockedCta => 'ابقَ مقفولًا';

  @override
  String get phoneLockDisableCta => 'إلغاء';

  @override
  String get phoneLockDisableButton => 'إلغاء القفل';

  @override
  String get waterIntakeTitle => 'شرب الماء:';

  @override
  String get waterGlassesUnit => 'أكواب';

  @override
  String get commonReset => 'إعادة التعيين';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get journalMoodCardTitle => 'كيف تشعر اليوم؟';

  @override
  String get journalMoodCardToday => 'اليوم';

  @override
  String get journalMoodCardRetry => 'إعادة المحاولة';

  @override
  String get journalMoodCardFailedToLoad => 'فشل تحميل الحالة المزاجية';

  @override
  String get journalCalendarMon => 'الإثنين';

  @override
  String get journalCalendarTue => 'الثلاثاء';

  @override
  String get journalCalendarWed => 'الأربعاء';

  @override
  String get journalCalendarThu => 'الخميس';

  @override
  String get journalCalendarFri => 'الجمعة';

  @override
  String get journalCalendarSat => 'السبت';

  @override
  String get journalCalendarSun => 'الأحد';

  @override
  String get journalCalendarMonday => 'الإثنين';

  @override
  String get journalCalendarTuesday => 'الثلاثاء';

  @override
  String get journalCalendarWednesday => 'الأربعاء';

  @override
  String get journalCalendarThursday => 'الخميس';

  @override
  String get journalCalendarFriday => 'الجمعة';

  @override
  String get journalCalendarSaturday => 'السبت';

  @override
  String get journalCalendarSunday => 'الأحد';

  @override
  String get journalMonthJan => 'يناير';

  @override
  String get journalMonthFeb => 'فبراير';

  @override
  String get journalMonthMar => 'مارس';

  @override
  String get journalMonthApr => 'أبريل';

  @override
  String get journalMonthMay => 'مايو';

  @override
  String get journalMonthJun => 'يونيو';

  @override
  String get journalMonthJul => 'يوليو';

  @override
  String get journalMonthAug => 'أغسطس';

  @override
  String get journalMonthSep => 'سبتمبر';

  @override
  String get journalMonthOct => 'أكتوبر';

  @override
  String get journalMonthNov => 'نوفمبر';

  @override
  String get journalMonthDec => 'ديسمبر';

  @override
  String get journalMonthJanuary => 'يناير';

  @override
  String get journalMonthFebruary => 'فبراير';

  @override
  String get journalMonthMarch => 'مارس';

  @override
  String get journalMonthApril => 'أبريل';

  @override
  String get journalMonthMayFull => 'مايو';

  @override
  String get journalMonthJune => 'يونيو';

  @override
  String get journalMonthJuly => 'يوليو';

  @override
  String get journalMonthAugust => 'أغسطس';

  @override
  String get journalMonthSeptember => 'سبتمبر';

  @override
  String get journalMonthOctober => 'أكتوبر';

  @override
  String get journalMonthNovember => 'نوفمبر';

  @override
  String get journalMonthDecember => 'ديسمبر';
}
