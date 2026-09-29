import 'dart:convert';
import 'dart:typed_data';

import '../../core/export/export_file_namer.dart';
import '../../core/settings/app_settings_store.dart';
import '../../core/storage/storage_schema.dart';
import '../../domain/entities/exported_file.dart';
import '../datasources/budgets/budget_local_data_source.dart';
import '../datasources/categories/category_local_data_source.dart';
import '../datasources/transactions/transaction_local_data_source.dart';
import '../datasources/wallets/wallet_balance_local_data_source.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/financial_transaction_model.dart';
import '../models/wallet_balance_model.dart';

/// Supported restore strategies for an imported backup.
enum BackupImportMode {
  /// Replace all local data with the validated backup contents.
  replace,

  /// Merge records by stable IDs. Imported records win conflicts.
  merge,
}

/// Safe categories of backup/restore failures.
enum BackupRestoreFailureReason {
  malformed,
  unsupportedVersion,
  validation,
  writeFailure,
}

/// Exception used for user-safe backup/restore failures.
class BackupRestoreException implements Exception {
  /// Creates a backup exception with a safe [message].
  const BackupRestoreException(this.reason, this.message);

  /// The high-level failure reason.
  final BackupRestoreFailureReason reason;

  /// Safe diagnostic text that must not include financial records.
  final String message;

  @override
  String toString() => 'BackupRestoreException($reason): $message';
}

/// Summary of a successful restore operation.
class BackupRestoreResult {
  const BackupRestoreResult({
    required this.mode,
    required this.transactionCount,
    required this.categoryCount,
    required this.budgetCount,
    required this.walletBalanceCount,
  });

  final BackupImportMode mode;
  final int transactionCount;
  final int categoryCount;
  final int budgetCount;
  final int walletBalanceCount;
}

/// Creates and restores local Masrofy backups.
class BackupRestoreService {
  /// Creates a backup service over the local data sources.
  const BackupRestoreService({
    required this._transactionDataSource,
    required CategoryLocalDataSource categoryDataSource,
    required this._budgetDataSource,
    required this._walletBalanceDataSource,
    required this._settingsStore,
    this._resetCategories = const [],
    ExportFileNamer? namer,
    this._now,
    this._appVersion,
  }) : _categoryDataSource = categoryDataSource,
       _namer = namer ?? const ExportFileNamer();

  static const int backupFormatVersion = 1;

  final TransactionLocalDataSource _transactionDataSource;
  final CategoryLocalDataSource _categoryDataSource;
  final BudgetLocalDataSource _budgetDataSource;
  final WalletBalanceLocalDataSource _walletBalanceDataSource;
  final AppSettingsStore _settingsStore;
  final Iterable<CategoryModel> _resetCategories;
  final ExportFileNamer _namer;
  final DateTime Function()? _now;
  final String? _appVersion;

  /// Builds a complete local backup as a JSON file.
  Future<ExportedFile> buildBackupFile() async {
    final snapshot = await _readSnapshot();
    final payload = <String, dynamic>{
      'backupFormatVersion': backupFormatVersion,
      'schemaVersion': StorageSchema.currentVersion,
      'createdAt': (_now?.call() ?? DateTime.now()).toIso8601String(),
      'appVersion': _appVersion,
      'data': snapshot.toJson(),
    };
    const encoder = JsonEncoder.withIndent('  ');
    return ExportedFile(
      fileName: _namer.backupJson(),
      mimeType: 'application/json',
      bytes: Uint8List.fromList(utf8.encode(encoder.convert(payload))),
    );
  }

  /// Restores a validated backup file using [mode].
  Future<BackupRestoreResult> restoreBackupBytes(
    Uint8List bytes, {
    required BackupImportMode mode,
  }) async {
    final imported = _decodeBackup(bytes);
    final target = switch (mode) {
      BackupImportMode.replace => imported,
      BackupImportMode.merge => await _mergeWithCurrent(imported),
    };
    final rollback = await _readSnapshot();

    try {
      await _applySnapshot(target);
      await _verifySnapshot(target);
    } on Object {
      await _restoreRollback(rollback);
      throw const BackupRestoreException(
        BackupRestoreFailureReason.writeFailure,
        'Backup restore failed safely.',
      );
    }

    return target.toResult(mode);
  }

