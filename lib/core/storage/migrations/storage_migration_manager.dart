import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/financial_transaction_model.dart';
import '../../../data/models/wallet_balance_model.dart';
import '../storage_quarantine_store.dart';
import '../storage_schema.dart';
import 'storage_migration_result.dart';
import '../storage_key_store.dart';

/// Runs ordered, retryable storage migrations for the app's local boxes.
class StorageMigrationManager {
  StorageMigrationManager({
    required this._encryptionService,
    required bool encryptedDataExists,
    required this._quarantineStore,
    this._legacyQuarantineBox,
    Box<String>? metadataBox,
  }) : _encryptedDataExists = encryptedDataExists,
       _metadataBox =
           metadataBox ?? Hive.box<String>(StorageSchema.metadataBoxName);

  static const _schemaVersionKey = 'schemaVersion';

  final StorageEncryptionService _encryptionService;
  final bool _encryptedDataExists;
  final StorageQuarantineStore _quarantineStore;
  final Box<String>? _legacyQuarantineBox;
  final Box<String> _metadataBox;

  Future<StorageMigrationResult> migrate() async {
    final storedVersion = _readStoredVersion();
    final appliedMigrations = <String>[];
    var quarantinedCount = 0;

    try {
      if (storedVersion > StorageSchema.currentVersion) {
        return StorageMigrationResult(
          success: false,
          storedSchemaVersion: storedVersion,
          targetSchemaVersion: StorageSchema.currentVersion,
          appliedMigrations: appliedMigrations,
          quarantinedRecordCount: quarantinedCount,
          failureMessage: 'Unsupported storage schema version.',
        );
      }

      final cipher = HiveAesCipher(
        await _encryptionService.readOrCreateKeyBytes(
          encryptedDataExists: _encryptedDataExists,
        ),
      );
      final currentBoxes = await _openCurrentBoxes(cipher);
      await _openLegacyBoxes();

      if (storedVersion < 2) {
        quarantinedCount += await _migrateLegacyData(currentBoxes);
        appliedMigrations.add(
          'legacy-to-encrypted-v2',
        );
      }

      if (storedVersion < 3) {
        quarantinedCount += await _migratePlaintextQuarantine();
        appliedMigrations.add('plaintext-quarantine-to-sanitized-v3');
        await _metadataBox.put(
          _schemaVersionKey,
          StorageSchema.currentVersion.toString(),
        );
      }

      quarantinedCount += await _validateCurrentData(currentBoxes);
      return StorageMigrationResult(
        success: true,
        storedSchemaVersion: _readStoredVersion(),
        targetSchemaVersion: StorageSchema.currentVersion,
        appliedMigrations: appliedMigrations,
        quarantinedRecordCount: quarantinedCount,
      );
    } on Object catch (error) {
      return StorageMigrationResult(
        success: false,
        storedSchemaVersion: storedVersion,
        targetSchemaVersion: StorageSchema.currentVersion,
        appliedMigrations: appliedMigrations,
        quarantinedRecordCount: quarantinedCount,
        failureMessage: error.toString(),
      );
    }
  }

  int _readStoredVersion() {
    return int.tryParse(
          _metadataBox.get(_schemaVersionKey) ?? '0',
        ) ??
        0;
  }

  Future<Map<String, Box<String>>> _openCurrentBoxes(
    HiveAesCipher cipher,
  ) async {
    final currentCategories = await Hive.openBox<String>(
      StorageSchema.categoriesBoxName,
      encryptionCipher: cipher,
    );
    final currentTransactions = await Hive.openBox<String>(
      StorageSchema.transactionsBoxName,
      encryptionCipher: cipher,
    );
    final currentSettings = await Hive.openBox<String>(
      StorageSchema.settingsBoxName,
      encryptionCipher: cipher,
    );
    final currentWalletBalances = await Hive.openBox<String>(
      StorageSchema.walletBalancesBoxName,
      encryptionCipher: cipher,
    );
    final currentBudgets = await Hive.openBox<String>(
      StorageSchema.budgetsBoxName,
      encryptionCipher: cipher,
    );

    return <String, Box<String>>{
      StorageSchema.categoriesBoxName: currentCategories,
      StorageSchema.transactionsBoxName: currentTransactions,
      StorageSchema.settingsBoxName: currentSettings,
      StorageSchema.walletBalancesBoxName: currentWalletBalances,
      StorageSchema.budgetsBoxName: currentBudgets,
    };
  }

