import 'package:equatable/equatable.dart';

import '../../../domain/entities/budget.dart';
import '../../../domain/entities/budget_period.dart';
import '../../../domain/entities/budget_progress.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';

enum BudgetsStatus { initial, loading, loaded, empty, failure }

enum BudgetsFailure { storage, validation, duplicate, invalidCategory }

class BudgetsState extends Equatable {
  BudgetsState({
    BudgetPeriod? selectedPeriod,
    this.status = BudgetsStatus.initial,
    this.budgets = const [],
    this.transactions = const [],
    this.categories = const [],
    this.progress = const [],
    this.isSaving = false,
    this.failure,
  }) : selectedPeriod = selectedPeriod ?? BudgetPeriod.fromDate(DateTime.now());

  final BudgetPeriod selectedPeriod;
  final BudgetsStatus status;
  final List<Budget> budgets;
  final List<FinancialTransaction> transactions;
  final List<Category> categories;
  final List<BudgetProgress> progress;
  final bool isSaving;
  final BudgetsFailure? failure;

  bool get hasProgress => progress.isNotEmpty;

  BudgetsState copyWith({
    BudgetPeriod? selectedPeriod,
    BudgetsStatus? status,
    List<Budget>? budgets,
    List<FinancialTransaction>? transactions,
    List<Category>? categories,
    List<BudgetProgress>? progress,
    bool? isSaving,
    BudgetsFailure? failure,
    bool clearFailure = false,
  }) {
    return BudgetsState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      progress: progress ?? this.progress,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    selectedPeriod,
    status,
    budgets,
    transactions,
    categories,
    progress,
    isSaving,
    failure,
  ];
}
