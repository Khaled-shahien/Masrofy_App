import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/presentation/widgets/transactions/transaction_formatters.dart';

void main() {
  test('obscures money and transaction amounts without changing values', () {
    final transaction = FinancialTransaction(
      id: 'tx',
      type: TransactionType.expense,
      amount: 125,
      categoryId: 'food',
      date: DateTime(2026, 7, 12),
      createdAt: DateTime(2026, 7, 12),
      updatedAt: DateTime(2026, 7, 12),
    );

    expect(formatMoney(125, obscure: true), maskedAmountText);
    expect(
      formatTransactionAmount(transaction, obscure: true),
      '- $maskedAmountText',
    );
    expect(transaction.amount, 125);
  });
}
