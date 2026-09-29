import '../../entities/dashboard_summary.dart';
import '../../entities/financial_transaction.dart';
import '../../entities/transaction_type.dart';

class BuildDashboardSummary {
  const BuildDashboardSummary({this._now});

  final DateTime Function()? _now;

  DashboardSummary call(Iterable<FinancialTransaction> transactions) {
    final now = _now?.call() ?? DateTime.now();
    return DashboardSummary(
      today: _sumFor(transactions, (transaction) {
        return _isSameDay(transaction.date, now);
      }),
      week: _sumFor(transactions, (transaction) {
        return _isInCurrentWeek(transaction.date, now);
      }),
      month: _sumFor(transactions, (transaction) {
        return _isSameMonth(transaction.date, now);
      }),
    );
  }

  DashboardPeriodTotals _sumFor(
    Iterable<FinancialTransaction> transactions,
    bool Function(FinancialTransaction transaction) test,
  ) {
    var income = 0.0;
    var expense = 0.0;
    for (final transaction in transactions.where(test)) {
      switch (transaction.type) {
        case TransactionType.income:
          income += transaction.amount;
        case TransactionType.expense:
          expense += transaction.amount;
      }
    }
    return DashboardPeriodTotals(income: income, expense: expense);
  }
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

bool _isSameMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}

bool _isInCurrentWeek(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final nextWeek = weekStart.add(const Duration(days: 7));
  final value = DateTime(date.year, date.month, date.day);
  return !value.isBefore(weekStart) && value.isBefore(nextWeek);
}
