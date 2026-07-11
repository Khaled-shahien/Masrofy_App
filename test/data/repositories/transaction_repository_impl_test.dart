import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/transactions/transaction_local_data_source.dart';
import 'package:masrofy/data/repositories/transaction_repository_impl.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';

void main() {
  test('saves, sorts, watches, and deletes local transactions', () async {
    final dataSource = InMemoryTransactionLocalDataSource();
    addTearDown(dataSource.close);
    final repository = TransactionRepositoryImpl(localDataSource: dataSource);

    final snapshots = <List<FinancialTransaction>>[];
    final subscription = repository.watchTransactions().listen(snapshots.add);
    addTearDown(subscription.cancel);

    final older = _transaction(id: 'older', date: DateTime(2026, 7, 10));
    final newer = _transaction(id: 'newer', date: DateTime(2026, 7, 11));
    await repository.saveTransaction(older);
    await repository.saveTransaction(newer);

    final transactions = await repository.getTransactions();
    expect(transactions.map((transaction) => transaction.id), [
      'newer',
      'older',
    ]);

    await repository.deleteTransaction('newer');
    final remaining = await repository.getTransactions();
    expect(remaining.single.id, 'older');
    expect(snapshots, isNotEmpty);
  });
}

FinancialTransaction _transaction({
  required String id,
  required DateTime date,
}) {
  return FinancialTransaction(
    id: id,
    type: TransactionType.expense,
    amount: 50,
    categoryId: 'expense_other',
    date: date,
    createdAt: date,
    updatedAt: date,
  );
}