  Future<void> _openLegacyBoxes() async {
    await Hive.openBox<String>(StorageSchema.legacyCategoriesBoxName);
    await Hive.openBox<String>(StorageSchema.legacyTransactionsBoxName);
    await Hive.openBox<String>(StorageSchema.legacySettingsBoxName);
    await Hive.openBox<String>(StorageSchema.legacyWalletBalancesBoxName);
  }

  Future<int> _migrateLegacyData(Map<String, Box<String>> currentBoxes) async {
    var quarantinedCount = 0;

    quarantinedCount += await _copyAndValidateCategories(
      source: Hive.box<String>(StorageSchema.legacyCategoriesBoxName),
      target: currentBoxes[StorageSchema.categoriesBoxName]!,
    );
    quarantinedCount += await _copyAndValidateTransactions(
      source: Hive.box<String>(StorageSchema.legacyTransactionsBoxName),
      target: currentBoxes[StorageSchema.transactionsBoxName]!,
    );
    quarantinedCount += await _copyAndValidateWalletBalances(
      source: Hive.box<String>(StorageSchema.legacyWalletBalancesBoxName),
      target: currentBoxes[StorageSchema.walletBalancesBoxName]!,
    );

    final legacySettings = Hive.box<String>(
      StorageSchema.legacySettingsBoxName,
    );
    await currentBoxes[StorageSchema.settingsBoxName]!.putAll(
      legacySettings.toMap(),
    );
    return quarantinedCount;
  }

  Future<int> _validateCurrentData(
    Map<String, Box<String>> currentBoxes,
  ) async {
    var quarantinedCount = 0;
    quarantinedCount += await _scanBox(
      boxName: StorageSchema.categoriesBoxName,
      box: currentBoxes[StorageSchema.categoriesBoxName]!,
      parser: (json) => CategoryModel.fromJson(json),
    );
    quarantinedCount += await _scanBox(
      boxName: StorageSchema.transactionsBoxName,
      box: currentBoxes[StorageSchema.transactionsBoxName]!,
      parser: (json) => FinancialTransactionModel.fromJson(json),
    );
    quarantinedCount += await _scanBox(
      boxName: StorageSchema.walletBalancesBoxName,
      box: currentBoxes[StorageSchema.walletBalancesBoxName]!,
      parser: (json) => WalletBalanceModel.fromJson(json),
    );
    quarantinedCount += await _scanBox(
      boxName: StorageSchema.budgetsBoxName,
      box: currentBoxes[StorageSchema.budgetsBoxName]!,
      parser: (json) => BudgetModel.fromJson(json),
    );
    return quarantinedCount;
  }

