import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/transactions/transaction_local_data_source.dart';
import 'package:masrofy/data/repositories/transaction_repository_impl.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/transactions/save_transaction.dart';

void main() {
  test('SaveTransaction creates a validated transaction', () async {
    final dataSource = InMemoryTransactionLocalDataSource();
    addTearDown(dataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final usecase = SaveTransaction(
      repository: repository,
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
    addTearDown(dataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final usecase = SaveTransaction(repository: repository);

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
    addTearDown(dataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);
    final createdAt = DateTime(2026, 7, 10, 9);
    final usecase = SaveTransaction(
      repository: repository,
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
}
