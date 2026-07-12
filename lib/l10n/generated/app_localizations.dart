import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name.
  ///
  /// In ar, this message translates to:
  /// **'مصروفي'**
  String get appName;

  /// Dashboard navigation tab label.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get dashboardTab;

  /// History navigation tab label.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get historyTab;

  /// Reports navigation tab label.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reportsTab;

  /// Budgets navigation tab label.
  ///
  /// In ar, this message translates to:
  /// **'الميزانيات'**
  String get budgetsTab;

  /// Settings navigation tab label.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTab;

  /// Dashboard empty state title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات حتى الآن'**
  String get dashboardEmptyTitle;

  /// Dashboard empty state body.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر ملخصات اليوم والأسبوع والشهر هنا.'**
  String get dashboardEmptyBody;

  /// History empty state title.
  ///
  /// In ar, this message translates to:
  /// **'السجل فارغ'**
  String get historyEmptyTitle;

  /// History empty state body.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر المعاملات مرتبة حسب التاريخ.'**
  String get historyEmptyBody;

  /// Reports empty state title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للتقارير'**
  String get reportsEmptyTitle;

  /// Reports empty state body.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الرسوم البيانية بعد تسجيل معاملات.'**
  String get reportsEmptyBody;

  /// Budgets empty state title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ميزانيات'**
  String get budgetsEmptyTitle;

  /// Budgets empty state body.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الميزانيات الشهرية لكل تصنيف هنا.'**
  String get budgetsEmptyBody;

  /// No description provided for @budget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية'**
  String get budget;

  /// No description provided for @addBudget.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ميزانية'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الميزانية'**
  String get editBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In ar, this message translates to:
  /// **'حذف الميزانية'**
  String get deleteBudget;

  /// No description provided for @monthlyBudget.
  ///
  /// In ar, this message translates to:
  /// **'ميزانية شهرية'**
  String get monthlyBudget;

  /// No description provided for @budgetMonthLabel.
  ///
  /// In ar, this message translates to:
  /// **'{month}'**
  String budgetMonthLabel(Object month);

  /// No description provided for @budgetPreviousMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر السابق'**
  String get budgetPreviousMonth;

  /// No description provided for @budgetNextMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر التالي'**
  String get budgetNextMonth;

  /// No description provided for @budgetCategoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get budgetCategoryLabel;

  /// No description provided for @budgetCategoryRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيف'**
  String get budgetCategoryRequired;

  /// No description provided for @budgetAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الميزانية'**
  String get budgetAmountLabel;

  /// No description provided for @budgetAmountRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغ ميزانية أكبر من صفر'**
  String get budgetAmountRequired;

  /// No description provided for @budgetNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get budgetNoteLabel;

  /// No description provided for @budgetSpent.
  ///
  /// In ar, this message translates to:
  /// **'المصروف'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get budgetRemaining;

  /// No description provided for @budgetExceeded.
  ///
  /// In ar, this message translates to:
  /// **'تم تجاوز الميزانية'**
  String get budgetExceeded;

  /// No description provided for @budgetApproachingLimit.
  ///
  /// In ar, this message translates to:
  /// **'قريب من الحد'**
  String get budgetApproachingLimit;

  /// No description provided for @budgetSafe.
  ///
  /// In ar, this message translates to:
  /// **'ضمن الحد'**
  String get budgetSafe;

  /// No description provided for @budgetSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الميزانية'**
  String get budgetSavedMessage;

  /// No description provided for @budgetDeletedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الميزانية'**
  String get budgetDeletedMessage;

  /// No description provided for @budgetsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الميزانيات'**
  String get budgetsLoadError;

  /// No description provided for @budgetsLoadErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث بيانات الميزانيات. حاول مرة أخرى.'**
  String get budgetsLoadErrorBody;

  /// No description provided for @budgetDuplicateValidation.
  ///
  /// In ar, this message translates to:
  /// **'يوجد ميزانية لهذا التصنيف في الشهر المحدد بالفعل'**
  String get budgetDuplicateValidation;

  /// No description provided for @budgetExpenseCategoryValidation.
  ///
  /// In ar, this message translates to:
  /// **'اختر تصنيف مصروف متاح'**
  String get budgetExpenseCategoryValidation;

  /// No description provided for @budgetNoExpenseCategories.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات مصروفات متاحة'**
  String get budgetNoExpenseCategories;

  /// No description provided for @budgetHiddenCategory.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف مخفي'**
  String get budgetHiddenCategory;

  /// No description provided for @budgetCategoryUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف غير متاح'**
  String get budgetCategoryUnavailable;

  /// No description provided for @budgetDeleteConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف ميزانية {categoryName}؟'**
  String budgetDeleteConfirmation(Object categoryName);

  /// No description provided for @budgetProgressSemantics.
  ///
  /// In ar, this message translates to:
  /// **'تم استخدام {percentage}% من ميزانية {categoryName}'**
  String budgetProgressSemantics(Object categoryName, Object percentage);

  /// Startup loading title.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تشغيل مصروفي'**
  String get startupLoadingTitle;

  /// Startup loading body.
  ///
  /// In ar, this message translates to:
  /// **'يتم تجهيز بياناتك المحلية بأمان.'**
  String get startupLoadingBody;

  /// Startup failure title.
  ///
  /// In ar, this message translates to:
  /// **'تعذر بدء التطبيق'**
  String get startupFailureTitle;

  /// Startup failure body.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء إعداد البيانات المحلية. حاول مرة أخرى.'**
  String get startupFailureBody;

  /// Settings screen title.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @languageSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageSectionTitle;

  /// No description provided for @themeSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get themeSectionTitle;

  /// System theme mode label.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeModeDark;

  /// Arabic language label.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get languageEnglish;

  /// No description provided for @addTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get addTransaction;

  /// No description provided for @addTransactionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة معاملة'**
  String get addTransactionTitle;

  /// No description provided for @editTransactionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المعاملة'**
  String get editTransactionTitle;

  /// No description provided for @saveTransaction.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المعاملة'**
  String get saveTransaction;

  /// No description provided for @updateTransaction.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المعاملة'**
  String get updateTransaction;

  /// No description provided for @transactionSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المعاملة'**
  String get transactionSavedMessage;

  /// No description provided for @transactionUpdatedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المعاملة'**
  String get transactionUpdatedMessage;

  /// No description provided for @transactionTypeExpenseForm.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get transactionTypeExpenseForm;

  /// No description provided for @transactionTypeIncomeForm.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get transactionTypeIncomeForm;

  /// No description provided for @transactionTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get transactionTypeLabel;

  /// No description provided for @transactionAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get transactionAmountLabel;

  /// No description provided for @transactionAmountRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا صحيحًا'**
  String get transactionAmountRequired;

  /// No description provided for @transactionCategoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get transactionCategoryLabel;

  /// No description provided for @transactionCategoryRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيف'**
  String get transactionCategoryRequired;

  /// No description provided for @transactionPersonLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشخص'**
  String get transactionPersonLabel;

  /// No description provided for @transactionWalletLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get transactionWalletLabel;

  /// No description provided for @transactionNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get transactionNoteLabel;

  /// No description provided for @transactionDeleteTooltip.
  ///
  /// In ar, this message translates to:
  /// **'حذف المعاملة'**
  String get transactionDeleteTooltip;

  /// No description provided for @transactionDeleteConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه المعاملة؟'**
  String get transactionDeleteConfirmation;

  /// No description provided for @transactionEditTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المعاملة'**
  String get transactionEditTooltip;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المعاملة'**
  String get transactionDetailsTitle;

  /// No description provided for @transactionSearchLabel.
  ///
  /// In ar, this message translates to:
  /// **'بحث في المعاملات'**
  String get transactionSearchLabel;

  /// No description provided for @transactionFiltersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر'**
  String get transactionFiltersTitle;

  /// No description provided for @transactionAllTypes.
  ///
  /// In ar, this message translates to:
  /// **'كل الأنواع'**
  String get transactionAllTypes;

  /// No description provided for @transactionAllCategories.
  ///
  /// In ar, this message translates to:
  /// **'كل التصنيفات'**
  String get transactionAllCategories;

  /// No description provided for @transactionAllWallets.
  ///
  /// In ar, this message translates to:
  /// **'كل المحافظ'**
  String get transactionAllWallets;

  /// No description provided for @transactionClearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get transactionClearFilters;

  /// No description provided for @transactionDateRange.
  ///
  /// In ar, this message translates to:
  /// **'نطاق التاريخ'**
  String get transactionDateRange;

  /// No description provided for @transactionMinAmount.
  ///
  /// In ar, this message translates to:
  /// **'أقل مبلغ'**
  String get transactionMinAmount;

  /// No description provided for @transactionMaxAmount.
  ///
  /// In ar, this message translates to:
  /// **'أكبر مبلغ'**
  String get transactionMaxAmount;

  /// No description provided for @transactionWithPersonName.
  ///
  /// In ar, this message translates to:
  /// **'بها اسم شخص'**
  String get transactionWithPersonName;

  /// No description provided for @transactionWithNotes.
  ///
  /// In ar, this message translates to:
  /// **'بها ملاحظات'**
  String get transactionWithNotes;

  /// No description provided for @transactionNoMatchesTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات مطابقة'**
  String get transactionNoMatchesTitle;

  /// No description provided for @transactionNoMatchesBody.
  ///
  /// In ar, this message translates to:
  /// **'عدّل البحث أو الفلاتر لعرض نتائج أكثر.'**
  String get transactionNoMatchesBody;

  /// No description provided for @transactionDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get transactionDateLabel;

  /// No description provided for @transactionCreatedAtLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإضافة'**
  String get transactionCreatedAtLabel;

  /// No description provided for @transactionUpdatedAtLabel.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get transactionUpdatedAtLabel;

  /// No description provided for @unknownCategory.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف غير معروف'**
  String get unknownCategory;

  /// No description provided for @dashboardStartHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط إضافة لتسجيل أول مصروف.'**
  String get dashboardStartHint;

  /// No description provided for @dashboardSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المصاريف'**
  String get dashboardSummaryTitle;

  /// No description provided for @dashboardRecentTransactionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر المعاملات'**
  String get dashboardRecentTransactionsTitle;

  /// No description provided for @summaryToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get summaryToday;

  /// No description provided for @summaryWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع'**
  String get summaryWeek;

  /// No description provided for @summaryMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get summaryMonth;

  /// No description provided for @summaryExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get summaryExpense;

  /// No description provided for @summaryIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get summaryIncome;

  /// No description provided for @summaryNet.
  ///
  /// In ar, this message translates to:
  /// **'الصافي {amount}'**
  String summaryNet(Object amount);

  /// No description provided for @historyStartHint.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ من زر إضافة بالأسفل.'**
  String get historyStartHint;

  /// No description provided for @historyTitle.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get historyTitle;

  /// No description provided for @reportsStartHint.
  ///
  /// In ar, this message translates to:
  /// **'سجل مصروفًا واحدًا لترى التوزيع.'**
  String get reportsStartHint;

  /// No description provided for @reportsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المصروفات'**
  String get reportsTitle;

  /// No description provided for @reportsTotalExpense.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروفات {amount}'**
  String reportsTotalExpense(Object amount);

  /// No description provided for @reportsTotalIncome.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الدخل {amount}'**
  String reportsTotalIncome(Object amount);

  /// No description provided for @reportsNetBalance.
  ///
  /// In ar, this message translates to:
  /// **'الصافي {amount}'**
  String reportsNetBalance(Object amount);

  /// No description provided for @reportsTransactionCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} معاملة'**
  String reportsTransactionCount(Object count);

  /// No description provided for @reportsAverageDailyExpense.
  ///
  /// In ar, this message translates to:
  /// **'متوسط اليوم {amount}'**
  String reportsAverageDailyExpense(Object amount);

  /// No description provided for @reportsHighestExpense.
  ///
  /// In ar, this message translates to:
  /// **'أكبر مصروف {amount}'**
  String reportsHighestExpense(Object amount);

  /// No description provided for @reportsHighestCategory.
  ///
  /// In ar, this message translates to:
  /// **'أعلى تصنيف {categoryName} · {amount}'**
  String reportsHighestCategory(Object amount, Object categoryName);

  /// No description provided for @reportsNoHighestExpense.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملة مصروف'**
  String get reportsNoHighestExpense;

  /// No description provided for @reportsComparisonTitle.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة بالفترة السابقة'**
  String get reportsComparisonTitle;

  /// No description provided for @reportsComparisonExpenseChange.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ({percentage}%)'**
  String reportsComparisonExpenseChange(Object amount, Object percentage);

  /// No description provided for @reportsExpenseRatio.
  ///
  /// In ar, this message translates to:
  /// **'{percentage}% من المصروفات'**
  String reportsExpenseRatio(Object percentage);

  /// No description provided for @reportsPeriodToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get reportsPeriodToday;

  /// No description provided for @reportsPeriodThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get reportsPeriodThisWeek;

  /// No description provided for @reportsPeriodThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get reportsPeriodThisMonth;

  /// No description provided for @reportsPeriodPreviousMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر السابق'**
  String get reportsPeriodPreviousMonth;

  /// No description provided for @reportsPeriodCustom.
  ///
  /// In ar, this message translates to:
  /// **'مخصص'**
  String get reportsPeriodCustom;

  /// No description provided for @reportsDateRange.
  ///
  /// In ar, this message translates to:
  /// **'{startDate} - {endDate}'**
  String reportsDateRange(Object endDate, Object startDate);

  /// No description provided for @reportsFiltersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر'**
  String get reportsFiltersTitle;

  /// No description provided for @reportsCategoryFilter.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get reportsCategoryFilter;

  /// No description provided for @reportsWalletFilter.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get reportsWalletFilter;

  /// No description provided for @reportsTypeFilter.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get reportsTypeFilter;

  /// No description provided for @reportsAllCategories.
  ///
  /// In ar, this message translates to:
  /// **'كل التصنيفات'**
  String get reportsAllCategories;

  /// No description provided for @reportsAllWallets.
  ///
  /// In ar, this message translates to:
  /// **'كل المحافظ'**
  String get reportsAllWallets;

  /// No description provided for @reportsAllTypes.
  ///
  /// In ar, this message translates to:
  /// **'الدخل والمصروفات'**
  String get reportsAllTypes;

  /// No description provided for @reportsClearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get reportsClearFilters;

  /// No description provided for @reportsCustomRangeAction.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الفترة'**
  String get reportsCustomRangeAction;

  /// No description provided for @reportsDistributionTitle.
  ///
  /// In ar, this message translates to:
  /// **'توزيع المصروفات'**
  String get reportsDistributionTitle;

  /// No description provided for @reportsTrendTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاتجاه عبر الوقت'**
  String get reportsTrendTitle;

  /// No description provided for @reportsIncomeVsExpenseTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدخل مقابل المصروفات'**
  String get reportsIncomeVsExpenseTitle;

  /// No description provided for @reportsNoChartData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات رسم للفلاتر المحددة'**
  String get reportsNoChartData;

  /// No description provided for @reportsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل التقارير'**
  String get reportsLoadError;

  /// No description provided for @reportsExportMenu.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get reportsExportMenu;

  /// No description provided for @exportReportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقرير PDF'**
  String get exportReportPdf;

  /// No description provided for @exportTransactionsExcel.
  ///
  /// In ar, this message translates to:
  /// **'تصدير المعاملات Excel'**
  String get exportTransactionsExcel;

  /// No description provided for @exportSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التصدير في {path}'**
  String exportSavedMessage(Object path);

  /// No description provided for @exportFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التصدير'**
  String get exportFailedMessage;

  /// No description provided for @settingsDataManagementTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة البيانات'**
  String get settingsDataManagementTitle;

  /// No description provided for @settingsExportBackupTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصدير نسخة احتياطية'**
  String get settingsExportBackupTitle;

  /// No description provided for @settingsExportBackupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'احفظ نسخة JSON محلية لهذا الجهاز'**
  String get settingsExportBackupSubtitle;

  /// No description provided for @settingsImportBackupTitle.
  ///
  /// In ar, this message translates to:
  /// **'استيراد نسخة احتياطية'**
  String get settingsImportBackupTitle;

  /// No description provided for @settingsImportBackupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استعد البيانات من ملف نسخة محلي'**
  String get settingsImportBackupSubtitle;

  /// No description provided for @settingsExportAllTransactionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كل المعاملات'**
  String get settingsExportAllTransactionsTitle;

  /// No description provided for @settingsExportAllTransactionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'احفظ كل المعاملات في ملف Excel'**
  String get settingsExportAllTransactionsSubtitle;

  /// No description provided for @settingsExportCurrentReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصدير تقرير الشهر الحالي'**
  String get settingsExportCurrentReportTitle;

  /// No description provided for @settingsExportCurrentReportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شارك ملخص PDF لهذا الشهر'**
  String get settingsExportCurrentReportSubtitle;

  /// No description provided for @settingsDeleteAllDataTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف كل البيانات المحلية'**
  String get settingsDeleteAllDataTitle;

  /// No description provided for @settingsDeleteAllDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح المعاملات والميزانيات والمحافظ وإعادة ضبط الإعدادات'**
  String get settingsDeleteAllDataSubtitle;

  /// No description provided for @settingsStoragePrivacyNote.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطية تحت تحكمك. لا تتضمن مفاتيح التشفير أو PIN أو البيانات الحيوية أو سجلات التشخيص أو معرفات الجهاز.'**
  String get settingsStoragePrivacyNote;

  /// No description provided for @privacySecuritySectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية والأمان'**
  String get privacySecuritySectionTitle;

  /// No description provided for @hideFinancialAmountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء المبالغ المالية'**
  String get hideFinancialAmountsTitle;

  /// No description provided for @hideFinancialAmountsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الأرصدة والإجماليات ومبالغ المعاملات حتى إظهارها'**
  String get hideFinancialAmountsSubtitle;

  /// No description provided for @showAmountsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إظهار المبالغ'**
  String get showAmountsTooltip;

  /// No description provided for @hideAmountsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء المبالغ'**
  String get hideAmountsTooltip;

  /// No description provided for @appLockEnableTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل قفل التطبيق'**
  String get appLockEnableTitle;

  /// No description provided for @appLockEnableSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب PIN عند فتح مصروفي'**
  String get appLockEnableSubtitle;

  /// No description provided for @appLockChangePinTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير PIN قفل التطبيق'**
  String get appLockChangePinTitle;

  /// No description provided for @appLockChangePinSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من PIN الحالي قبل تغييره'**
  String get appLockChangePinSubtitle;

  /// No description provided for @appLockDisableTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل قفل التطبيق'**
  String get appLockDisableTitle;

  /// No description provided for @appLockDisableSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من PIN الحالي قبل تعطيل الحماية'**
  String get appLockDisableSubtitle;

  /// No description provided for @appLockPinLabel.
  ///
  /// In ar, this message translates to:
  /// **'PIN'**
  String get appLockPinLabel;

  /// No description provided for @appLockCurrentPinLabel.
  ///
  /// In ar, this message translates to:
  /// **'PIN الحالي'**
  String get appLockCurrentPinLabel;

  /// No description provided for @appLockConfirmPinLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد PIN'**
  String get appLockConfirmPinLabel;

  /// No description provided for @appLockPinHelper.
  ///
  /// In ar, this message translates to:
  /// **'استخدم من 4 إلى 8 أرقام'**
  String get appLockPinHelper;

  /// No description provided for @appLockEnabledMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل قفل التطبيق'**
  String get appLockEnabledMessage;

  /// No description provided for @appLockDisabledMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تعطيل قفل التطبيق'**
  String get appLockDisabledMessage;

  /// No description provided for @appLockPinChangedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير PIN'**
  String get appLockPinChangedMessage;

  /// No description provided for @appLockOperationFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تعديل قفل التطبيق'**
  String get appLockOperationFailed;

  /// No description provided for @appLockUnlockTitle.
  ///
  /// In ar, this message translates to:
  /// **'مصروفي مقفل'**
  String get appLockUnlockTitle;

  /// No description provided for @appLockUnlockBody.
  ///
  /// In ar, this message translates to:
  /// **'أدخل PIN للمتابعة.'**
  String get appLockUnlockBody;

  /// No description provided for @appLockUnlockAction.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get appLockUnlockAction;

  /// No description provided for @appLockIncorrectPin.
  ///
  /// In ar, this message translates to:
  /// **'PIN غير صحيح'**
  String get appLockIncorrectPin;

  /// No description provided for @appLockLockedOutMessage.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة جدًا. حاول لاحقًا.'**
  String get appLockLockedOutMessage;

  /// No description provided for @localPrivacyExplanation.
  ///
  /// In ar, this message translates to:
  /// **'يحفظ مصروفي البيانات محليًا على هذا الجهاز ولا يحتوي حاليًا على مزامنة خلفية. النسخ الاحتياطية التي تنشئها تحت تحكمك. إزالة التطبيق قد تزيل البيانات المحلية إذا لم تكن هناك نسخة احتياطية، كما أن الوصول على مستوى الجهاز قد يؤثر على الخصوصية.'**
  String get localPrivacyExplanation;

  /// No description provided for @backupPathLabel.
  ///
  /// In ar, this message translates to:
  /// **'مسار ملف النسخة الاحتياطية'**
  String get backupPathLabel;

  /// No description provided for @backupImportDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'استيراد نسخة احتياطية'**
  String get backupImportDialogTitle;

  /// No description provided for @backupImportModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاستعادة'**
  String get backupImportModeLabel;

  /// No description provided for @backupImportMerge.
  ///
  /// In ar, this message translates to:
  /// **'دمج'**
  String get backupImportMerge;

  /// No description provided for @backupImportReplace.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get backupImportReplace;

  /// No description provided for @backupImportReplaceWarning.
  ///
  /// In ar, this message translates to:
  /// **'الاستبدال يمسح البيانات المحلية الحالية بعد التحقق من النسخة. يتم إنشاء لقطة رجوع أولًا.'**
  String get backupImportReplaceWarning;

  /// No description provided for @backupImportAction.
  ///
  /// In ar, this message translates to:
  /// **'استيراد'**
  String get backupImportAction;

  /// No description provided for @backupImportSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم استيراد النسخة الاحتياطية'**
  String get backupImportSuccess;

  /// No description provided for @backupImportFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر استيراد النسخة الاحتياطية'**
  String get backupImportFailed;

  /// No description provided for @deleteAllDataDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف البيانات المحلية؟'**
  String get deleteAllDataDialogTitle;

  /// No description provided for @deleteAllDataDialogBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم مسح المعاملات والميزانيات وأرصدة المحافظ والإعدادات المحلية. ستتم استعادة التصنيفات الافتراضية المطلوبة.'**
  String get deleteAllDataDialogBody;

  /// No description provided for @deleteAllDataConfirmHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب DELETE للتأكيد'**
  String get deleteAllDataConfirmHint;

  /// No description provided for @deleteAllDataFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف البيانات المحلية'**
  String get deleteAllDataFailed;

  /// No description provided for @deleteAllDataSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف البيانات المحلية'**
  String get deleteAllDataSuccess;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @currencySymbol.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get currencySymbol;

  /// No description provided for @settingsWalletBalancesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرصدة المحافظ'**
  String get settingsWalletBalancesTitle;

  /// No description provided for @settingsWalletBalancesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة رصيد إنستاباي وفودافون كاش'**
  String get settingsWalletBalancesSubtitle;

  /// No description provided for @walletBalancesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرصدة المحافظ'**
  String get walletBalancesTitle;

  /// No description provided for @walletBalancesIntro.
  ///
  /// In ar, this message translates to:
  /// **'سجل رصيدك الحالي مرة واحدة. أي دخل أو مصروف لاحق على نفس المحفظة سيحدث الرصيد تلقائيًا.'**
  String get walletBalancesIntro;

  /// No description provided for @walletBalanceEditAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get walletBalanceEditAction;

  /// No description provided for @walletTransactionNet.
  ///
  /// In ar, this message translates to:
  /// **'صافي المعاملات: {amount}'**
  String walletTransactionNet(Object amount);

  /// No description provided for @walletBalanceDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'رصيد {walletName}'**
  String walletBalanceDialogTitle(Object walletName);

  /// No description provided for @walletCurrentBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get walletCurrentBalanceLabel;

  /// No description provided for @walletCurrentBalanceRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رصيدًا صحيحًا'**
  String get walletCurrentBalanceRequired;

  /// No description provided for @walletBalanceSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ رصيد المحفظة'**
  String get walletBalanceSavedMessage;

  /// No description provided for @walletBalancesLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل أرصدة المحافظ'**
  String get walletBalancesLoadError;

  /// Settings entry title for category management.
  ///
  /// In ar, this message translates to:
  /// **'تصنيفات المعاملات'**
  String get settingsCategoriesTitle;

  /// Settings entry subtitle for category management.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التصنيفات الافتراضية والمخصصة'**
  String get settingsCategoriesSubtitle;

  /// Category management screen title.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get categoriesTitle;

  /// Category management screen introduction.
  ///
  /// In ar, this message translates to:
  /// **'تحكّم في التصنيفات الظاهرة وحدد المحفظة الافتراضية لكل تصنيف.'**
  String get categoriesIntro;

  /// Expense transaction type label.
  ///
  /// In ar, this message translates to:
  /// **'صادر'**
  String get transactionTypeExpense;

  /// Income transaction type label.
  ///
  /// In ar, this message translates to:
  /// **'وارد'**
  String get transactionTypeIncome;

  /// Default categories section heading.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات الافتراضية'**
  String get defaultCategoriesSection;

  /// Custom categories section heading.
  ///
  /// In ar, this message translates to:
  /// **'تصنيفاتك'**
  String get customCategoriesSection;

  /// Add custom category action.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تصنيف'**
  String get addCategory;

  /// Edit custom category form title.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التصنيف'**
  String get editCategory;

  /// Category name field label.
  ///
  /// In ar, this message translates to:
  /// **'اسم التصنيف'**
  String get categoryNameLabel;

  /// Category icon picker label.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get categoryIconLabel;

  /// Category color picker label.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get categoryColorLabel;

  /// Default wallet field label.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة الافتراضية'**
  String get categoryDefaultWalletLabel;

  /// Displays a category's selected default wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة الافتراضية: {walletName}'**
  String categoryDefaultWalletValue(String walletName);

  /// No default wallet option.
  ///
  /// In ar, this message translates to:
  /// **'بدون محفظة افتراضية'**
  String get categoryNoDefaultWallet;

  /// Tooltip for changing a category's default wallet.
  ///
  /// In ar, this message translates to:
  /// **'تغيير المحفظة الافتراضية'**
  String get changeDefaultWallet;

  /// Badge shown on a hidden category.
  ///
  /// In ar, this message translates to:
  /// **'مخفي'**
  String get categoryHidden;

  /// Accessibility label for showing a category.
  ///
  /// In ar, this message translates to:
  /// **'إظهار {categoryName}'**
  String showCategoryLabel(String categoryName);

  /// Accessibility label for hiding a category.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء {categoryName}'**
  String hideCategoryLabel(String categoryName);

  /// Accessibility label for editing a custom category.
  ///
  /// In ar, this message translates to:
  /// **'تعديل {categoryName}'**
  String editCategoryLabel(String categoryName);

  /// Accessibility label for a category icon option.
  ///
  /// In ar, this message translates to:
  /// **'خيار الأيقونة {index}'**
  String categoryIconOptionLabel(int index);

  /// Accessibility label for a category color option.
  ///
  /// In ar, this message translates to:
  /// **'خيار اللون {index}'**
  String categoryColorOptionLabel(int index);

  /// Custom categories empty state title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات مخصصة'**
  String get noCustomCategoriesTitle;

  /// Custom categories empty state body.
  ///
  /// In ar, this message translates to:
  /// **'أضف تصنيفًا يناسب طريقة متابعتك لأموالك.'**
  String get noCustomCategoriesBody;

  /// Empty category type title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات هنا بعد'**
  String get noCategoriesTitle;

  /// Empty category type body.
  ///
  /// In ar, this message translates to:
  /// **'أضف تصنيفًا مخصصًا للبدء.'**
  String get noCategoriesBody;

  /// Required category name validation message.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم التصنيف'**
  String get categoryNameRequired;

  /// Duplicate category name validation message.
  ///
  /// In ar, this message translates to:
  /// **'يوجد تصنيف بهذا الاسم بالفعل'**
  String get categoryNameAlreadyExists;

  /// Confirmation shown after adding a custom category.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة التصنيف'**
  String get categoryCreatedMessage;

  /// Confirmation shown after editing a custom category.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث التصنيف'**
  String get categoryUpdatedMessage;

  /// Category loading error message.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل التصنيفات'**
  String get categoriesLoadError;

  /// Category save error message.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ التغييرات'**
  String get categoriesSaveError;

  /// Generic cancel action.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// Generic save action.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// Generic retry action.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// Cash wallet label.
  ///
  /// In ar, this message translates to:
  /// **'الكاش'**
  String get walletCash;

  /// InstaPay wallet label.
  ///
  /// In ar, this message translates to:
  /// **'إنستاباي'**
  String get walletInstaPay;

  /// Vodafone Cash wallet label.
  ///
  /// In ar, this message translates to:
  /// **'فودافون كاش'**
  String get walletVodafoneCash;

  /// Built-in food and drink expense category.
  ///
  /// In ar, this message translates to:
  /// **'أكل وشرب'**
  String get categoryExpenseFoodAndDrink;

  /// Built-in cafes and restaurants expense category.
  ///
  /// In ar, this message translates to:
  /// **'كافيهات ومطاعم'**
  String get categoryExpenseCafesRestaurants;

  /// Built-in transport expense category.
  ///
  /// In ar, this message translates to:
  /// **'نقل ومواصلات'**
  String get categoryExpenseTransport;

  /// Built-in clothing expense category.
  ///
  /// In ar, this message translates to:
  /// **'ملابس'**
  String get categoryExpenseClothing;

  /// Built-in medical expense category.
  ///
  /// In ar, this message translates to:
  /// **'علاج وأدوية'**
  String get categoryExpenseHealthcare;

  /// Built-in household expense category.
  ///
  /// In ar, this message translates to:
  /// **'مصاريف منزلية'**
  String get categoryExpenseHousehold;

  /// Built-in extra expenses category.
  ///
  /// In ar, this message translates to:
  /// **'مصاريف إضافية'**
  String get categoryExpenseExtra;

  /// Built-in person transfer expense category.
  ///
  /// In ar, this message translates to:
  /// **'تحويلات لأشخاص'**
  String get categoryExpensePersonTransfer;

  /// Built-in personal care expense category.
  ///
  /// In ar, this message translates to:
  /// **'حلاقة وعناية شخصية'**
  String get categoryExpensePersonalCare;

  /// Built-in subscriptions expense category.
  ///
  /// In ar, this message translates to:
  /// **'اشتراكات'**
  String get categoryExpenseSubscriptions;

  /// Built-in entertainment expense category.
  ///
  /// In ar, this message translates to:
  /// **'ترفيه وخروجات'**
  String get categoryExpenseEntertainment;

  /// Built-in other expense category.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get categoryExpenseOther;

  /// Built-in salary income category.
  ///
  /// In ar, this message translates to:
  /// **'راتب'**
  String get categoryIncomeSalary;

  /// Built-in freelance income category.
  ///
  /// In ar, this message translates to:
  /// **'عمل حر'**
  String get categoryIncomeFreelance;

  /// Built-in other income category.
  ///
  /// In ar, this message translates to:
  /// **'دخل آخر'**
  String get categoryIncomeOther;

  /// Route error title.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الصفحة'**
  String get notFoundTitle;

  /// Route error body.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة المطلوبة غير متاحة.'**
  String get notFoundBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
