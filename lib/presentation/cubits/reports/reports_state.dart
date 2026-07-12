import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/report_filter.dart';
import '../../../domain/entities/report_summary.dart';

enum ReportsStatus { initial, loading, loaded, empty, failure }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsStatus.initial,
    this.filter = const ReportFilter(),
    this.transactions = const [],
    this.categories = const [],
    this.report,
  });

  final ReportsStatus status;
  final ReportFilter filter;
  final List<FinancialTransaction> transactions;
  final List<Category> categories;
  final ReportData? report;

  ReportsState copyWith({
    ReportsStatus? status,
    ReportFilter? filter,
    List<FinancialTransaction>? transactions,
    List<Category>? categories,
    ReportData? report,
    bool clearReport = false,
  }) {
    return ReportsState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      report: clearReport ? null : report ?? this.report,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    transactions,
    categories,
    report,
  ];
}
