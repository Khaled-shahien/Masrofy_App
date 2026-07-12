import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/export/export_file_namer.dart';
import 'package:masrofy/core/settings/app_settings_store.dart';
import 'package:masrofy/data/backup/backup_restore_service.dart';
import 'package:masrofy/data/datasources/budgets/budget_local_data_source.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/datasources/transactions/transaction_local_data_source.dart';
import 'package:masrofy/data/datasources/wallets/wallet_balance_local_data_source.dart';
import 'package:masrofy/data/models/budget_model.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/models/financial_transaction_model.dart';
import 'package:masrofy/data/models/wallet_balance_model.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';

void main() {
  test('builds a complete versioned backup with safe settings', () async {
    final store = InMemoryAppSettingsStore();
    await store.saveLocaleCode('en');
    await store.saveThemeMode(ThemeMode.dark);
    final service = _service(settingsStore: store);

    final file = await service.buildBackupFile();
    final backup = _decode(file.bytes);

    expect(file.fileName, 'masrofy_backup_20260712_0905.json');
    expect(backup['backupFormatVersion'], 1);
    expect(backup['schemaVersion'], 2);
    expect(backup['createdAt'], '2026-07-12T09:05:00.000');
    expect(backup['data']['transactions'], hasLength(1));
    expect(backup['data']['categories'], hasLength(1));
    expect(backup['data']['budgets'], hasLength(1));
    expect(backup['data']['walletBalances'], hasLength(1));
    expect(
      backup['data']['settings'],
      {
        'localeCode': 'en',
        'themeMode': 'dark',
        'hideFinancialAmounts': false,
      },
    );
    expect(jsonEncode(backup), isNot(contains('pin')));
    expect(jsonEncode(backup), isNot(contains('encryption')));
  });

  test(
    'replace restore swaps data and restores settings and budgets',
    () async {
      final sourceStore = InMemoryAppSettingsStore();
      await sourceStore.saveLocaleCode('en');
      await sourceStore.saveThemeMode(ThemeMode.dark);
      final backup = await _service(
        settingsStore: sourceStore,
      ).buildBackupFile();
      final store = InMemoryAppSettingsStore();
      await store.saveLocaleCode('ar');
      final targetTransactions = InMemoryTransactionLocalDataSource([
        _transaction(id: 'old-tx', categoryId: 'old-category'),
      ]);
      final targetCategories = InMemoryCategoryLocalDataSource([
        _category(id: 'old-category', name: 'Old'),
      ]);
      final targetBudgets = InMemoryBudgetLocalDataSource();
      final targetWallets = InMemoryWalletBalanceLocalDataSource();
      final target = _service(
        transactions: targetTransactions,
        categories: targetCategories,
        budgets: targetBudgets,
        wallets: targetWallets,
        settingsStore: store,
      );

      final result = await target.restoreBackupBytes(
        backup.bytes,
        mode: BackupImportMode.replace,
      );

      expect(result.mode, BackupImportMode.replace);
      expect(await targetTransactions.getTransactions(), hasLength(1));
      expect((await targetTransactions.getTransactions()).single.id, 'tx-1');
      expect((await targetCategories.getCategories()).single.id, 'food');
      expect((await targetBudgets.getBudgets()).single.id, 'budget-1');
      expect(
        (await targetWallets.getWalletBalances()).single.walletType,
        WalletType.cash,
      );
      expect(store.localeCode, 'en');
      expect(store.themeMode, ThemeMode.dark);
    },
  );

  test('merge restore deduplicates by ID and imported records win', () async {
    final importedService = _service(
      transactions: InMemoryTransactionLocalDataSource([
        _transaction(amount: 99),
        _transaction(id: 'tx-2'),
      ]),
      categories: InMemoryCategoryLocalDataSource([_category()]),
    );
    final backup = await importedService.buildBackupFile();
    final targetTransactions = InMemoryTransactionLocalDataSource([
      _transaction(amount: 10),
      _transaction(id: 'local-only'),
    ]);
    final target = _service(transactions: targetTransactions);

    final result = await target.restoreBackupBytes(
      backup.bytes,
      mode: BackupImportMode.merge,
    );

    final transactions = await targetTransactions.getTransactions();
    expect(result.transactionCount, 3);
    expect(transactions.map((transaction) => transaction.id), {
      'tx-1',
      'tx-2',
      'local-only',
    });
    expect(
      transactions
          .singleWhere((transaction) => transaction.id == 'tx-1')
          .amount,
      99,
    );
  });

  test('rejects duplicate IDs without changing existing data', () async {
    final targetTransactions = InMemoryTransactionLocalDataSource([
      _transaction(id: 'existing'),
    ]);
    final target = _service(transactions: targetTransactions);
    final backup = _decode((await _service().buildBackupFile()).bytes);
    backup['data']['transactions'].add(backup['data']['transactions'].first);

    await expectLater(
      target.restoreBackupBytes(
        _encode(backup),
        mode: BackupImportMode.merge,
      ),
      throwsA(
        isA<BackupRestoreException>().having(
          (error) => error.reason,
          'reason',
          BackupRestoreFailureReason.validation,
        ),
      ),
    );
    expect((await targetTransactions.getTransactions()).single.id, 'existing');
  });

  test('rejects unsupported and corrupted backup files', () async {
    final service = _service();
    final backup = _decode((await service.buildBackupFile()).bytes)
      ..['backupFormatVersion'] = 999;

    await expectLater(
      service.restoreBackupBytes(_encode(backup), mode: BackupImportMode.merge),
      throwsA(
        isA<BackupRestoreException>().having(
          (error) => error.reason,
          'reason',
          BackupRestoreFailureReason.unsupportedVersion,
        ),
      ),
    );
    await expectLater(
      service.restoreBackupBytes(
        Uint8List.fromList(utf8.encode('{broken')),
        mode: BackupImportMode.merge,
      ),
      throwsA(
        isA<BackupRestoreException>().having(
          (error) => error.reason,
          'reason',
          BackupRestoreFailureReason.malformed,
        ),
      ),
    );
  });

  test('rejects partial records before touching existing data', () async {
    final targetTransactions = InMemoryTransactionLocalDataSource([
      _transaction(id: 'existing'),
    ]);
    final service = _service(transactions: targetTransactions);
    final backup = _decode((await _service().buildBackupFile()).bytes);
    backup['data']['budgets'].first.remove('createdAt');

    await expectLater(
      service.restoreBackupBytes(_encode(backup), mode: BackupImportMode.merge),
      throwsA(isA<BackupRestoreException>()),
    );
    expect((await targetTransactions.getTransactions()).single.id, 'existing');
  });

  test('rolls back previous state when a write fails during restore', () async {
    final transactions = InMemoryTransactionLocalDataSource([
      _transaction(id: 'existing'),
    ]);
    final categories = InMemoryCategoryLocalDataSource([
      _category(id: 'existing-category'),
    ]);
    final budgets = InMemoryBudgetLocalDataSource([
      _budget(id: 'existing-budget', categoryId: 'existing-category'),
    ]);
    final wallets = _FailingWalletBalanceLocalDataSource(
      InMemoryWalletBalanceLocalDataSource([
        _wallet(WalletType.instaPay, baseBalance: 42),
      ]),
    );
    final store = InMemoryAppSettingsStore();
    await store.saveLocaleCode('en');
    final target = _service(
      transactions: transactions,
      categories: categories,
      budgets: budgets,
      wallets: wallets,
      settingsStore: store,
    );
    final backup = await _service().buildBackupFile();

    await expectLater(
      target.restoreBackupBytes(backup.bytes, mode: BackupImportMode.replace),
      throwsA(
        isA<BackupRestoreException>().having(
          (error) => error.reason,
          'reason',
          BackupRestoreFailureReason.writeFailure,
        ),
      ),
    );

    expect((await transactions.getTransactions()).single.id, 'existing');
    expect((await categories.getCategories()).single.id, 'existing-category');
    expect((await budgets.getBudgets()).single.id, 'existing-budget');
    expect(
      (await wallets.getWalletBalances()).single.walletType,
      WalletType.instaPay,
    );
    expect(store.localeCode, 'en');
  });

  test(
    'deleteAllLocalData restores defaults and clears financial data',
    () async {
      final transactions = InMemoryTransactionLocalDataSource([_transaction()]);
      final categories = InMemoryCategoryLocalDataSource([_category()]);
      final budgets = InMemoryBudgetLocalDataSource([_budget()]);
      final wallets = InMemoryWalletBalanceLocalDataSource([
        _wallet(WalletType.cash),
      ]);
      final store = InMemoryAppSettingsStore();
      await store.saveLocaleCode('en');
      await store.saveThemeMode(ThemeMode.dark);
      final service = _service(
        transactions: transactions,
        categories: categories,
        budgets: budgets,
        wallets: wallets,
        settingsStore: store,
        resetCategories: [_category(id: 'default', name: 'Default')],
      );

      await service.deleteAllLocalData();

      expect(await transactions.getTransactions(), isEmpty);
      expect((await categories.getCategories()).single.id, 'default');
      expect(await budgets.getBudgets(), isEmpty);
      expect(await wallets.getWalletBalances(), isEmpty);
      expect(store.localeCode, 'ar');
      expect(store.themeMode, ThemeMode.system);
    },
  );
}

