import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:masrofy/core/storage/migrations/storage_migration_manager.dart';
import 'package:masrofy/core/storage/storage_key_store.dart';
import 'package:masrofy/core/storage/storage_quarantine_store.dart';
import 'package:masrofy/core/storage/storage_schema.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/models/financial_transaction_model.dart';
import 'package:masrofy/data/models/wallet_balance_model.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';

void main() {
  group('StorageMigrationManager', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('masrofy_migration');
      Hive.init(tempDir.path);
      await Hive.openBox<String>(StorageSchema.metadataBoxName);
      await Hive.openBox<String>(StorageSchema.legacyQuarantineBoxName);
      await Hive.openBox<String>(StorageSchema.legacyCategoriesBoxName);
      await Hive.openBox<String>(StorageSchema.legacyTransactionsBoxName);
      await Hive.openBox<String>(StorageSchema.legacySettingsBoxName);
      await Hive.openBox<String>(StorageSchema.legacyWalletBalancesBoxName);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'migrates valid legacy records and quarantines malformed ones',
      () async {
        final categories = Hive.box<String>(
          StorageSchema.legacyCategoriesBoxName,
        );
        final transactions = Hive.box<String>(
          StorageSchema.legacyTransactionsBoxName,
        );
        final settings = Hive.box<String>(StorageSchema.legacySettingsBoxName);
        final wallets = Hive.box<String>(
          StorageSchema.legacyWalletBalancesBoxName,
        );

        await categories.put(
          'expense_other',
          jsonEncode(
            CategoryModel.fromDomain(
              const Category(
                id: 'expense_other',
                type: TransactionType.expense,
                name: 'Other',
                localizationKey: null,
                iconKey: 'category',
                colorValue: 0xFF607D8B,
                sortOrder: 0,
                isDefault: true,
              ),
            ).toJson(),
          ),
        );
        await transactions.put(
          'tx-1',
          jsonEncode(
            FinancialTransactionModel(
              id: 'tx-1',
              type: TransactionType.expense,
              amount: 50,
              categoryId: 'expense_other',
              date: DateTime(2026, 7, 11),
              createdAt: DateTime(2026, 7, 11),
              updatedAt: DateTime(2026, 7, 11),
            ).toJson(),
          ),
        );
        await transactions.put(
          'broken',
          jsonEncode({
            'id': 'broken',
            'type': 'expense',
            'amount': 10,
            'categoryId': 'expense_other',
            'date': 'invalid-date',
            'createdAt': '2026-07-11T00:00:00.000',
            'updatedAt': '2026-07-11T00:00:00.000',
          }),
        );
        await settings.put('locale', 'ar');
        await wallets.put(
          'cash',
          jsonEncode(
            WalletBalanceModel(
              walletType: WalletType.cash,
              baseBalance: 100,
              updatedAt: DateTime(2026, 7, 11),
            ).toJson(),
          ),
        );

        final manager = StorageMigrationManager(
          encryptionService: StorageEncryptionService(
            InMemoryStorageKeyStore(),
          ),
          quarantineStore: StorageQuarantineStore(
            await Hive.openBox<String>(
              StorageSchema.quarantineBoxName,
              encryptionCipher: HiveAesCipher(
                await StorageEncryptionService(
                  InMemoryStorageKeyStore(),
                ).readOrCreateKeyBytes(),
              ),
            ),
          ),
          metadataBox: Hive.box<String>(StorageSchema.metadataBoxName),
          legacyQuarantineBox: Hive.box<String>(
            StorageSchema.legacyQuarantineBoxName,
          ),
          encryptedDataExists: false,
        );

        final result = await manager.migrate();

        expect(result.success, isTrue);
        expect(result.storedSchemaVersion, StorageSchema.currentVersion);
        expect(result.appliedMigrations, isNotEmpty);
        expect(result.quarantinedRecordCount, 1);
        expect(Hive.box<String>(StorageSchema.transactionsBoxName).length, 1);
        expect(Hive.box<String>(StorageSchema.quarantineBoxName).length, 1);
        final quarantineJson =
            jsonDecode(
                  Hive.box<String>(
                    StorageSchema.quarantineBoxName,
                  ).values.single,
                )
                as Map<String, Object?>;
        expect(quarantineJson, isNot(contains('rawValue')));
        expect(quarantineJson['errorCategory'], 'formatException');
      },
    );

    test('is idempotent when migration is rerun', () async {
      final encryptionService = StorageEncryptionService(
        InMemoryStorageKeyStore(),
      );
      final quarantineBox = await Hive.openBox<String>(
        StorageSchema.quarantineBoxName,
        encryptionCipher: HiveAesCipher(
          await encryptionService.readOrCreateKeyBytes(),
        ),
      );
      final manager = StorageMigrationManager(
        encryptionService: encryptionService,
        quarantineStore: StorageQuarantineStore(quarantineBox),
        metadataBox: Hive.box<String>(StorageSchema.metadataBoxName),
        legacyQuarantineBox: Hive.box<String>(
          StorageSchema.legacyQuarantineBoxName,
        ),
        encryptedDataExists: false,
      );

      final first = await manager.migrate();
      final second = await manager.migrate();

      expect(first.success, isTrue);
      expect(second.success, isTrue);
      expect(second.appliedMigrations, isEmpty);
    });
  });
}
