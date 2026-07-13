import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../core/security/app_lock_service.dart';
import '../core/security/biometric_authentication_service.dart';
import '../core/security/secure_value_store.dart';
import '../core/settings/app_settings_store.dart';
import '../core/storage/local_storage_bootstrap.dart';
import '../data/backup/backup_restore_service.dart';
import '../data/backup/backup_file_picker.dart';
import '../data/catalog/default_category_catalog.dart';
import '../data/datasources/budgets/budget_local_data_source.dart';
import '../data/datasources/categories/category_local_data_source.dart';
import '../data/datasources/transactions/transaction_local_data_source.dart';
import '../data/datasources/wallets/wallet_balance_local_data_source.dart';
import '../data/export/data_export_service.dart';
import '../data/models/category_model.dart';
import '../data/repositories/budget_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../data/repositories/wallet_balance_repository_impl.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/wallet_balance_repository.dart';
import '../domain/usecases/budgets/calculate_budget_progress.dart';
import '../domain/usecases/budgets/delete_budget.dart';
import '../domain/usecases/budgets/get_budgets_for_month.dart';
import '../domain/usecases/budgets/save_budget.dart';
import '../domain/usecases/budgets/watch_budgets.dart';
import '../domain/usecases/categories/initialize_default_categories.dart';
import '../domain/usecases/categories/save_custom_category.dart';
import '../domain/usecases/categories/set_category_default_wallet.dart';
import '../domain/usecases/categories/set_category_visibility.dart';
import '../domain/usecases/categories/watch_categories.dart';
import '../domain/usecases/dashboard/build_dashboard_summary.dart';
import '../domain/usecases/reports/build_report.dart';
import '../domain/usecases/transactions/delete_transaction.dart';
import '../domain/usecases/transactions/save_transaction.dart';
import '../domain/usecases/transactions/watch_transactions.dart';
import '../domain/usecases/wallets/set_wallet_current_balance.dart';
import '../presentation/cubits/budgets/budgets_cubit.dart';
import '../presentation/cubits/categories/categories_cubit.dart';
import '../presentation/cubits/reports/reports_cubit.dart';
import '../presentation/cubits/security/app_lock_cubit.dart';
import '../presentation/cubits/settings/app_settings_cubit.dart';
import '../presentation/cubits/transactions/transactions_cubit.dart';
import '../presentation/cubits/wallets/wallet_balances_cubit.dart';
import '../routing/app_router.dart';

/// Shared application dependency container.
final serviceLocator = GetIt.instance;

