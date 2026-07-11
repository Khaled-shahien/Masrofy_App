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
  String get saveTransaction => 'حفظ المعاملة';

  @override
  String get transactionSavedMessage => 'تم حفظ المعاملة';

  @override
  String get transactionTypeExpenseForm => 'مصروف';

  @override
  String get transactionTypeIncomeForm => 'دخل';

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
  String reportsExpenseRatio(Object percentage) {
    return '$percentage% من المصروفات';
  }

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
