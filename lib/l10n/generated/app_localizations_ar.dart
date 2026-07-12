// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مصروفي';

  @override
  String get dashboardTab => 'الرئيسية';

  @override
  String get historyTab => 'السجل';

  @override
  String get reportsTab => 'التقارير';

  @override
  String get budgetsTab => 'الميزانيات';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get dashboardEmptyTitle => 'لا توجد معاملات حتى الآن';

  @override
  String get dashboardEmptyBody => 'ستظهر ملخصات اليوم والأسبوع والشهر هنا.';

  @override
  String get historyEmptyTitle => 'السجل فارغ';

  @override
  String get historyEmptyBody => 'ستظهر المعاملات مرتبة حسب التاريخ.';

  @override
  String get reportsEmptyTitle => 'لا توجد بيانات للتقارير';

  @override
  String get reportsEmptyBody => 'ستظهر الرسوم البيانية بعد تسجيل معاملات.';

  @override
  String get budgetsEmptyTitle => 'لا توجد ميزانيات';

  @override
  String get budgetsEmptyBody => 'ستظهر الميزانيات الشهرية لكل تصنيف هنا.';

  @override
  String get budget => 'الميزانية';

  @override
  String get addBudget => 'إضافة ميزانية';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get deleteBudget => 'حذف الميزانية';

  @override
  String get monthlyBudget => 'ميزانية شهرية';

  @override
  String budgetMonthLabel(Object month) {
    return '$month';
  }

  @override
  String get budgetPreviousMonth => 'الشهر السابق';

  @override
  String get budgetNextMonth => 'الشهر التالي';

  @override
  String get budgetCategoryLabel => 'التصنيف';

  @override
  String get budgetCategoryRequired => 'اختر التصنيف';

  @override
  String get budgetAmountLabel => 'مبلغ الميزانية';

  @override
  String get budgetAmountRequired => 'أدخل مبلغ ميزانية أكبر من صفر';

  @override
  String get budgetNoteLabel => 'ملاحظة';

  @override
  String get budgetSpent => 'المصروف';

  @override
  String get budgetRemaining => 'المتبقي';

  @override
  String get budgetExceeded => 'تم تجاوز الميزانية';

  @override
  String get budgetApproachingLimit => 'قريب من الحد';

  @override
  String get budgetSafe => 'ضمن الحد';

  @override
  String get budgetSavedMessage => 'تم حفظ الميزانية';

  @override
  String get budgetDeletedMessage => 'تم حذف الميزانية';

  @override
  String get budgetsLoadError => 'تعذر تحميل الميزانيات';

  @override
  String get budgetsLoadErrorBody =>
      'تعذر تحديث بيانات الميزانيات. حاول مرة أخرى.';

  @override
  String get budgetDuplicateValidation =>
      'يوجد ميزانية لهذا التصنيف في الشهر المحدد بالفعل';

  @override
  String get budgetExpenseCategoryValidation => 'اختر تصنيف مصروف متاح';

  @override
  String get budgetNoExpenseCategories => 'لا توجد تصنيفات مصروفات متاحة';

  @override
  String get budgetHiddenCategory => 'تصنيف مخفي';

  @override
  String get budgetCategoryUnavailable => 'تصنيف غير متاح';

  @override
  String budgetDeleteConfirmation(Object categoryName) {
    return 'هل تريد حذف ميزانية $categoryName؟';
  }

  @override
  String budgetProgressSemantics(Object categoryName, Object percentage) {
    return 'تم استخدام $percentage% من ميزانية $categoryName';
  }

  @override
  String get startupLoadingTitle => 'جارٍ تشغيل مصروفي';

  @override
  String get startupLoadingBody => 'يتم تجهيز بياناتك المحلية بأمان.';

  @override
  String get startupFailureTitle => 'تعذر بدء التطبيق';

  @override
  String get startupFailureBody =>
      'حدث خطأ أثناء إعداد البيانات المحلية. حاول مرة أخرى.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get languageSectionTitle => 'اللغة';

  @override
  String get themeSectionTitle => 'المظهر';

  @override
  String get themeModeSystem => 'حسب النظام';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get addTransaction => 'إضافة';

  @override
  String get addTransactionTitle => 'إضافة معاملة';

  @override
  String get editTransactionTitle => 'تعديل المعاملة';

  @override
  String get saveTransaction => 'حفظ المعاملة';

  @override
  String get updateTransaction => 'تحديث المعاملة';

  @override
  String get transactionSavedMessage => 'تم حفظ المعاملة';

  @override
  String get transactionUpdatedMessage => 'تم تحديث المعاملة';

  @override
  String get transactionTypeExpenseForm => 'مصروف';

  @override
  String get transactionTypeIncomeForm => 'دخل';

  @override
  String get transactionTypeLabel => 'النوع';

  @override
  String get transactionAmountLabel => 'المبلغ';

  @override
  String get transactionAmountRequired => 'أدخل مبلغًا صحيحًا';

  @override
  String get transactionCategoryLabel => 'التصنيف';

  @override
  String get transactionCategoryRequired => 'اختر التصنيف';

  @override
  String get transactionPersonLabel => 'اسم الشخص';

  @override
  String get transactionWalletLabel => 'المحفظة';

  @override
  String get transactionNoteLabel => 'ملاحظة';

  @override
  String get transactionDeleteTooltip => 'حذف المعاملة';

  @override
  String get transactionDeleteConfirmation => 'هل تريد حذف هذه المعاملة؟';

  @override
  String get transactionEditTooltip => 'تعديل المعاملة';

  @override
  String get transactionDetailsTitle => 'تفاصيل المعاملة';

  @override
  String get transactionSearchLabel => 'بحث في المعاملات';

  @override
  String get transactionFiltersTitle => 'الفلاتر';

  @override
  String get transactionAllTypes => 'كل الأنواع';

  @override
  String get transactionAllCategories => 'كل التصنيفات';

  @override
  String get transactionAllWallets => 'كل المحافظ';

  @override
  String get transactionClearFilters => 'مسح الفلاتر';

  @override
  String get transactionDateRange => 'نطاق التاريخ';

  @override
  String get transactionMinAmount => 'أقل مبلغ';

  @override
  String get transactionMaxAmount => 'أكبر مبلغ';

  @override
  String get transactionWithPersonName => 'بها اسم شخص';

  @override
  String get transactionWithNotes => 'بها ملاحظات';

  @override
  String get transactionNoMatchesTitle => 'لا توجد معاملات مطابقة';

  @override
  String get transactionNoMatchesBody =>
      'عدّل البحث أو الفلاتر لعرض نتائج أكثر.';

  @override
  String get transactionDateLabel => 'التاريخ';

  @override
  String get transactionCreatedAtLabel => 'تاريخ الإضافة';

  @override
  String get transactionUpdatedAtLabel => 'آخر تحديث';

  @override
  String get unknownCategory => 'تصنيف غير معروف';

  @override
  String get dashboardStartHint => 'اضغط إضافة لتسجيل أول مصروف.';

  @override
  String get dashboardSummaryTitle => 'ملخص المصاريف';

  @override
  String get dashboardRecentTransactionsTitle => 'آخر المعاملات';

  @override
  String get summaryToday => 'اليوم';

  @override
  String get summaryWeek => 'الأسبوع';

  @override
  String get summaryMonth => 'الشهر';

  @override
  String get summaryExpense => 'مصروف';

  @override
  String get summaryIncome => 'دخل';

  @override
  String summaryNet(Object amount) {
    return 'الصافي $amount';
  }

  @override
  String get historyStartHint => 'ابدأ من زر إضافة بالأسفل.';

  @override
  String get historyTitle => 'السجل';

  @override
  String get reportsStartHint => 'سجل مصروفًا واحدًا لترى التوزيع.';

  @override
  String get reportsTitle => 'تقرير المصروفات';

  @override
  String reportsTotalExpense(Object amount) {
    return 'إجمالي المصروفات $amount';
  }

  @override
  String reportsTotalIncome(Object amount) {
    return 'إجمالي الدخل $amount';
  }

  @override
  String reportsNetBalance(Object amount) {
    return 'الصافي $amount';
  }

  @override
  String reportsTransactionCount(Object count) {
    return '$count معاملة';
  }

  @override
  String reportsAverageDailyExpense(Object amount) {
    return 'متوسط اليوم $amount';
  }

  @override
  String reportsHighestExpense(Object amount) {
    return 'أكبر مصروف $amount';
  }

  @override
  String reportsHighestCategory(Object amount, Object categoryName) {
    return 'أعلى تصنيف $categoryName · $amount';
  }

  @override
  String get reportsNoHighestExpense => 'لا توجد معاملة مصروف';

  @override
  String get reportsComparisonTitle => 'مقارنة بالفترة السابقة';

  @override
  String reportsComparisonExpenseChange(Object amount, Object percentage) {
    return '$amount ($percentage%)';
  }

  @override
  String reportsExpenseRatio(Object percentage) {
    return '$percentage% من المصروفات';
  }

  @override
  String get reportsPeriodToday => 'اليوم';

  @override
  String get reportsPeriodThisWeek => 'هذا الأسبوع';

  @override
  String get reportsPeriodThisMonth => 'هذا الشهر';

  @override
  String get reportsPeriodPreviousMonth => 'الشهر السابق';

  @override
  String get reportsPeriodCustom => 'مخصص';

  @override
  String reportsDateRange(Object endDate, Object startDate) {
    return '$startDate - $endDate';
  }

  @override
  String get reportsFiltersTitle => 'الفلاتر';

  @override
  String get reportsCategoryFilter => 'التصنيف';

  @override
  String get reportsWalletFilter => 'المحفظة';

  @override
  String get reportsTypeFilter => 'النوع';

  @override
  String get reportsAllCategories => 'كل التصنيفات';

  @override
  String get reportsAllWallets => 'كل المحافظ';

  @override
  String get reportsAllTypes => 'الدخل والمصروفات';

  @override
  String get reportsClearFilters => 'مسح الفلاتر';

  @override
  String get reportsCustomRangeAction => 'اختيار الفترة';

  @override
  String get reportsDistributionTitle => 'توزيع المصروفات';

  @override
  String get reportsTrendTitle => 'الاتجاه عبر الوقت';

  @override
  String get reportsIncomeVsExpenseTitle => 'الدخل مقابل المصروفات';

  @override
  String get reportsNoChartData => 'لا توجد بيانات رسم للفلاتر المحددة';

  @override
  String get reportsLoadError => 'تعذر تحميل التقارير';

  @override
  String get reportsExportMenu => 'تصدير';

  @override
  String get exportReportPdf => 'تصدير التقرير PDF';

  @override
  String get exportTransactionsExcel => 'تصدير المعاملات Excel';

  @override
  String exportSavedMessage(Object path) {
    return 'تم حفظ التصدير في $path';
  }

  @override
  String get exportFailedMessage => 'تعذر التصدير';

  @override
  String get settingsDataManagementTitle => 'إدارة البيانات';

  @override
  String get settingsExportBackupTitle => 'تصدير نسخة احتياطية';

  @override
  String get settingsExportBackupSubtitle => 'احفظ نسخة JSON محلية لهذا الجهاز';

  @override
  String get settingsImportBackupTitle => 'استيراد نسخة احتياطية';

  @override
  String get settingsImportBackupSubtitle => 'استعد البيانات من ملف نسخة محلي';

  @override
  String get settingsExportAllTransactionsTitle => 'تصدير كل المعاملات';

  @override
  String get settingsExportAllTransactionsSubtitle =>
      'احفظ كل المعاملات في ملف Excel';

  @override
  String get settingsExportCurrentReportTitle => 'تصدير تقرير الشهر الحالي';

  @override
  String get settingsExportCurrentReportSubtitle => 'شارك ملخص PDF لهذا الشهر';

  @override
  String get settingsDeleteAllDataTitle => 'حذف كل البيانات المحلية';

  @override
  String get settingsDeleteAllDataSubtitle =>
      'مسح المعاملات والميزانيات والمحافظ وإعادة ضبط الإعدادات';

  @override
  String get settingsStoragePrivacyNote =>
      'النسخ الاحتياطية تحت تحكمك. لا تتضمن مفاتيح التشفير أو PIN أو البيانات الحيوية أو سجلات التشخيص أو معرفات الجهاز.';

  @override
  String get privacySecuritySectionTitle => 'الخصوصية والأمان';

  @override
  String get hideFinancialAmountsTitle => 'إخفاء المبالغ المالية';

  @override
  String get hideFinancialAmountsSubtitle =>
      'إخفاء الأرصدة والإجماليات ومبالغ المعاملات حتى إظهارها';

  @override
  String get showAmountsTooltip => 'إظهار المبالغ';

  @override
  String get hideAmountsTooltip => 'إخفاء المبالغ';

  @override
  String get appLockEnableTitle => 'تفعيل قفل التطبيق';

  @override
  String get appLockEnableSubtitle => 'طلب PIN عند فتح مصروفي';

  @override
  String get appLockChangePinTitle => 'تغيير PIN قفل التطبيق';

  @override
  String get appLockChangePinSubtitle => 'تحقق من PIN الحالي قبل تغييره';

  @override
  String get appLockDisableTitle => 'تعطيل قفل التطبيق';

  @override
  String get appLockDisableSubtitle => 'تحقق من PIN الحالي قبل تعطيل الحماية';

  @override
  String get appLockPinLabel => 'PIN';

  @override
  String get appLockCurrentPinLabel => 'PIN الحالي';

  @override
  String get appLockConfirmPinLabel => 'تأكيد PIN';

  @override
  String get appLockPinHelper => 'استخدم من 4 إلى 8 أرقام';

  @override
  String get appLockEnabledMessage => 'تم تفعيل قفل التطبيق';

  @override
  String get appLockDisabledMessage => 'تم تعطيل قفل التطبيق';

  @override
  String get appLockPinChangedMessage => 'تم تغيير PIN';

  @override
  String get appLockOperationFailed => 'تعذر تعديل قفل التطبيق';

  @override
  String get appLockUnlockTitle => 'مصروفي مقفل';

  @override
  String get appLockUnlockBody => 'أدخل PIN للمتابعة.';

  @override
  String get appLockUnlockAction => 'فتح';

  @override
  String get appLockIncorrectPin => 'PIN غير صحيح';

  @override
  String get appLockLockedOutMessage => 'محاولات كثيرة جدًا. حاول لاحقًا.';

  @override
  String get localPrivacyExplanation =>
      'يحفظ مصروفي البيانات محليًا على هذا الجهاز ولا يحتوي حاليًا على مزامنة خلفية. النسخ الاحتياطية التي تنشئها تحت تحكمك. إزالة التطبيق قد تزيل البيانات المحلية إذا لم تكن هناك نسخة احتياطية، كما أن الوصول على مستوى الجهاز قد يؤثر على الخصوصية.';

  @override
  String get backupPathLabel => 'مسار ملف النسخة الاحتياطية';

  @override
  String get backupImportDialogTitle => 'استيراد نسخة احتياطية';

  @override
  String get backupImportModeLabel => 'طريقة الاستعادة';

  @override
  String get backupImportMerge => 'دمج';

  @override
  String get backupImportReplace => 'استبدال';

  @override
  String get backupImportReplaceWarning =>
      'الاستبدال يمسح البيانات المحلية الحالية بعد التحقق من النسخة. يتم إنشاء لقطة رجوع أولًا.';

  @override
  String get backupImportAction => 'استيراد';

  @override
  String get backupImportSuccess => 'تم استيراد النسخة الاحتياطية';

  @override
  String get backupImportFailed => 'تعذر استيراد النسخة الاحتياطية';

  @override
  String get deleteAllDataDialogTitle => 'حذف البيانات المحلية؟';

  @override
  String get deleteAllDataDialogBody =>
      'سيتم مسح المعاملات والميزانيات وأرصدة المحافظ والإعدادات المحلية. ستتم استعادة التصنيفات الافتراضية المطلوبة.';

  @override
  String get deleteAllDataConfirmHint => 'اكتب DELETE للتأكيد';

  @override
  String get deleteAllDataFailed => 'تعذر حذف البيانات المحلية';

  @override
  String get deleteAllDataSuccess => 'تم حذف البيانات المحلية';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get currencySymbol => 'ج.م';

  @override
  String get settingsWalletBalancesTitle => 'أرصدة المحافظ';

  @override
  String get settingsWalletBalancesSubtitle =>
      'متابعة رصيد إنستاباي وفودافون كاش';

  @override
  String get walletBalancesTitle => 'أرصدة المحافظ';

  @override
  String get walletBalancesIntro =>
      'سجل رصيدك الحالي مرة واحدة. أي دخل أو مصروف لاحق على نفس المحفظة سيحدث الرصيد تلقائيًا.';

  @override
  String get walletBalanceEditAction => 'تعديل';

  @override
  String walletTransactionNet(Object amount) {
    return 'صافي المعاملات: $amount';
  }

  @override
  String walletBalanceDialogTitle(Object walletName) {
    return 'رصيد $walletName';
  }

  @override
  String get walletCurrentBalanceLabel => 'الرصيد الحالي';

  @override
  String get walletCurrentBalanceRequired => 'أدخل رصيدًا صحيحًا';

  @override
  String get walletBalanceSavedMessage => 'تم حفظ رصيد المحفظة';

  @override
  String get walletBalancesLoadError => 'تعذر تحميل أرصدة المحافظ';

  @override
  String get settingsCategoriesTitle => 'تصنيفات المعاملات';

  @override
  String get settingsCategoriesSubtitle =>
      'إدارة التصنيفات الافتراضية والمخصصة';

  @override
  String get categoriesTitle => 'التصنيفات';

  @override
  String get categoriesIntro =>
      'تحكّم في التصنيفات الظاهرة وحدد المحفظة الافتراضية لكل تصنيف.';

  @override
  String get transactionTypeExpense => 'صادر';

  @override
  String get transactionTypeIncome => 'وارد';

  @override
  String get defaultCategoriesSection => 'التصنيفات الافتراضية';

  @override
  String get customCategoriesSection => 'تصنيفاتك';

  @override
  String get addCategory => 'إضافة تصنيف';

  @override
  String get editCategory => 'تعديل التصنيف';

  @override
  String get categoryNameLabel => 'اسم التصنيف';

  @override
  String get categoryIconLabel => 'الأيقونة';

  @override
  String get categoryColorLabel => 'اللون';

  @override
  String get categoryDefaultWalletLabel => 'المحفظة الافتراضية';

  @override
  String categoryDefaultWalletValue(String walletName) {
    return 'المحفظة الافتراضية: $walletName';
  }

  @override
  String get categoryNoDefaultWallet => 'بدون محفظة افتراضية';

  @override
  String get changeDefaultWallet => 'تغيير المحفظة الافتراضية';

  @override
  String get categoryHidden => 'مخفي';

  @override
  String showCategoryLabel(String categoryName) {
    return 'إظهار $categoryName';
  }

  @override
  String hideCategoryLabel(String categoryName) {
    return 'إخفاء $categoryName';
  }

  @override
  String editCategoryLabel(String categoryName) {
    return 'تعديل $categoryName';
  }

  @override
  String categoryIconOptionLabel(int index) {
    return 'خيار الأيقونة $index';
  }

  @override
  String categoryColorOptionLabel(int index) {
    return 'خيار اللون $index';
  }

  @override
  String get noCustomCategoriesTitle => 'لا توجد تصنيفات مخصصة';

  @override
  String get noCustomCategoriesBody =>
      'أضف تصنيفًا يناسب طريقة متابعتك لأموالك.';

  @override
  String get noCategoriesTitle => 'لا توجد تصنيفات هنا بعد';

  @override
  String get noCategoriesBody => 'أضف تصنيفًا مخصصًا للبدء.';

  @override
  String get categoryNameRequired => 'أدخل اسم التصنيف';

  @override
  String get categoryNameAlreadyExists => 'يوجد تصنيف بهذا الاسم بالفعل';

  @override
  String get categoryCreatedMessage => 'تمت إضافة التصنيف';

  @override
  String get categoryUpdatedMessage => 'تم تحديث التصنيف';

  @override
  String get categoriesLoadError => 'تعذر تحميل التصنيفات';

  @override
  String get categoriesSaveError => 'تعذر حفظ التغييرات';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get walletCash => 'الكاش';

  @override
  String get walletInstaPay => 'إنستاباي';

  @override
  String get walletVodafoneCash => 'فودافون كاش';

  @override
  String get categoryExpenseFoodAndDrink => 'أكل وشرب';

  @override
  String get categoryExpenseCafesRestaurants => 'كافيهات ومطاعم';

  @override
  String get categoryExpenseTransport => 'نقل ومواصلات';

  @override
  String get categoryExpenseClothing => 'ملابس';

  @override
  String get categoryExpenseHealthcare => 'علاج وأدوية';

  @override
  String get categoryExpenseHousehold => 'مصاريف منزلية';

  @override
  String get categoryExpenseExtra => 'مصاريف إضافية';

  @override
  String get categoryExpensePersonTransfer => 'تحويلات لأشخاص';

  @override
  String get categoryExpensePersonalCare => 'حلاقة وعناية شخصية';

  @override
  String get categoryExpenseSubscriptions => 'اشتراكات';

  @override
  String get categoryExpenseEntertainment => 'ترفيه وخروجات';

  @override
  String get categoryExpenseOther => 'أخرى';

  @override
  String get categoryIncomeSalary => 'راتب';

  @override
  String get categoryIncomeFreelance => 'عمل حر';

  @override
  String get categoryIncomeOther => 'دخل آخر';

  @override
  String get notFoundTitle => 'تعذر فتح الصفحة';

  @override
  String get notFoundBody => 'الوجهة المطلوبة غير متاحة.';
}