BackupRestoreService _service({
  TransactionLocalDataSource? transactions,
  CategoryLocalDataSource? categories,
  BudgetLocalDataSource? budgets,
  WalletBalanceLocalDataSource? wallets,
  AppSettingsStore? settingsStore,
  Iterable<CategoryModel> resetCategories = const [],
}) {
  return BackupRestoreService(
    transactionDataSource:
        transactions ?? InMemoryTransactionLocalDataSource([_transaction()]),
    categoryDataSource:
        categories ??
        InMemoryCategoryLocalDataSource([
          _category(),
        ]),
    budgetDataSource: budgets ?? InMemoryBudgetLocalDataSource([_budget()]),
    walletBalanceDataSource:
        wallets ??
        InMemoryWalletBalanceLocalDataSource([_wallet(WalletType.cash)]),
    settingsStore: settingsStore ?? InMemoryAppSettingsStore(),
    resetCategories: resetCategories,
    now: () => DateTime(2026, 7, 12, 9, 5),
    namer: const _FixedBackupNamer(),
  );
}

Map<String, dynamic> _decode(Uint8List bytes) {
  return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
}

Uint8List _encode(Map<String, dynamic> json) {
  return Uint8List.fromList(utf8.encode(jsonEncode(json)));
}

CategoryModel _category({
  String id = 'food',
  String name = 'Food',
}) {
  return CategoryModel.fromDomain(
    Category(
      id: id,
      type: TransactionType.expense,
      name: name,
      localizationKey: null,
      iconKey: 'restaurant',
      colorValue: 0xFF2A9D8F,
      sortOrder: 0,
    ),
  );
}

