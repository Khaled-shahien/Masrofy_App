import 'package:hive_flutter/hive_flutter.dart';

/// Prepares the local persistence required before the application starts.
class LocalStorageBootstrap {
  const LocalStorageBootstrap._();

  /// The versioned Hive box containing category JSON records.
  static const categoriesBoxName = 'categories_v1';

  /// The versioned Hive box containing transaction JSON records.
  static const transactionsBoxName = 'transactions_v1';

  /// The versioned Hive box containing user preference records.
  static const settingsBoxName = 'settings_v1';

  /// The versioned Hive box containing wallet balance records.
  static const walletBalancesBoxName = 'wallet_balances_v1';

  /// Initializes Hive and opens boxes required during application startup.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(categoriesBoxName);
    await Hive.openBox<String>(transactionsBoxName);
    await Hive.openBox<String>(settingsBoxName);
    await Hive.openBox<String>(walletBalancesBoxName);
  }
}
