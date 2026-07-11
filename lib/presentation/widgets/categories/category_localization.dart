import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Resolves stable built-in keys while preserving user-entered custom names.
String localizedCategoryName(
  AppLocalizations localizations,
  Category category,
) {
  return switch (category.localizationKey) {
    'categoryExpenseFoodAndDrink' => localizations.categoryExpenseFoodAndDrink,
    'categoryExpenseCafesRestaurants' =>
      localizations.categoryExpenseCafesRestaurants,
    'categoryExpenseTransport' => localizations.categoryExpenseTransport,
    'categoryExpenseClothing' => localizations.categoryExpenseClothing,
    'categoryExpenseHealthcare' => localizations.categoryExpenseHealthcare,
    'categoryExpenseHousehold' => localizations.categoryExpenseHousehold,
    'categoryExpenseExtra' => localizations.categoryExpenseExtra,
    'categoryExpensePersonTransfer' =>
      localizations.categoryExpensePersonTransfer,
    'categoryExpensePersonalCare' => localizations.categoryExpensePersonalCare,
    'categoryExpenseSubscriptions' =>
      localizations.categoryExpenseSubscriptions,
    'categoryExpenseEntertainment' =>
      localizations.categoryExpenseEntertainment,
    'categoryExpenseOther' => localizations.categoryExpenseOther,
    'categoryIncomeSalary' => localizations.categoryIncomeSalary,
    'categoryIncomeFreelance' => localizations.categoryIncomeFreelance,
    'categoryIncomeOther' => localizations.categoryIncomeOther,
    null || _ => category.name,
  };
}

/// Returns a localized label for a transaction type.
String localizedTransactionType(
  AppLocalizations localizations,
  TransactionType type,
) {
  return switch (type) {
    TransactionType.expense => localizations.transactionTypeExpense,
    TransactionType.income => localizations.transactionTypeIncome,
  };
}

/// Returns a localized wallet display name.
String localizedWalletName(
  AppLocalizations localizations,
  WalletType wallet,
) {
  return switch (wallet) {
    WalletType.cash => localizations.walletCash,
    WalletType.instaPay => localizations.walletInstaPay,
    WalletType.vodafoneCash => localizations.walletVodafoneCash,
  };
}