FinancialTransactionModel _transaction({
  String id = 'tx-1',
  String categoryId = 'food',
  double amount = 25,
}) {
  return FinancialTransactionModel(
    id: id,
    type: TransactionType.expense,
    amount: amount,
    categoryId: categoryId,
    date: DateTime(2026, 7, 10),
    createdAt: DateTime(2026, 7, 10),
    updatedAt: DateTime(2026, 7, 10),
  );
}

BudgetModel _budget({
  String id = 'budget-1',
  String categoryId = 'food',
}) {
  return BudgetModel(
    id: id,
    categoryId: categoryId,
    amount: 500,
    month: 7,
    year: 2026,
    createdAt: DateTime(2026, 7),
    updatedAt: DateTime(2026, 7),
  );
}

WalletBalanceModel _wallet(
  WalletType walletType, {
  double baseBalance = 100,
}) {
  return WalletBalanceModel(
    walletType: walletType,
    baseBalance: baseBalance,
    updatedAt: DateTime(2026, 7, 1),
  );
}

class _FixedBackupNamer extends ExportFileNamer {
  const _FixedBackupNamer();

  @override
  String backupJson() => 'masrofy_backup_20260712_0905.json';
}

class _FailingWalletBalanceLocalDataSource
    implements WalletBalanceLocalDataSource {
  _FailingWalletBalanceLocalDataSource(this._inner);

  final InMemoryWalletBalanceLocalDataSource _inner;
  bool _failNextReplace = true;

  @override
  Future<WalletBalanceModel?> getWalletBalance(WalletType walletType) {
    return _inner.getWalletBalance(walletType);
  }

  @override
  Future<List<WalletBalanceModel>> getWalletBalances() {
    return _inner.getWalletBalances();
  }

  @override
  Future<void> replaceWalletBalances(
    Iterable<WalletBalanceModel> balances,
  ) async {
    if (_failNextReplace) {
      _failNextReplace = false;
      throw StateError('simulated write failure');
    }
    await _inner.replaceWalletBalances(balances);
  }

  @override
  Future<void> saveWalletBalance(WalletBalanceModel balance) {
    return _inner.saveWalletBalance(balance);
  }

  @override
  Stream<List<WalletBalanceModel>> watchWalletBalances() {
    return _inner.watchWalletBalances();
  }
}
