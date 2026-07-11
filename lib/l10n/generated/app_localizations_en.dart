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
  String get saveTransaction => 'Save transaction';

  @override
  String get transactionSavedMessage => 'Transaction saved';

  @override
  String get transactionTypeExpenseForm => 'Expense';

  @override
  String get transactionTypeIncomeForm => 'Income';

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
  String reportsExpenseRatio(Object percentage) {
    return '$percentage% of expenses';
  }

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
