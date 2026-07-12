import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/dashboard/build_dashboard_summary.dart';

void main() {
  test('aggregates today, current week, and current month totals', () {
    final buildSummary = BuildDashboardSummary(
      now: () => DateTime(2026, 7, 12),
    );

    final summary = buildSummary([
      _transaction(
        id: 'today-expense',
        amount: 100,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 12),
      ),
      _transaction(
        id: 'today-income',
        amount: 250,
        type: TransactionType.income,
        date: DateTime(2026, 7, 12),
      ),
      _transaction(
        id: 'week-expense',
        amount: 40,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 10),
      ),
      _transaction(
        id: 'month-expense',
        amount: 25,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 1),
      ),
      _transaction(
        id: 'old-expense',
        amount: 999,
        type: TransactionType.expense,
        date: DateTime(2026, 6, 30),
      ),
    ]);

    expect(summary.today.income, 250);
    expect(summary.today.expense, 100);
    expect(summary.today.net, 150);
    expect(summary.week.expense, 140);
    expect(summary.month.expense, 165);
  });
}

FinancialTransaction _transaction({
  required String id,
  required double amount,
  required TransactionType type,
  required DateTime date,
}) {
  return FinancialTransaction(
    id: id,
    type: type,
    amount: amount,
    categoryId: 'category',
    date: date,
    createdAt: date,
    updatedAt: date,
  );
}
