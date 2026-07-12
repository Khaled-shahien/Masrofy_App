import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_filter.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';

void main() {
  const category = Category(
    id: 'food',
    type: TransactionType.expense,
    name: 'Food',
    localizationKey: 'categoryExpenseFoodAndDrink',
    iconKey: 'restaurant',
    colorValue: 0xFF2A9D8F,
    sortOrder: 0,
  );

  test('matches query against notes, person, category, and amount text', () {
    final transaction = _transaction(
      note: 'Weekly groceries',
      personName: 'Mona',
    );

    expect(
      const TransactionFilter(query: 'grocer').matches(
        transaction,
        category: category,
      ),
      isTrue,
    );
    expect(
      const TransactionFilter(query: 'mona').matches(
        transaction,
        category: category,
      ),
      isTrue,
    );
    expect(
      const TransactionFilter(query: 'food').matches(
        transaction,
        category: category,
      ),
      isTrue,
    );
    expect(
      const TransactionFilter(query: '125').matches(
        transaction,
        category: category,
      ),
      isTrue,
    );
  });

  test('applies typed filters without mutating transaction data', () {
    final transaction = _transaction(
      note: 'Weekly groceries',
      personName: 'Mona',
    );
    final filter = TransactionFilter(
      type: TransactionType.expense,
      categoryId: 'food',
      wallet: WalletType.cash,
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 31),
      minAmount: 100,
      maxAmount: 200,
      hasPersonName: true,
      hasNote: true,
    );

    expect(filter.matches(transaction, category: category), isTrue);
    expect(
      filter.copyWith(minAmount: 200).matches(transaction, category: category),
      isFalse,
    );
  });
}

FinancialTransaction _transaction({
  String? note,
  String? personName,
}) {
  return FinancialTransaction(
    id: 'tx-1',
    type: TransactionType.expense,
    amount: 125,
    categoryId: 'food',
    wallet: WalletType.cash,
    date: DateTime(2026, 7, 10),
    note: note,
    personName: personName,
    createdAt: DateTime(2026, 7, 10),
    updatedAt: DateTime(2026, 7, 10),
  );
}
