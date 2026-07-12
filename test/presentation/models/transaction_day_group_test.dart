import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/presentation/models/transaction_day_group.dart';
import 'package:masrofy/presentation/widgets/transactions/transaction_formatters.dart';

void main() {
  test('groups adjacent same-day transactions under formatted labels', () {
    final firstDay = DateTime(2026, 7, 12);
    final previousDay = DateTime(2026, 7, 11);

    final groups = groupTransactionsByDay(
      [
        _transaction('first', firstDay),
        _transaction('second', firstDay),
        _transaction('third', previousDay),
      ],
      localeName: 'en',
    );

    expect(groups, hasLength(2));
    expect(groups.first.dayLabel, formatDay(firstDay, localeName: 'en'));
    expect(groups.first.transactions.map((transaction) => transaction.id), [
      'first',
      'second',
    ]);
    expect(groups.last.dayLabel, formatDay(previousDay, localeName: 'en'));
  });
}

FinancialTransaction _transaction(String id, DateTime date) {
  return FinancialTransaction(
    id: id,
    type: TransactionType.expense,
    amount: 10,
    categoryId: 'category',
    date: date,
    createdAt: date,
    updatedAt: date,
  );
}
