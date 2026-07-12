import 'package:equatable/equatable.dart';

import 'financial_transaction.dart';
import 'report_filter.dart';

class CategorySpendingSummary extends Equatable {
  const CategorySpendingSummary({
    required this.categoryId,
    required this.expenseAmount,
    required this.incomeAmount,
    required this.expenseRatio,
    required this.incomeRatio,
  });

  final String categoryId;
  final double expenseAmount;
  final double incomeAmount;
  final double expenseRatio;
  final double incomeRatio;

  @override
  List<Object?> get props => [
    categoryId,
    expenseAmount,
    incomeAmount,
    expenseRatio,
    incomeRatio,
  ];
}

class TimeSeriesPoint extends Equatable {
  const TimeSeriesPoint({
    required this.date,
    required this.incomeAmount,
    required this.expenseAmount,
  });

  final DateTime date;
  final double incomeAmount;
  final double expenseAmount;

  @override
  List<Object?> get props => [date, incomeAmount, expenseAmount];
}

class ReportComparisonSummary extends Equatable {
  const ReportComparisonSummary({
    required this.previousExpense,
    required this.changeAmount,
    required this.changePercentage,
  });

  final double previousExpense;
  final double changeAmount;
  final double changePercentage;

  @override
  List<Object?> get props => [
    previousExpense,
    changeAmount,
    changePercentage,
  ];
}

class ReportSummary extends Equatable {
  const ReportSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.transactionCount,
    required this.averageDailyExpense,
    required this.comparison,
    this.highestExpenseTransaction,
    this.highestSpendingCategory,
  });

  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int transactionCount;
  final double averageDailyExpense;
  final FinancialTransaction? highestExpenseTransaction;
  final CategorySpendingSummary? highestSpendingCategory;
  final ReportComparisonSummary comparison;

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    netBalance,
    transactionCount,
    averageDailyExpense,
    highestExpenseTransaction,
    highestSpendingCategory,
    comparison,
  ];
}

class ReportData extends Equatable {
  const ReportData({
    required this.filter,
    required this.range,
    required this.transactions,
    required this.summary,
    required this.categorySummaries,
    required this.timeSeries,
  });

  final ReportFilter filter;
  final ReportDateRange range;
  final List<FinancialTransaction> transactions;
  final ReportSummary summary;
  final List<CategorySpendingSummary> categorySummaries;
  final List<TimeSeriesPoint> timeSeries;

  bool get hasTransactions => summary.transactionCount > 0;

  bool get hasExpenses => summary.totalExpense > 0;

  @override
  List<Object?> get props => [
    filter,
    range,
    transactions,
    summary,
    categorySummaries,
    timeSeries,
  ];
}
