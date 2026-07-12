import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/models/financial_transaction_model.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';

void main() {
  test('FinancialTransactionModel round-trips between domain and JSON', () {
    final transaction = FinancialTransaction(
      id: 'tx-1',
      type: TransactionType.expense,
      amount: 125.5,
      categoryId: 'expense_food_drink',
      date: DateTime(2026, 7, 11),
      note: 'Lunch',
      wallet: WalletType.cash,
      personName: 'Mona',
      createdAt: DateTime(2026, 7, 11, 10),
      updatedAt: DateTime(2026, 7, 11, 10, 5),
    );

    final model = FinancialTransactionModel.fromDomain(transaction);
    final decoded = FinancialTransactionModel.fromJson(model.toJson());

    expect(decoded.toDomain(), transaction);
  });

  test(
    'FinancialTransactionModel accepts legacy records without timestamps',
    () {
      final model = FinancialTransactionModel.fromJson({
        'id': 'legacy',
        'amount': 20,
        'categoryId': 'expense_other',
        'date': '2026-07-11T00:00:00.000',
        'futureField': 'ignored',
      });

      expect(model.type, TransactionType.expense);
      expect(model.amount, 20);
      expect(model.wallet, isNull);
      expect(model.createdAt, DateTime.parse('2026-07-11T00:00:00.000'));
      expect(model.updatedAt, DateTime.parse('2026-07-11T00:00:00.000'));
    },
  );

  test('FinancialTransactionModel rejects invalid dates and enums', () {
    expect(
      () => FinancialTransactionModel.fromJson({
        'id': 'bad-date',
        'amount': 20,
        'categoryId': 'expense_other',
        'type': 'expense',
        'date': 'invalid-date',
        'createdAt': '2026-07-11T00:00:00.000',
        'updatedAt': '2026-07-11T00:00:00.000',
      }),
      throwsFormatException,
    );

    expect(
      () => FinancialTransactionModel.fromJson({
        'id': 'bad-enum',
        'amount': 20,
        'categoryId': 'expense_other',
        'type': 'not-a-type',
        'date': '2026-07-11T00:00:00.000',
        'createdAt': '2026-07-11T00:00:00.000',
        'updatedAt': '2026-07-11T00:00:00.000',
      }),
      throwsFormatException,
    );
  });
}
