import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';

enum TransactionsStatus { initial, loading, ready, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.categories = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  final TransactionsStatus status;
  final List<FinancialTransaction> transactions;
  final List<Category> categories;
  final bool isSaving;
  final String? errorMessage;

  bool get hasTransactions => transactions.isNotEmpty;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<FinancialTransaction>? transactions,
    List<Category>? categories,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    categories,
    isSaving,
    errorMessage,
  ];
}
