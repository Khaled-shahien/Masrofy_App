import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../core/settings/app_settings_store.dart';
import '../core/storage/local_storage_bootstrap.dart';
import '../data/catalog/default_category_catalog.dart';
import '../data/datasources/categories/category_local_data_source.dart';
import '../data/datasources/transactions/transaction_local_data_source.dart';
import '../data/datasources/wallets/wallet_balance_local_data_source.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../data/repositories/wallet_balance_repository_impl.dart';
import '../data/seed/provided_expenses_importer.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/wallet_balance_repository.dart';
import '../domain/usecases/categories/initialize_default_categories.dart';
import '../domain/usecases/categories/save_custom_category.dart';
import '../domain/usecases/categories/set_category_default_wallet.dart';
import '../domain/usecases/categories/set_category_visibility.dart';
import '../domain/usecases/categories/watch_categories.dart';
import '../domain/usecases/transactions/delete_transaction.dart';
import '../domain/usecases/transactions/save_transaction.dart';
import '../domain/usecases/transactions/watch_transactions.dart';
import '../domain/usecases/wallets/set_wallet_current_balance.dart';
import '../presentation/cubits/categories/categories_cubit.dart';
import '../presentation/cubits/settings/app_settings_cubit.dart';
import '../presentation/cubits/transactions/transactions_cubit.dart';
import '../presentation/cubits/wallets/wallet_balances_cubit.dart';
import '../routing/app_router.dart';

/// Shared application dependency container.
final serviceLocator = GetIt.instance;