  /// Deletes local financial data and restores required default categories.
  Future<void> deleteAllLocalData() async {
    final rollback = await _readSnapshot();
    final target = _BackupSnapshot(
      transactions: const [],
      categories: _sortById(_resetCategories),
      budgets: const [],
      walletBalances: const [],
      settings: const AppSettingsSnapshot.defaults(),
    );

    try {
      await _applySnapshot(target);
      await _verifySnapshot(target);
    } on Object {
      await _restoreRollback(rollback);
      throw const BackupRestoreException(
        BackupRestoreFailureReason.writeFailure,
        'Local data reset failed safely.',
      );
    }
  }

  Future<_BackupSnapshot> _readSnapshot() async {
    return _BackupSnapshot(
      transactions: _sortById(await _transactionDataSource.getTransactions()),
      categories: _sortById(await _categoryDataSource.getCategories()),
      budgets: _sortById(await _budgetDataSource.getBudgets()),
      walletBalances: _sortByWallet(
        await _walletBalanceDataSource.getWalletBalances(),
      ),
      settings: _settingsStore.safeSnapshot,
    );
  }

  _BackupSnapshot _decodeBackup(Uint8List bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Backup root must be a map.');
      }
      if (decoded['backupFormatVersion'] != backupFormatVersion) {
        throw const BackupRestoreException(
          BackupRestoreFailureReason.unsupportedVersion,
          'Unsupported backup version.',
        );
      }
      final schemaVersion = decoded['schemaVersion'];
      if (schemaVersion is! int || schemaVersion < 1) {
        throw const FormatException('Invalid schema version.');
      }
      final createdAt = decoded['createdAt'];
      if (createdAt is! String || DateTime.tryParse(createdAt) == null) {
        throw const FormatException('Invalid backup timestamp.');
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Backup data must be a map.');
      }
      return _BackupSnapshot.fromJson(data);
    } on BackupRestoreException {
      rethrow;
    } on Object {
      throw const BackupRestoreException(
        BackupRestoreFailureReason.malformed,
        'Backup file is malformed.',
      );
    }
  }

  Future<_BackupSnapshot> _mergeWithCurrent(_BackupSnapshot imported) async {
    final current = await _readSnapshot();
    return _BackupSnapshot(
      transactions: _mergeById(current.transactions, imported.transactions),
      categories: _mergeById(current.categories, imported.categories),
      budgets: _mergeById(current.budgets, imported.budgets),
      walletBalances: _mergeByWallet(
        current.walletBalances,
        imported.walletBalances,
      ),
      settings: imported.settings,
    );
  }

  Future<void> _applySnapshot(_BackupSnapshot snapshot) async {
    await _categoryDataSource.replaceCategories(snapshot.categories);
    await _transactionDataSource.replaceTransactions(snapshot.transactions);
    await _budgetDataSource.replaceBudgets(snapshot.budgets);
    await _walletBalanceDataSource.replaceWalletBalances(
      snapshot.walletBalances,
    );
    await _settingsStore.restoreSafeSnapshot(snapshot.settings);
  }

  Future<void> _verifySnapshot(_BackupSnapshot expected) async {
    final actual = await _readSnapshot();
    if (jsonEncode(actual.toJson()) != jsonEncode(expected.toJson())) {
      throw const BackupRestoreException(
        BackupRestoreFailureReason.writeFailure,
        'Backup restore verification failed.',
      );
    }
  }

  Future<void> _restoreRollback(_BackupSnapshot rollback) async {
    try {
      await _applySnapshot(rollback);
    } on Object {
      throw const BackupRestoreException(
        BackupRestoreFailureReason.writeFailure,
        'Backup restore rollback failed.',
      );
    }
  }
}

class _BackupSnapshot {
  const _BackupSnapshot({
    required this.transactions,
    required this.categories,
    required this.budgets,
    required this.walletBalances,
    required this.settings,
  });

  final List<FinancialTransactionModel> transactions;
  final List<CategoryModel> categories;
  final List<BudgetModel> budgets;
  final List<WalletBalanceModel> walletBalances;
  final AppSettingsSnapshot settings;

