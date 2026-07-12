import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:masrofy/app/masrofy_bootstrap_app.dart';
import 'package:masrofy/core/security/app_lock_service.dart';
import 'package:masrofy/core/storage/storage_key_store.dart';
import 'package:masrofy/core/storage/storage_schema.dart';
import 'package:masrofy/data/backup/backup_restore_service.dart';
import 'package:masrofy/data/catalog/default_category_catalog.dart';
import 'package:masrofy/data/models/financial_transaction_model.dart';
import 'package:masrofy/di/service_locator.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/repositories/category_repository.dart';
import 'package:masrofy/domain/repositories/transaction_repository.dart';
import 'package:masrofy/presentation/cubits/settings/app_settings_cubit.dart';

void main() {
  group('startup bootstrap and dependency registration', () {
    late Directory tempDir;
    late InMemoryStorageKeyStore keyStore;
    late HiveAesCipher cipher;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('masrofy_bootstrap');
      Hive.init(tempDir.path);
      keyStore = InMemoryStorageKeyStore();
      cipher = HiveAesCipher(
        await StorageEncryptionService(keyStore).readOrCreateKeyBytes(),
      );

      await Hive.openBox<String>(StorageSchema.metadataBoxName);
      await Hive.openBox<String>(StorageSchema.quarantineBoxName);
      await Hive.openBox<String>(
        StorageSchema.categoriesBoxName,
        encryptionCipher: cipher,
      );
      await Hive.openBox<String>(
        StorageSchema.transactionsBoxName,
        encryptionCipher: cipher,
      );
      await Hive.openBox<String>(
        StorageSchema.settingsBoxName,
        encryptionCipher: cipher,
      );
      await Hive.openBox<String>(
        StorageSchema.walletBalancesBoxName,
        encryptionCipher: cipher,
      );
      await Hive.openBox<String>(
        StorageSchema.budgetsBoxName,
        encryptionCipher: cipher,
      );
    });

    tearDown(() async {
      await serviceLocator.reset();
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('keeps existing transactions and does not import demo data', () async {
      final transactions = Hive.box<String>(StorageSchema.transactionsBoxName);
      await transactions.put(
        'existing',
        jsonEncode(
          FinancialTransactionModel(
            id: 'existing',
            type: TransactionType.expense,
            amount: 42,
            categoryId: 'expense_other',
            date: DateTime(2026, 7, 11),
            createdAt: DateTime(2026, 7, 11),
            updatedAt: DateTime(2026, 7, 11),
          ).toJson(),
        ),
      );

      await configureDependencies();

      final repository = serviceLocator<TransactionRepository>();
      final transactionsList = await repository.getTransactions();

      expect(transactionsList, hasLength(1));
      expect(transactionsList.single.id, 'existing');
    });

    test('seeds default categories when storage is empty', () async {
      await configureDependencies();

      final repository = serviceLocator<CategoryRepository>();
      final categories = await repository.getCategories(includeHidden: true);

      expect(categories, hasLength(defaultCategories.length));
      expect(
        categories.map((category) => category.id),
        containsAll(defaultCategories.map((category) => category.id)),
      );
    });

    test(
      'does not duplicate registrations on repeated configuration',
      () async {
        await configureDependencies();

        final firstRouter = serviceLocator<GoRouter>();
        final firstSettingsCubit = serviceLocator<AppSettingsCubit>();

        await configureDependencies();

        expect(identical(firstRouter, serviceLocator<GoRouter>()), isTrue);
        expect(
          identical(firstSettingsCubit, serviceLocator<AppSettingsCubit>()),
          isTrue,
        );
        expect(serviceLocator<BackupRestoreService>(), isNotNull);
        expect(serviceLocator<AppLockService>(), isNotNull);
      },
    );
  });

  testWidgets('shows a safe failure state and retries successfully', (
    tester,
  ) async {
    var shouldFail = true;

    await tester.pumpWidget(
      MasrofyBootstrapApp(
        locale: const Locale('ar'),
        bootstrap: () async {
          if (shouldFail) {
            throw StateError('startup failed');
          }
        },
        appBuilder: (_) => const Placeholder(key: ValueKey('app-ready')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر بدء التطبيق'), findsOneWidget);
    expect(find.byKey(const ValueKey('app-ready')), findsNothing);

    shouldFail = false;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-ready')), findsOneWidget);
  });
}