/// Registers application services and seeds the default category catalog.
Future<void> configureDependencies() async {
  if (serviceLocator.isRegistered<CategoryLocalDataSource>()) {
    await serviceLocator.reset();
  }

  final categoryLocalDataSource = _createCategoryLocalDataSource();
  final transactionLocalDataSource = _createTransactionLocalDataSource();
  final walletBalanceLocalDataSource = _createWalletBalanceLocalDataSource();
  final appSettingsStore = _createAppSettingsStore();
  const uuid = Uuid();

  serviceLocator
    ..registerSingleton<AppSettingsStore>(appSettingsStore)
    ..registerSingleton<CategoryLocalDataSource>(
      categoryLocalDataSource,
      dispose: (dataSource) async {
        if (dataSource case InMemoryCategoryLocalDataSource()) {
          await dataSource.close();
        }
      },
    )
    ..registerSingleton<TransactionLocalDataSource>(
      transactionLocalDataSource,
      dispose: (dataSource) async {
        if (dataSource case InMemoryTransactionLocalDataSource()) {
          await dataSource.close();
        }
      },
    )
    ..registerSingleton<WalletBalanceLocalDataSource>(
      walletBalanceLocalDataSource,
      dispose: (dataSource) async {
        if (dataSource case InMemoryWalletBalanceLocalDataSource()) {
          await dataSource.close();
        }
      },
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        localDataSource: serviceLocator<CategoryLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        localDataSource: serviceLocator<TransactionLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<WalletBalanceRepository>(
      () => WalletBalanceRepositoryImpl(
        localDataSource: serviceLocator<WalletBalanceLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<InitializeDefaultCategories>(
      () => InitializeDefaultCategories(
        repository: serviceLocator<CategoryRepository>(),
        defaults: defaultCategories,
      ),
    )
    ..registerLazySingleton<WatchCategories>(
      () => WatchCategories(serviceLocator<CategoryRepository>()),
    )
    ..registerLazySingleton<SaveCustomCategory>(
      () => SaveCustomCategory(
        repository: serviceLocator<CategoryRepository>(),
        generateId: uuid.v4,
      ),
    )
    ..registerLazySingleton<SetCategoryVisibility>(
      () => SetCategoryVisibility(serviceLocator<CategoryRepository>()),
    )
    ..registerLazySingleton<SetCategoryDefaultWallet>(
      () => SetCategoryDefaultWallet(serviceLocator<CategoryRepository>()),
    )
    ..registerLazySingleton<WatchTransactions>(
      () => WatchTransactions(serviceLocator<TransactionRepository>()),
    )
    ..registerLazySingleton<SaveTransaction>(
      () => SaveTransaction(
        repository: serviceLocator<TransactionRepository>(),
        generateId: uuid.v4,
      ),
    )
    ..registerLazySingleton<DeleteTransaction>(
      () => DeleteTransaction(serviceLocator<TransactionRepository>()),
    )
    ..registerLazySingleton<SetWalletCurrentBalance>(
      () => SetWalletCurrentBalance(
        walletBalanceRepository: serviceLocator<WalletBalanceRepository>(),
        transactionRepository: serviceLocator<TransactionRepository>(),
      ),
    )
    ..registerFactory<CategoriesCubit>(
      () => CategoriesCubit(
        watchCategories: serviceLocator<WatchCategories>(),
        saveCustomCategory: serviceLocator<SaveCustomCategory>(),
        setCategoryVisibility: serviceLocator<SetCategoryVisibility>(),
        setCategoryDefaultWallet: serviceLocator<SetCategoryDefaultWallet>(),
      ),
    )
    ..registerFactory<TransactionsCubit>(
      () => TransactionsCubit(
        watchTransactions: serviceLocator<WatchTransactions>(),
        watchCategories: serviceLocator<WatchCategories>(),
        saveTransaction: serviceLocator<SaveTransaction>(),
        deleteTransaction: serviceLocator<DeleteTransaction>(),
      ),
    )
    ..registerLazySingleton<AppSettingsCubit>(
      () => AppSettingsCubit(store: serviceLocator<AppSettingsStore>()),
    )
    ..registerFactory<WalletBalancesCubit>(
      () => WalletBalancesCubit(
        walletBalanceRepository: serviceLocator<WalletBalanceRepository>(),
        transactionRepository: serviceLocator<TransactionRepository>(),
        setWalletCurrentBalance: serviceLocator<SetWalletCurrentBalance>(),
      ),
    )
    ..registerLazySingleton<AppRouter>(AppRouter.new)
    ..registerLazySingleton<GoRouter>(() => serviceLocator<AppRouter>().router);

  await serviceLocator<InitializeDefaultCategories>()();
  if (Hive.isBoxOpen(LocalStorageBootstrap.transactionsBoxName)) {
    await ProvidedExpensesImporter(
      serviceLocator<TransactionRepository>(),
    ).importOnce();
  }
}

CategoryLocalDataSource _createCategoryLocalDataSource() {
  if (Hive.isBoxOpen(LocalStorageBootstrap.categoriesBoxName)) {
    return HiveCategoryLocalDataSource(
      Hive.box<String>(LocalStorageBootstrap.categoriesBoxName),
    );
  }
  return InMemoryCategoryLocalDataSource();
}

TransactionLocalDataSource _createTransactionLocalDataSource() {
  if (Hive.isBoxOpen(LocalStorageBootstrap.transactionsBoxName)) {
    return HiveTransactionLocalDataSource(
      Hive.box<String>(LocalStorageBootstrap.transactionsBoxName),
    );
  }
  return InMemoryTransactionLocalDataSource();
}

WalletBalanceLocalDataSource _createWalletBalanceLocalDataSource() {
  if (Hive.isBoxOpen(LocalStorageBootstrap.walletBalancesBoxName)) {
    return HiveWalletBalanceLocalDataSource(
      Hive.box<String>(LocalStorageBootstrap.walletBalancesBoxName),
    );
  }
  return InMemoryWalletBalanceLocalDataSource();
}

AppSettingsStore _createAppSettingsStore() {
  if (Hive.isBoxOpen(LocalStorageBootstrap.settingsBoxName)) {
    return HiveAppSettingsStore(
      Hive.box<String>(LocalStorageBootstrap.settingsBoxName),
    );
  }
  return InMemoryAppSettingsStore();
}
