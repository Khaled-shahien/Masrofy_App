import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/report_filter.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/domain/usecases/reports/build_report.dart';

void main() {
  test('resolves week and leap-year month boundaries', () {
    final week = const ReportFilter(
      periodType: ReportPeriodType.thisWeek,
    ).resolveDateRange(DateTime(2026, 7, 12));
    expect(week.start, DateTime(2026, 7, 6));
    expect(week.endExclusive, DateTime(2026, 7, 13));

    final leapFebruary = const ReportFilter(
      periodType: ReportPeriodType.thisMonth,
    ).resolveDateRange(DateTime(2024, 2, 14));
    expect(leapFebruary.dayCount, 29);
  });

  test('aggregates totals, category ratios, trend, and comparison safely', () {
    final report = BuildReport(now: () => DateTime(2026, 7, 15))(
      filter: const ReportFilter(periodType: ReportPeriodType.thisMonth),
      transactions: [
        _transaction(
          id: 'expense-1',
          amount: 300,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(2026, 7, 10),
        ),
        _transaction(
          id: 'expense-2',
          amount: 100,
          type: TransactionType.expense,
          categoryId: 'transport',
          date: DateTime(2026, 7, 11),
        ),
        _transaction(
          id: 'income-1',
          amount: 800,
          type: TransactionType.income,
          categoryId: 'salary',
          date: DateTime(2026, 7, 11),
        ),
        _transaction(
          id: 'previous',
          amount: 250,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(2026, 6, 10),
        ),
      ],
    );

    expect(report.summary.totalExpense, 400);
    expect(report.summary.totalIncome, 800);
    expect(report.summary.netBalance, 400);
    expect(report.summary.highestExpenseTransaction?.id, 'expense-1');
    expect(report.summary.highestSpendingCategory?.categoryId, 'food');
    expect(report.categorySummaries.first.expenseRatio, 0.75);
    expect(report.summary.comparison.previousExpense, 250);
    expect(report.summary.comparison.changeAmount, 150);
    expect(report.timeSeries, hasLength(31));
  });

  test('applies category, wallet, type, and custom date filters', () {
    final report = BuildReport(now: () => DateTime(2026, 7, 15))(
      filter: ReportFilter(
        periodType: ReportPeriodType.custom,
        customStart: DateTime(2026, 7, 10),
        customEnd: DateTime(2026, 7, 11),
        categoryId: 'food',
        wallet: WalletType.cash,
        transactionType: TransactionType.expense,
      ),
      transactions: [
        _transaction(
          id: 'included',
          amount: 300,
          type: TransactionType.expense,
          categoryId: 'food',
          wallet: WalletType.cash,
          date: DateTime(2026, 7, 10),
        ),
        _transaction(
          id: 'wrong-wallet',
          amount: 100,
          type: TransactionType.expense,
          categoryId: 'food',
          wallet: WalletType.instaPay,
          date: DateTime(2026, 7, 10),
        ),
        _transaction(
          id: 'wrong-type',
          amount: 100,
          type: TransactionType.income,
          categoryId: 'food',
          wallet: WalletType.cash,
          date: DateTime(2026, 7, 10),
        ),
      ],
    );

    expect(report.summary.transactionCount, 1);
    expect(report.summary.totalExpense, 300);
    expect(report.summary.totalIncome, 0);
  });

  test('handles zero previous totals without division by zero', () {
    final report = BuildReport(now: () => DateTime(2026, 7, 15))(
      filter: const ReportFilter(periodType: ReportPeriodType.thisMonth),
      transactions: [
        _transaction(
          id: 'expense',
          amount: 300,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(2026, 7, 10),
        ),
      ],
    );

    expect(report.summary.comparison.previousExpense, 0);
    expect(report.summary.comparison.changePercentage, 100);
  });
}

FinancialTransaction _transaction({
  required String id,
  required double amount,
  required TransactionType type,
  required String categoryId,
  required DateTime date,
  WalletType? wallet,
}) {
  return FinancialTransaction(
    id: id,
    type: type,
    amount: amount,
    categoryId: categoryId,
    wallet: wallet,
    date: date,
    createdAt: date,
    updatedAt: date,
  );
}
