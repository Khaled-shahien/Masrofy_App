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

  /// No description provided for @saveTransaction.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المعاملة'**
  String get saveTransaction;

  /// No description provided for @transactionSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المعاملة'**
  String get transactionSavedMessage;

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

  /// No description provided for @reportsExpenseRatio.
  ///
  /// In ar, this message translates to:
  /// **'{percentage}% من المصروفات'**
  String reportsExpenseRatio(Object percentage);

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
