import '../../entities/financial_transaction.dart';
import '../../entities/report_filter.dart';
import '../../entities/report_summary.dart';
import '../../entities/transaction_type.dart';

/// Aggregates filtered local transactions into report-ready summaries.
class BuildReport {
  const BuildReport({this._now});

  final DateTime Function()? _now;

  ReportData call({
    required Iterable<FinancialTransaction> transactions,
    required ReportFilter filter,
  }) {
    final now = _now?.call() ?? DateTime.now();
    final range = filter.resolveDateRange(now);
    final currentTransactions = _filterTransactions(
      transactions,
      filter: filter,
      range: range,
    );
    final previousTransactions = _filterTransactions(
      transactions,
      filter: filter,
      range: range.previousEquivalent,
    );
    final totalIncome = _sumType(
      currentTransactions,
      TransactionType.income,
    );
    final totalExpense = _sumType(
      currentTransactions,
      TransactionType.expense,
    );
    final previousExpense = _sumType(
      previousTransactions,
      TransactionType.expense,
    );
    final categorySummaries = _buildCategorySummaries(
      currentTransactions,
      totalExpense: totalExpense,
      totalIncome: totalIncome,
    );
    final comparison = ReportComparisonSummary(
      previousExpense: previousExpense,
      changeAmount: totalExpense - previousExpense,
      changePercentage: _changePercentage(
        current: totalExpense,
        previous: previousExpense,
      ),
    );

    return ReportData(
      filter: filter,
      range: range,
      transactions: currentTransactions,
      summary: ReportSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netBalance: totalIncome - totalExpense,
        transactionCount: currentTransactions.length,
        averageDailyExpense: totalExpense / range.dayCount,
        highestExpenseTransaction: _highestExpense(currentTransactions),
        highestSpendingCategory: categorySummaries
            .where((summary) => summary.expenseAmount > 0)
            .firstOrNull,
        comparison: comparison,
      ),
      categorySummaries: categorySummaries,
      timeSeries: _buildTimeSeries(currentTransactions, range),
    );
  }

  List<FinancialTransaction> _filterTransactions(
    Iterable<FinancialTransaction> transactions, {
    required ReportFilter filter,
    required ReportDateRange range,
  }) {
    return transactions
        .where(
          (transaction) =>
              range.contains(transaction.date) &&
              (filter.categoryId == null ||
                  transaction.categoryId == filter.categoryId) &&
              (filter.wallet == null || transaction.wallet == filter.wallet) &&
              (filter.transactionType == null ||
                  transaction.type == filter.transactionType),
        )
        .toList(growable: false);
  }

  List<CategorySpendingSummary> _buildCategorySummaries(
    Iterable<FinancialTransaction> transactions, {
    required double totalExpense,
    required double totalIncome,
  }) {
    final byCategory = <String, ({double income, double expense})>{};
    for (final transaction in transactions) {
      final current =
          byCategory[transaction.categoryId] ?? (income: 0.0, expense: 0.0);
      byCategory[transaction.categoryId] = switch (transaction.type) {
        TransactionType.income => (
          income: current.income + transaction.amount,
          expense: current.expense,
        ),
        TransactionType.expense => (
          income: current.income,
          expense: current.expense + transaction.amount,
        ),
      };
    }

    final summaries =
        byCategory.entries.map((entry) {
          return CategorySpendingSummary(
            categoryId: entry.key,
            expenseAmount: entry.value.expense,
            incomeAmount: entry.value.income,
            expenseRatio: totalExpense == 0
                ? 0
                : entry.value.expense / totalExpense,
            incomeRatio: totalIncome == 0
                ? 0
                : entry.value.income / totalIncome,
          );
        }).toList()..sort((left, right) {
          final expenseComparison = right.expenseAmount.compareTo(
            left.expenseAmount,
          );
          if (expenseComparison != 0) {
            return expenseComparison;
          }
          return right.incomeAmount.compareTo(left.incomeAmount);
        });
    return List<CategorySpendingSummary>.unmodifiable(summaries);
  }

  List<TimeSeriesPoint> _buildTimeSeries(
    Iterable<FinancialTransaction> transactions,
    ReportDateRange range,
  ) {
    final totalsByDay = <DateTime, ({double income, double expense})>{};
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      final current = totalsByDay[day] ?? (income: 0.0, expense: 0.0);
      totalsByDay[day] = switch (transaction.type) {
        TransactionType.income => (
          income: current.income + transaction.amount,
          expense: current.expense,
        ),
        TransactionType.expense => (
          income: current.income,
          expense: current.expense + transaction.amount,
        ),
      };
    }

    return List<TimeSeriesPoint>.generate(range.dayCount, (index) {
      final day = range.start.add(Duration(days: index));
      final totals = totalsByDay[day] ?? (income: 0.0, expense: 0.0);
      return TimeSeriesPoint(
        date: day,
        incomeAmount: totals.income,
        expenseAmount: totals.expense,
      );
    }, growable: false);
  }

  double _sumType(
    Iterable<FinancialTransaction> transactions,
    TransactionType type,
  ) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  FinancialTransaction? _highestExpense(
    Iterable<FinancialTransaction> transactions,
  ) {
    FinancialTransaction? highest;
    for (final transaction in transactions) {
      if (transaction.type != TransactionType.expense) {
        continue;
      }
      if (highest == null || transaction.amount > highest.amount) {
        highest = transaction;
      }
    }
    return highest;
  }

  double _changePercentage({
    required double current,
    required double previous,
  }) {
    if (previous == 0) {
      return current == 0 ? 0 : 100;
    }
    return ((current - previous) / previous) * 100;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    for (final value in this) {
      return value;
    }
    return null;
  }
}