  Future<int> _copyAndValidateCategories({
    required Box<String> source,
    required Box<String> target,
  }) async {
    var quarantinedCount = 0;
    for (final entry in source.toMap().entries) {
      final key = entry.key.toString();
      final value = entry.value;
      try {
        final decoded = CategoryModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(value) as Map),
        );
        await target.put(key, jsonEncode(decoded.toJson()));
      } on Object catch (error) {
        quarantinedCount++;
        await _quarantineStore.record(
          boxName: StorageSchema.legacyCategoriesBoxName,
          recordKey: key,
          errorCategory: _errorCategory(error),
          migrationVersion: StorageSchema.currentVersion,
        );
      }
    }
    return quarantinedCount;
  }

  Future<int> _copyAndValidateTransactions({
    required Box<String> source,
    required Box<String> target,
  }) async {
    var quarantinedCount = 0;
    for (final entry in source.toMap().entries) {
      final key = entry.key.toString();
      final value = entry.value;
      try {
        final decoded = FinancialTransactionModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(value) as Map),
        );
        await target.put(key, jsonEncode(decoded.toJson()));
      } on Object catch (error) {
        quarantinedCount++;
        await _quarantineStore.record(
          boxName: StorageSchema.legacyTransactionsBoxName,
          recordKey: key,
          errorCategory: _errorCategory(error),
          migrationVersion: StorageSchema.currentVersion,
        );
      }
    }
    return quarantinedCount;
  }

  Future<int> _copyAndValidateWalletBalances({
    required Box<String> source,
    required Box<String> target,
  }) async {
    var quarantinedCount = 0;
    for (final entry in source.toMap().entries) {
      final key = entry.key.toString();
      final value = entry.value;
      try {
        final decoded = WalletBalanceModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(value) as Map),
        );
        await target.put(key, jsonEncode(decoded.toJson()));
      } on Object catch (error) {
        quarantinedCount++;
        await _quarantineStore.record(
          boxName: StorageSchema.legacyWalletBalancesBoxName,
          recordKey: key,
          errorCategory: _errorCategory(error),
          migrationVersion: StorageSchema.currentVersion,
        );
      }
    }
    return quarantinedCount;
  }

  Future<int> _scanBox<T>({
    required String boxName,
    required Box<String> box,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    var quarantinedCount = 0;
    for (final entry in box.toMap().entries) {
      final key = entry.key.toString();
      final value = entry.value;
      try {
        parser(Map<String, dynamic>.from(jsonDecode(value) as Map));
      } on Object catch (error) {
        quarantinedCount++;
        await _quarantineStore.record(
          boxName: boxName,
          recordKey: key,
          errorCategory: _errorCategory(error),
          migrationVersion: StorageSchema.currentVersion,
        );
        await box.delete(key);
      }
    }
    return quarantinedCount;
  }

  Future<int> _migratePlaintextQuarantine() async {
    final legacyBox = _legacyQuarantineBox;
    if (legacyBox == null || legacyBox.isEmpty) {
      return 0;
    }

    var migratedCount = 0;
    for (final entry in legacyBox.toMap().entries) {
      final storageKey = entry.key.toString();
      final value = entry.value;
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          final boxName = decoded['boxName'] as String? ?? 'unknown';
          final recordKey = decoded['recordKey'] as String? ?? storageKey;
          final reason = decoded['reason'] as String?;
          await _quarantineStore.record(
            boxName: boxName,
            recordKey: recordKey,
            errorCategory: _legacyErrorCategory(reason),
            migrationVersion: StorageSchema.currentVersion,
          );
        } else {
          await _quarantineStore.record(
            boxName: StorageSchema.legacyQuarantineBoxName,
            recordKey: storageKey,
            errorCategory: 'malformedLegacyQuarantineEntry',
            migrationVersion: StorageSchema.currentVersion,
          );
        }
      } on Object {
        await _quarantineStore.record(
          boxName: StorageSchema.legacyQuarantineBoxName,
          recordKey: storageKey,
          errorCategory: 'malformedLegacyQuarantineEntry',
          migrationVersion: StorageSchema.currentVersion,
        );
      }
      migratedCount++;
    }

    await legacyBox.clear();
    return migratedCount;
  }

  String _errorCategory(Object error) {
    return switch (error) {
      FormatException() => 'formatException',
      TypeError() => 'typeError',
      ArgumentError() => 'argumentError',
      _ => error.runtimeType.toString(),
    };
  }

  String _legacyErrorCategory(String? reason) {
    if (reason == null || reason.isEmpty) {
      return 'legacyValidationFailure';
    }
    if (reason.contains('FormatException')) {
      return 'formatException';
    }
    if (reason.contains('TypeError')) {
      return 'typeError';
    }
    return 'legacyValidationFailure';
  }
}
