/// Versioned storage metadata for the local Hive data model.
class StorageSchema {
  const StorageSchema._();

  static const currentVersion = 3;

  static const metadataBoxName = 'storage_metadata_v1';
  static const quarantineBoxName = 'storage_quarantine_v2';
  static const legacyQuarantineBoxName = 'storage_quarantine_v1';

  static const categoriesBoxName = 'categories_v2';
  static const transactionsBoxName = 'transactions_v2';
  static const settingsBoxName = 'settings_v2';
  static const walletBalancesBoxName = 'wallet_balances_v2';
  static const budgetsBoxName = 'budgets_v1';

  static const legacyCategoriesBoxName = 'categories_v1';
  static const legacyTransactionsBoxName = 'transactions_v1';
  static const legacySettingsBoxName = 'settings_v1';
  static const legacyWalletBalancesBoxName = 'wallet_balances_v1';
}
