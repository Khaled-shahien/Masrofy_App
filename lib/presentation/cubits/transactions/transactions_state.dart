import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_filter.dart';

enum TransactionsStatus { initial, loading, ready, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.categories = const [],
    this.filter = const TransactionFilter(),
    this.isSaving = false,
    this.errorMessage,
  });

  final TransactionsStatus status;
  final List<FinancialTransaction> transactions;
  final List<FinancialTransaction> filteredTransactions;
  final List<Category> categories;
  final TransactionFilter filter;
  final bool isSaving;
  final String? errorMessage;

  bool get hasTransactions => transactions.isNotEmpty;

  bool get hasFilteredTransactions => filteredTransactions.isNotEmpty;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<FinancialTransaction>? transactions,
    List<FinancialTransaction>? filteredTransactions,
    List<Category>? categories,
    TransactionFilter? filter,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    filteredTransactions,
    categories,
    filter,
    isSaving,
    errorMessage,
  ];
}
