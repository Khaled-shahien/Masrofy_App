import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/datasources/transactions/transaction_local_data_source.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/data/repositories/transaction_repository_impl.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/transactions/save_transaction.dart';

void main() {
  test('SaveTransaction creates a validated transaction', () async {
    final dataSource = InMemoryTransactionLocalDataSource();
    final categoryDataSource = _categoryDataSource();
    addTearDown(dataSource.close);
    addTearDown(categoryDataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final usecase = SaveTransaction(
      repository: repository,
      categoryRepository: CategoryRepositoryImpl(
        localDataSource: categoryDataSource,
      ),
      generateId: () => 'tx-1',
      now: () => DateTime(2026, 7, 11, 10),
    );

    await usecase(
      SaveTransactionInput(
        type: TransactionType.expense,
        amount: 100,
        categoryId: 'expense_food_drink',
        date: DateTime(2026, 7, 11),
        note: '  coffee  ',
      ),
    );

    final transaction = (await repository.getTransactions()).single;
    expect(transaction.id, 'tx-1');
    expect(transaction.note, 'coffee');
  });

  test('SaveTransaction rejects invalid amounts', () async {
    final dataSource = InMemoryTransactionLocalDataSource();
    final categoryDataSource = _categoryDataSource();
    addTearDown(dataSource.close);
    addTearDown(categoryDataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final usecase = SaveTransaction(
      repository: repository,
      categoryRepository: CategoryRepositoryImpl(
        localDataSource: categoryDataSource,
      ),
    );

    expect(
      () => usecase(
        SaveTransactionInput(
          type: TransactionType.expense,
          amount: 0,
          categoryId: 'expense_food_drink',
          date: DateTime(2026, 7, 11),
        ),
      ),
      throwsA(isA<TransactionValidationException>()),
    );
  });

  test('SaveTransaction updates an existing transaction ID', () async {
    final dataSource = InMemoryTransactionLocalDataSource();
    final categoryDataSource = _categoryDataSource();
    addTearDown(dataSource.close);
    addTearDown(categoryDataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final createdAt = DateTime(2026, 7, 10, 9);
    final usecase = SaveTransaction(
      repository: repository,
      categoryRepository: CategoryRepositoryImpl(
        localDataSource: categoryDataSource,
      ),
      generateId: () => 'unused',
      now: () => DateTime(2026, 7, 12, 10),
    );

    await usecase(
      SaveTransactionInput(
        id: 'tx-1',
        createdAt: createdAt,
        type: TransactionType.expense,
        amount: 250,
        categoryId: 'expense_food_drink',
        date: DateTime(2026, 7, 11),
      ),
    );

    final transaction = (await repository.getTransactions()).single;
    expect(transaction.id, 'tx-1');
    expect(transaction.createdAt, createdAt);
    expect(transaction.updatedAt, DateTime(2026, 7, 12, 10));
  });

  test('SaveTransaction rejects unknown categories', () async {
    final dataSource = InMemoryTransactionLocalDataSource();
    final categoryDataSource = _categoryDataSource();
    addTearDown(dataSource.close);
    addTearDown(categoryDataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final usecase = SaveTransaction(
      repository: repository,
      categoryRepository: CategoryRepositoryImpl(
        localDataSource: categoryDataSource,
      ),
    );

    expect(
      () => usecase(
        SaveTransactionInput(
          type: TransactionType.expense,
          amount: 20,
          categoryId: 'missing',
          date: DateTime(2026, 7, 11),
        ),
      ),
      throwsA(
        isA<TransactionValidationException>().having(
          (error) => error.reason,
          'reason',
          TransactionValidationFailureReason.unknownCategory,
        ),
      ),
    );
  });

  test('SaveTransaction rejects mismatched category types', () async {
    final dataSource = InMemoryTransactionLocalDataSource();
    final categoryDataSource = _categoryDataSource();
    addTearDown(dataSource.close);
    addTearDown(categoryDataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final usecase = SaveTransaction(
      repository: repository,
      categoryRepository: CategoryRepositoryImpl(
        localDataSource: categoryDataSource,
      ),
    );

    expect(
      () => usecase(
        SaveTransactionInput(
          type: TransactionType.income,
          amount: 20,
          categoryId: 'expense_food_drink',
          date: DateTime(2026, 7, 11),
        ),
      ),
      throwsA(
        isA<TransactionValidationException>().having(
          (error) => error.reason,
          'reason',
          TransactionValidationFailureReason.categoryTypeMismatch,
        ),
      ),
    );
  });
}

InMemoryCategoryLocalDataSource _categoryDataSource() {
  return InMemoryCategoryLocalDataSource([
    CategoryModel.fromDomain(
      const Category(
        id: 'expense_food_drink',
        type: TransactionType.expense,
        name: 'Food',
        localizationKey: null,
        iconKey: 'category',
        colorValue: 0xFF2A9D8F,
        sortOrder: 0,
      ),
    ),
    CategoryModel.fromDomain(
      const Category(
        id: 'income_salary',
        type: TransactionType.income,
        name: 'Salary',
        localizationKey: null,
        iconKey: 'category',
        colorValue: 0xFF2A9D8F,
        sortOrder: 1,
      ),
    ),
  ]);
}