/// Registers application services and seeds the default category catalog.
Future<void> configureDependencies({
  bool? existingInstallation,
  bool allowInMemoryStores = false,
}) async {
  const uuid = Uuid();

  _registerSingletonIfAbsent<SecureValueStore>(FlutterSecureValueStore());
  _registerLazySingletonIfAbsent<AppLockService>(
    () => AppLockService(secureStore: serviceLocator<SecureValueStore>()),
  );
  _registerLazySingletonIfAbsent<BiometricAuthenticationService>(
    LocalAuthBiometricAuthenticationService.new,
  );
  _registerSingletonIfAbsent<AppSettingsStore>(
    _createAppSettingsStore(allowInMemoryStores: allowInMemoryStores),
  );
  _registerSingletonIfAbsent<CategoryLocalDataSource>(
    _createCategoryLocalDataSource(),
    dispose: (dataSource) async {
      if (dataSource case InMemoryCategoryLocalDataSource()) {
        await dataSource.close();
      }
    },
  );
  _registerSingletonIfAbsent<TransactionLocalDataSource>(
    _createTransactionLocalDataSource(),
    dispose: (dataSource) async {
      if (dataSource case InMemoryTransactionLocalDataSource()) {
        await dataSource.close();
      }
    },
  );
  _registerSingletonIfAbsent<WalletBalanceLocalDataSource>(
    _createWalletBalanceLocalDataSource(),
    dispose: (dataSource) async {
      if (dataSource case InMemoryWalletBalanceLocalDataSource()) {
        await dataSource.close();
      }
    },
  );
  _registerSingletonIfAbsent<BudgetLocalDataSource>(
    _createBudgetLocalDataSource(),
    dispose: (dataSource) async {
      if (dataSource case InMemoryBudgetLocalDataSource()) {
        await dataSource.close();
      }
    },
  );
  _registerLazySingletonIfAbsent<CategoryRepository>(
    () => CategoryRepositoryImpl(
      localDataSource: serviceLocator<CategoryLocalDataSource>(),
    ),
  );
  _registerLazySingletonIfAbsent<TransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: serviceLocator<TransactionLocalDataSource>(),
    ),
  );
  _registerLazySingletonIfAbsent<WalletBalanceRepository>(
    () => WalletBalanceRepositoryImpl(
      localDataSource: serviceLocator<WalletBalanceLocalDataSource>(),
    ),
  );
  _registerLazySingletonIfAbsent<BudgetRepository>(
    () => BudgetRepositoryImpl(
      localDataSource: serviceLocator<BudgetLocalDataSource>(),
    ),
  );
  _registerLazySingletonIfAbsent<InitializeDefaultCategories>(
    () => InitializeDefaultCategories(
      repository: serviceLocator<CategoryRepository>(),
      defaults: defaultCategories,
    ),
  );
  _registerLazySingletonIfAbsent<WatchCategories>(
    () => WatchCategories(serviceLocator<CategoryRepository>()),
  );
  _registerLazySingletonIfAbsent<SaveCustomCategory>(
    () => SaveCustomCategory(
      repository: serviceLocator<CategoryRepository>(),
      generateId: uuid.v4,
    ),
  );
  _registerLazySingletonIfAbsent<SetCategoryVisibility>(
    () => SetCategoryVisibility(serviceLocator<CategoryRepository>()),
  );
  _registerLazySingletonIfAbsent<SetCategoryDefaultWallet>(
    () => SetCategoryDefaultWallet(serviceLocator<CategoryRepository>()),
  );
  _registerLazySingletonIfAbsent<WatchTransactions>(
    () => WatchTransactions(serviceLocator<TransactionRepository>()),
  );
  _registerLazySingletonIfAbsent<SaveTransaction>(
    () => SaveTransaction(
      repository: serviceLocator<TransactionRepository>(),
      categoryRepository: serviceLocator<CategoryRepository>(),
      generateId: uuid.v4,
    ),
  );
  _registerLazySingletonIfAbsent<DeleteTransaction>(
    () => DeleteTransaction(serviceLocator<TransactionRepository>()),
  );
  _registerLazySingletonIfAbsent<SetWalletCurrentBalance>(
    () => SetWalletCurrentBalance(
      walletBalanceRepository: serviceLocator<WalletBalanceRepository>(),
      transactionRepository: serviceLocator<TransactionRepository>(),
    ),
  );
  _registerLazySingletonIfAbsent<WatchBudgets>(
    () => WatchBudgets(serviceLocator<BudgetRepository>()),
  );
  _registerLazySingletonIfAbsent<GetBudgetsForMonth>(
    () => GetBudgetsForMonth(serviceLocator<BudgetRepository>()),
  );
  _registerLazySingletonIfAbsent<SaveBudget>(
    () => SaveBudget(
      budgetRepository: serviceLocator<BudgetRepository>(),
      categoryRepository: serviceLocator<CategoryRepository>(),
      generateId: uuid.v4,
    ),
  );
  _registerLazySingletonIfAbsent<DeleteBudget>(
    () => DeleteBudget(serviceLocator<BudgetRepository>()),
  );
  _registerLazySingletonIfAbsent<CalculateBudgetProgress>(
    CalculateBudgetProgress.new,
  );
  _registerLazySingletonIfAbsent<BuildDashboardSummary>(
    BuildDashboardSummary.new,
  );
  _registerLazySingletonIfAbsent<BuildReport>(BuildReport.new);
  _registerLazySingletonIfAbsent<DataExportService>(DataExportService.new);
  _registerLazySingletonIfAbsent<BackupFilePicker>(
    PlatformBackupFilePicker.new,
  );
  _registerLazySingletonIfAbsent<BackupRestoreService>(
    () => BackupRestoreService(
      transactionDataSource: serviceLocator<TransactionLocalDataSource>(),
      categoryDataSource: serviceLocator<CategoryLocalDataSource>(),
      budgetDataSource: serviceLocator<BudgetLocalDataSource>(),
      walletBalanceDataSource: serviceLocator<WalletBalanceLocalDataSource>(),
      settingsStore: serviceLocator<AppSettingsStore>(),
      resetCategories: defaultCategories.map(CategoryModel.fromDomain),
    ),
  );
  _registerFactoryIfAbsent<CategoriesCubit>(
    () => CategoriesCubit(
      watchCategories: serviceLocator<WatchCategories>(),
      saveCustomCategory: serviceLocator<SaveCustomCategory>(),
      setCategoryVisibility: serviceLocator<SetCategoryVisibility>(),
      setCategoryDefaultWallet: serviceLocator<SetCategoryDefaultWallet>(),
    ),
  );
  _registerFactoryIfAbsent<TransactionsCubit>(
    () => TransactionsCubit(
      watchTransactions: serviceLocator<WatchTransactions>(),
      watchCategories: serviceLocator<WatchCategories>(),
      saveTransaction: serviceLocator<SaveTransaction>(),
      deleteTransaction: serviceLocator<DeleteTransaction>(),
    ),
  );
  _registerLazySingletonIfAbsent<AppSettingsCubit>(
    () => AppSettingsCubit(store: serviceLocator<AppSettingsStore>()),
  );
  _registerFactoryIfAbsent<AppLockCubit>(
    () => AppLockCubit(
      appLockService: serviceLocator<AppLockService>(),
      biometricAuthenticationService:
          serviceLocator<BiometricAuthenticationService>(),
    ),
  );
  _registerFactoryIfAbsent<WalletBalancesCubit>(
    () => WalletBalancesCubit(
      walletBalanceRepository: serviceLocator<WalletBalanceRepository>(),
      transactionRepository: serviceLocator<TransactionRepository>(),
      setWalletCurrentBalance: serviceLocator<SetWalletCurrentBalance>(),
    ),
  );
  _registerFactoryIfAbsent<BudgetsCubit>(
    () => BudgetsCubit(
      watchBudgets: serviceLocator<WatchBudgets>(),
      watchTransactions: serviceLocator<WatchTransactions>(),
      watchCategories: serviceLocator<WatchCategories>(),
      saveBudget: serviceLocator<SaveBudget>(),
      deleteBudget: serviceLocator<DeleteBudget>(),
      calculateBudgetProgress: serviceLocator<CalculateBudgetProgress>(),
    ),
  );
  _registerFactoryIfAbsent<ReportsCubit>(
    () => ReportsCubit(
      watchTransactions: serviceLocator<WatchTransactions>(),
      watchCategories: serviceLocator<WatchCategories>(),
      buildReport: serviceLocator<BuildReport>(),
    ),
  );
  _registerLazySingletonIfAbsent<AppRouter>(AppRouter.new);
  _registerLazySingletonIfAbsent<GoRouter>(
    () => serviceLocator<AppRouter>().router,
  );

  if (existingInstallation != null) {
    await serviceLocator<AppSettingsStore>().migrateOnboardingState(
      existingInstallation: existingInstallation,
    );
  }
  await serviceLocator<InitializeDefaultCategories>()();
}

