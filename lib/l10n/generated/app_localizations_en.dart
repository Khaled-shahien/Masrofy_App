// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Masrofy';

  @override
  String get dashboardTab => 'Home';

  @override
  String get historyTab => 'History';

  @override
  String get reportsTab => 'Reports';

  @override
  String get budgetsTab => 'Budgets';

  @override
  String get settingsTab => 'Settings';

  @override
  String get dashboardEmptyTitle => 'No transactions yet';

  @override
  String get dashboardEmptyBody =>
      'Daily, weekly, and monthly summaries will appear here.';

  @override
  String get historyEmptyTitle => 'History is empty';

  @override
  String get historyEmptyBody => 'Transactions will appear grouped by date.';

  @override
  String get reportsEmptyTitle => 'No report data';

  @override
  String get reportsEmptyBody =>
      'Charts will appear after transactions are recorded.';

  @override
  String get budgetsEmptyTitle => 'No budgets';

  @override
  String get budgetsEmptyBody =>
      'Monthly budgets for each category will appear here.';

  @override
  String get budget => 'Budget';

  @override
  String get addBudget => 'Add budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get deleteBudget => 'Delete budget';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String budgetMonthLabel(Object month) {
    return '$month';
  }

  @override
  String get budgetPreviousMonth => 'Previous month';

  @override
  String get budgetNextMonth => 'Next month';

  @override
  String get budgetCategoryLabel => 'Category';

  @override
  String get budgetCategoryRequired => 'Choose a category';

  @override
  String get budgetAmountLabel => 'Budget amount';

  @override
  String get budgetAmountRequired => 'Enter a budget amount greater than zero';

  @override
  String get budgetNoteLabel => 'Note';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetExceeded => 'Exceeded';

  @override
  String get budgetApproachingLimit => 'Approaching limit';

  @override
  String get budgetSafe => 'On track';

  @override
  String get budgetSavedMessage => 'Budget saved';

  @override
  String get budgetDeletedMessage => 'Budget deleted';

  @override
  String get budgetsLoadError => 'Budgets could not be loaded';

  @override
  String get budgetsLoadErrorBody =>
      'Your budget data could not be refreshed. Try again.';

  @override
  String get budgetDuplicateValidation =>
      'This category already has a budget for the selected month';

  @override
  String get budgetExpenseCategoryValidation =>
      'Choose an available expense category';

  @override
  String get budgetNoExpenseCategories => 'No expense categories are available';

  @override
  String get budgetHiddenCategory => 'Hidden category';

  @override
  String get budgetCategoryUnavailable => 'Unavailable category';

  @override
  String budgetDeleteConfirmation(Object categoryName) {
    return 'Delete the budget for $categoryName?';
  }

  @override
  String budgetProgressSemantics(Object categoryName, Object percentage) {
    return '$categoryName budget is $percentage% used';
  }

  @override
  String get startupLoadingTitle => 'Starting Masrofy';

  @override
  String get startupLoadingBody => 'Your local data is being prepared safely.';

  @override
  String get startupFailureTitle => 'App startup failed';

  @override
  String get startupFailureBody =>
      'There was a problem preparing local data. Try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get themeSectionTitle => 'Appearance';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get addTransaction => 'Add';

  @override
  String get addTransactionTitle => 'Add transaction';

  @override
  String get editTransactionTitle => 'Edit transaction';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get updateTransaction => 'Update transaction';

  @override
  String get transactionSavedMessage => 'Transaction saved';

  @override
  String get transactionUpdatedMessage => 'Transaction updated';

  @override
  String get transactionTypeExpenseForm => 'Expense';

  @override
  String get transactionTypeIncomeForm => 'Income';

  @override
  String get transactionTypeLabel => 'Type';

  @override
  String get transactionAmountLabel => 'Amount';

  @override
  String get transactionAmountRequired => 'Enter a valid amount';

  @override
  String get transactionCategoryLabel => 'Category';

  @override
  String get transactionCategoryRequired => 'Choose a category';

  @override
  String get transactionPersonLabel => 'Person name';

  @override
  String get transactionWalletLabel => 'Wallet';

  @override
  String get transactionNoteLabel => 'Note';

  @override
  String get transactionDeleteTooltip => 'Delete transaction';

  @override
  String get transactionEditTooltip => 'Edit transaction';

  @override
  String get transactionDetailsTitle => 'Transaction details';

  @override
  String get transactionSearchLabel => 'Search transactions';

  @override
  String get transactionFiltersTitle => 'Filters';

  @override
  String get transactionAllTypes => 'All types';

  @override
  String get transactionAllCategories => 'All categories';

  @override
  String get transactionAllWallets => 'All wallets';

  @override
  String get transactionClearFilters => 'Clear filters';

  @override
  String get transactionDateRange => 'Date range';

  @override
  String get transactionMinAmount => 'Min amount';

  @override
  String get transactionMaxAmount => 'Max amount';

  @override
  String get transactionWithPersonName => 'Has person name';

  @override
  String get transactionWithNotes => 'Has notes';

  @override
  String get transactionNoMatchesTitle => 'No matching transactions';

  @override
  String get transactionNoMatchesBody =>
      'Adjust search or filters to see more results.';

  @override
  String get transactionDateLabel => 'Date';

  @override
  String get transactionCreatedAtLabel => 'Created';

  @override
  String get transactionUpdatedAtLabel => 'Updated';

  @override
  String get unknownCategory => 'Unknown category';

  @override
  String get dashboardStartHint => 'Tap Add to record your first expense.';

  @override
  String get dashboardSummaryTitle => 'Spending summary';

  @override
  String get dashboardRecentTransactionsTitle => 'Recent transactions';

  @override
  String get summaryToday => 'Today';

  @override
  String get summaryWeek => 'Week';

  @override
  String get summaryMonth => 'Month';

  @override
  String get summaryExpense => 'Expense';

  @override
  String get summaryIncome => 'Income';

  @override
  String summaryNet(Object amount) {
    return 'Net $amount';
  }

  @override
  String get historyStartHint => 'Start from the Add button at the bottom.';

  @override
  String get historyTitle => 'History';

  @override
  String get reportsStartHint => 'Record one expense to see the distribution.';

  @override
  String get reportsTitle => 'Spending report';

  @override
  String reportsTotalExpense(Object amount) {
    return 'Total expenses $amount';
  }

  @override
  String reportsTotalIncome(Object amount) {
    return 'Total income $amount';
  }

  @override
  String reportsNetBalance(Object amount) {
    return 'Net balance $amount';
  }

  @override
  String reportsTransactionCount(Object count) {
    return '$count transactions';
  }

  @override
  String reportsAverageDailyExpense(Object amount) {
    return 'Daily average $amount';
  }

  @override
  String reportsHighestExpense(Object amount) {
    return 'Highest expense $amount';
  }

  @override
  String reportsHighestCategory(Object amount, Object categoryName) {
    return 'Top category $categoryName · $amount';
  }

  @override
  String get reportsNoHighestExpense => 'No expense transaction';

  @override
  String get reportsComparisonTitle => 'Compared with previous period';

  @override
  String reportsComparisonExpenseChange(Object amount, Object percentage) {
    return '$amount ($percentage%)';
  }

  @override
  String reportsExpenseRatio(Object percentage) {
    return '$percentage% of expenses';
  }

  @override
  String get reportsPeriodToday => 'Today';

  @override
  String get reportsPeriodThisWeek => 'This week';

  @override
  String get reportsPeriodThisMonth => 'This month';

  @override
  String get reportsPeriodPreviousMonth => 'Previous month';

  @override
  String get reportsPeriodCustom => 'Custom';

  @override
  String reportsDateRange(Object endDate, Object startDate) {
    return '$startDate - $endDate';
  }

  @override
  String get reportsFiltersTitle => 'Filters';

  @override
  String get reportsCategoryFilter => 'Category';

  @override
  String get reportsWalletFilter => 'Wallet';

  @override
  String get reportsTypeFilter => 'Type';

  @override
  String get reportsAllCategories => 'All categories';

  @override
  String get reportsAllWallets => 'All wallets';

  @override
  String get reportsAllTypes => 'Income and expenses';

  @override
  String get reportsClearFilters => 'Clear filters';

  @override
  String get reportsCustomRangeAction => 'Choose range';

  @override
  String get reportsDistributionTitle => 'Expense distribution';

  @override
  String get reportsTrendTitle => 'Trend over time';

  @override
  String get reportsIncomeVsExpenseTitle => 'Income vs expenses';

  @override
  String get reportsNoChartData => 'No chart data for the selected filters';

  @override
  String get reportsLoadError => 'Reports could not be loaded';

  @override
  String get reportsExportMenu => 'Export';

  @override
  String get exportReportPdf => 'Export report PDF';

  @override
  String get exportTransactionsExcel => 'Export transactions Excel';

  @override
  String exportSavedMessage(Object path) {
    return 'Export saved to $path';
  }

  @override
  String get exportFailedMessage => 'Export failed';

  @override
  String get settingsDataManagementTitle => 'Data management';

  @override
  String get settingsExportBackupTitle => 'Export backup';

  @override
  String get settingsExportBackupSubtitle =>
      'Save a local JSON backup for this device';

  @override
  String get settingsImportBackupTitle => 'Import backup';

  @override
  String get settingsImportBackupSubtitle => 'Restore from a local backup file';

  @override
  String get settingsExportAllTransactionsTitle => 'Export all transactions';

  @override
  String get settingsExportAllTransactionsSubtitle =>
      'Save every transaction as an Excel file';

  @override
  String get settingsExportCurrentReportTitle => 'Export current month report';

  @override
  String get settingsExportCurrentReportSubtitle =>
      'Share a PDF summary for this month';

  @override
  String get settingsDeleteAllDataTitle => 'Delete all local data';

  @override
  String get settingsDeleteAllDataSubtitle =>
      'Clear transactions, budgets, wallets, and reset settings';

  @override
  String get settingsStoragePrivacyNote =>
      'Backups stay under your control. They do not include encryption keys, PINs, biometric data, debug logs, or device identifiers.';

  @override
  String get privacySecuritySectionTitle => 'Privacy and security';

  @override
  String get hideFinancialAmountsTitle => 'Hide financial amounts';

  @override
  String get hideFinancialAmountsSubtitle =>
      'Mask balances, totals, and transaction amounts until revealed';

  @override
  String get showAmountsTooltip => 'Reveal amounts';

  @override
  String get hideAmountsTooltip => 'Hide amounts';

  @override
  String get appLockEnableTitle => 'Enable app lock';

  @override
  String get appLockEnableSubtitle => 'Require a PIN when opening Masrofy';

  @override
  String get appLockChangePinTitle => 'Change app lock PIN';

  @override
  String get appLockChangePinSubtitle =>
      'Verify the current PIN before changing it';

  @override
  String get appLockDisableTitle => 'Disable app lock';

  @override
  String get appLockDisableSubtitle =>
      'Verify the current PIN before disabling protection';

  @override
  String get appLockPinLabel => 'PIN';

  @override
  String get appLockCurrentPinLabel => 'Current PIN';

  @override
  String get appLockConfirmPinLabel => 'Confirm PIN';

  @override
  String get appLockPinHelper => 'Use 4 to 8 digits';

  @override
  String get appLockEnabledMessage => 'App lock enabled';

  @override
  String get appLockDisabledMessage => 'App lock disabled';

  @override
  String get appLockPinChangedMessage => 'PIN changed';

  @override
  String get appLockOperationFailed => 'App lock change failed';

  @override
  String get appLockUnlockTitle => 'Masrofy is locked';

  @override
  String get appLockUnlockBody => 'Enter your PIN to continue.';

  @override
  String get appLockUnlockAction => 'Unlock';

  @override
  String get appLockIncorrectPin => 'Incorrect PIN';

  @override
  String get appLockLockedOutMessage => 'Too many attempts. Try again later.';

  @override
  String get localPrivacyExplanation =>
      'Masrofy stores data locally on this device and currently has no backend sync. User-created backups stay under your control. Removing the app may remove local data if no backup exists, and device-level access can still affect privacy.';

  @override
  String get backupPathLabel => 'Backup file path';

  @override
  String get backupImportDialogTitle => 'Import backup';

  @override
  String get backupImportModeLabel => 'Restore mode';

  @override
  String get backupImportMerge => 'Merge';

  @override
  String get backupImportReplace => 'Replace';

  @override
  String get backupImportReplaceWarning =>
      'Replace clears current local data after the backup is validated. A rollback snapshot is created first.';

  @override
  String get backupImportAction => 'Import';

  @override
  String get backupImportSuccess => 'Backup imported';

  @override
  String get backupImportFailed => 'Backup could not be imported';

  @override
  String get deleteAllDataDialogTitle => 'Delete local data?';

  @override
  String get deleteAllDataDialogBody =>
      'This clears local transactions, budgets, wallet balances, and settings. Required default categories will be restored.';

  @override
  String get deleteAllDataConfirmHint => 'Type DELETE to confirm';

  @override
  String get deleteAllDataFailed => 'Local data could not be deleted';

  @override
  String get deleteAllDataSuccess => 'Local data deleted';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get currencySymbol => 'EGP';

  @override
  String get settingsWalletBalancesTitle => 'Wallet balances';

  @override
  String get settingsWalletBalancesSubtitle =>
      'Track InstaPay and Vodafone Cash balances';

  @override
  String get walletBalancesTitle => 'Wallet balances';

  @override
  String get walletBalancesIntro =>
      'Set your current balance once. Future income and expenses recorded on each wallet will update it automatically.';

  @override
  String get walletBalanceEditAction => 'Edit';

  @override
  String walletTransactionNet(Object amount) {
    return 'Transactions net: $amount';
  }

  @override
  String walletBalanceDialogTitle(Object walletName) {
    return '$walletName balance';
  }

  @override
  String get walletCurrentBalanceLabel => 'Current balance';

  @override
  String get walletCurrentBalanceRequired => 'Enter a valid balance';

  @override
  String get walletBalanceSavedMessage => 'Wallet balance saved';

  @override
  String get walletBalancesLoadError => 'Wallet balances could not be loaded';

  @override
  String get settingsCategoriesTitle => 'Transaction categories';

  @override
  String get settingsCategoriesSubtitle =>
      'Manage default and custom categories';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesIntro =>
      'Choose which categories are visible and set a default wallet for each one.';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get defaultCategoriesSection => 'Default categories';

  @override
  String get customCategoriesSection => 'Your categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get categoryIconLabel => 'Icon';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get categoryDefaultWalletLabel => 'Default wallet';

  @override
  String categoryDefaultWalletValue(String walletName) {
    return 'Default wallet: $walletName';
  }

  @override
  String get categoryNoDefaultWallet => 'No default wallet';

  @override
  String get changeDefaultWallet => 'Change default wallet';

  @override
  String get categoryHidden => 'Hidden';

  @override
  String showCategoryLabel(String categoryName) {
    return 'Show $categoryName';
  }

  @override
  String hideCategoryLabel(String categoryName) {
    return 'Hide $categoryName';
  }

  @override
  String editCategoryLabel(String categoryName) {
    return 'Edit $categoryName';
  }

  @override
  String categoryIconOptionLabel(int index) {
    return 'Icon option $index';
  }

  @override
  String categoryColorOptionLabel(int index) {
    return 'Color option $index';
  }

  @override
  String get noCustomCategoriesTitle => 'No custom categories';

  @override
  String get noCustomCategoriesBody =>
      'Add a category that matches the way you track your money.';

  @override
  String get noCategoriesTitle => 'No categories here yet';

  @override
  String get noCategoriesBody => 'Add a custom category to get started.';

  @override
  String get categoryNameRequired => 'Enter a category name';

  @override
  String get categoryNameAlreadyExists =>
      'A category with this name already exists';

  @override
  String get categoryCreatedMessage => 'Category added';

  @override
  String get categoryUpdatedMessage => 'Category updated';

  @override
  String get categoriesLoadError => 'Categories could not be loaded';

  @override
  String get categoriesSaveError => 'Changes could not be saved';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Try again';

  @override
  String get walletCash => 'Cash';

  @override
  String get walletInstaPay => 'InstaPay';

  @override
  String get walletVodafoneCash => 'Vodafone Cash';

  @override
  String get categoryExpenseFoodAndDrink => 'Food & drink';

  @override
  String get categoryExpenseCafesRestaurants => 'Cafés & restaurants';

  @override
  String get categoryExpenseTransport => 'Transport';

  @override
  String get categoryExpenseClothing => 'Clothing';

  @override
  String get categoryExpenseHealthcare => 'Medical & pharmacy';

  @override
  String get categoryExpenseHousehold => 'Household expenses';

  @override
  String get categoryExpenseExtra => 'Extra expenses';

  @override
  String get categoryExpensePersonTransfer => 'Transfers to people';

  @override
  String get categoryExpensePersonalCare => 'Haircuts & personal care';

  @override
  String get categoryExpenseSubscriptions => 'Subscriptions';

  @override
  String get categoryExpenseEntertainment => 'Entertainment & outings';

  @override
  String get categoryExpenseOther => 'Other';

  @override
  String get categoryIncomeSalary => 'Salary';

  @override
  String get categoryIncomeFreelance => 'Freelance';

  @override
  String get categoryIncomeOther => 'Other income';

  @override
  String get notFoundTitle => 'Page unavailable';

  @override
  String get notFoundBody => 'The requested destination is unavailable.';
}