  factory _BackupSnapshot.fromJson(Map<String, dynamic> json) {
    final snapshot = _BackupSnapshot(
      transactions: _sortById(
        _records(json, 'transactions').map(FinancialTransactionModel.fromJson),
      ),
      categories: _sortById(
        _records(json, 'categories').map(CategoryModel.fromJson),
      ),
      budgets: _sortById(_records(json, 'budgets').map(BudgetModel.fromJson)),
      walletBalances: _sortByWallet(
        _records(json, 'walletBalances').map(WalletBalanceModel.fromJson),
      ),
      settings: AppSettingsSnapshot.fromJson(_record(json, 'settings')),
    );
    snapshot._validate();
    return snapshot;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'transactions': [
        for (final transaction in transactions) transaction.toJson(),
      ],
      'categories': [for (final category in categories) category.toJson()],
      'budgets': [for (final budget in budgets) budget.toJson()],
      'walletBalances': [
        for (final walletBalance in walletBalances) walletBalance.toJson(),
      ],
      'settings': settings.toJson(),
    };
  }

  BackupRestoreResult toResult(BackupImportMode mode) {
    return BackupRestoreResult(
      mode: mode,
      transactionCount: transactions.length,
      categoryCount: categories.length,
      budgetCount: budgets.length,
      walletBalanceCount: walletBalances.length,
    );
  }

  void _validate() {
    _assertUnique(
      values: transactions.map((transaction) => transaction.id),
      collection: 'transactions',
    );
    _assertUnique(
      values: categories.map((category) => category.id),
      collection: 'categories',
    );
    _assertUnique(
      values: budgets.map((budget) => budget.id),
      collection: 'budgets',
    );
    _assertUnique(
      values: walletBalances.map((balance) => balance.walletType.name),
      collection: 'walletBalances',
    );

    final categoryIds = categories.map((category) => category.id).toSet();
    for (final transaction in transactions) {
      if (!categoryIds.contains(transaction.categoryId)) {
        throw const BackupRestoreException(
          BackupRestoreFailureReason.validation,
          'Backup contains a transaction with an unknown category.',
        );
      }
    }
    for (final budget in budgets) {
      if (!categoryIds.contains(budget.categoryId)) {
        throw const BackupRestoreException(
          BackupRestoreFailureReason.validation,
          'Backup contains a budget with an unknown category.',
        );
      }
    }
  }
}

List<Map<String, dynamic>> _records(
  Map<String, dynamic> json,
  String fieldName,
) {
  final value = json[fieldName];
  if (value is! List) {
    throw FormatException('Invalid or missing $fieldName.');
  }
  return [
    for (final record in value)
      if (record is Map<String, dynamic>)
        record
      else
        throw FormatException('Invalid record in $fieldName.'),
  ];
}

Map<String, dynamic> _record(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('Invalid or missing $fieldName.');
}

void _assertUnique({
  required Iterable<String> values,
  required String collection,
}) {
  final seen = <String>{};
  for (final value in values) {
    if (!seen.add(value)) {
      throw BackupRestoreException(
        BackupRestoreFailureReason.validation,
        'Backup contains duplicate IDs in $collection.',
      );
    }
  }
}

List<T> _sortById<T extends Object>(Iterable<T> records) {
  final sorted = records.toList();
  sorted.sort((left, right) => _idOf(left).compareTo(_idOf(right)));
  return List<T>.unmodifiable(sorted);
}

List<WalletBalanceModel> _sortByWallet(Iterable<WalletBalanceModel> records) {
  final sorted = records.toList();
  sorted.sort(
    (left, right) => left.walletType.name.compareTo(right.walletType.name),
  );
  return List<WalletBalanceModel>.unmodifiable(sorted);
}

String _idOf(Object record) {
  return switch (record) {
    FinancialTransactionModel(:final id) => id,
    CategoryModel(:final id) => id,
    BudgetModel(:final id) => id,
    _ => throw ArgumentError('Unsupported backup record type.'),
  };
}

List<T> _mergeById<T extends Object>(
  Iterable<T> current,
  Iterable<T> imported,
) {
  final records = <String, T>{
    for (final record in current) _idOf(record): record,
  };
  for (final record in imported) {
    records[_idOf(record)] = record;
  }
  return _sortById(records.values);
}

List<WalletBalanceModel> _mergeByWallet(
  Iterable<WalletBalanceModel> current,
  Iterable<WalletBalanceModel> imported,
) {
  final records = <String, WalletBalanceModel>{
    for (final record in current) record.walletType.name: record,
  };
  for (final record in imported) {
    records[record.walletType.name] = record;
  }
  return _sortByWallet(records.values);
}