void _registerSingletonIfAbsent<T extends Object>(
  T instance, {
  Future<void> Function(T instance)? dispose,
}) {
  if (serviceLocator.isRegistered<T>()) {
    return;
  }

  serviceLocator.registerSingleton<T>(instance, dispose: dispose);
}

void _registerLazySingletonIfAbsent<T extends Object>(T Function() factory) {
  if (serviceLocator.isRegistered<T>()) {
    return;
  }

  serviceLocator.registerLazySingleton<T>(factory);
}

void _registerFactoryIfAbsent<T extends Object>(T Function() factory) {
  if (serviceLocator.isRegistered<T>()) {
    return;
  }

  serviceLocator.registerFactory<T>(factory);
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

BudgetLocalDataSource _createBudgetLocalDataSource() {
  if (Hive.isBoxOpen(LocalStorageBootstrap.budgetsBoxName)) {
    return HiveBudgetLocalDataSource(
      Hive.box<String>(LocalStorageBootstrap.budgetsBoxName),
    );
  }
  return InMemoryBudgetLocalDataSource();
}

AppSettingsStore _createAppSettingsStore({required bool allowInMemoryStores}) {
  if (Hive.isBoxOpen(LocalStorageBootstrap.settingsBoxName)) {
    return HiveAppSettingsStore(
      Hive.box<String>(LocalStorageBootstrap.settingsBoxName),
    );
  }
  if (allowInMemoryStores) {
    return InMemoryAppSettingsStore();
  }
  throw StateError(
    'Persistent settings storage is not initialized. Startup cannot continue.',
  );
}
