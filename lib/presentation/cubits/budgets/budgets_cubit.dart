import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/budget.dart';
import '../../../domain/entities/budget_period.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/usecases/budgets/budget_usecase_exception.dart';
import '../../../domain/usecases/budgets/calculate_budget_progress.dart';
import '../../../domain/usecases/budgets/delete_budget.dart';
import '../../../domain/usecases/budgets/save_budget.dart';
import '../../../domain/usecases/budgets/watch_budgets.dart';
import '../../../domain/usecases/categories/watch_categories.dart';
import '../../../domain/usecases/transactions/watch_transactions.dart';
import 'budgets_state.dart';

class BudgetsCubit extends Cubit<BudgetsState> {
  BudgetsCubit({
    required WatchBudgets watchBudgets,
    required WatchTransactions watchTransactions,
    required WatchCategories watchCategories,
    required SaveBudget saveBudget,
    required DeleteBudget deleteBudget,
    required CalculateBudgetProgress calculateBudgetProgress,
    DateTime Function()? now,
  }) : _watchBudgets = watchBudgets,
       _watchTransactions = watchTransactions,
       _watchCategories = watchCategories,
       _saveBudget = saveBudget,
       _deleteBudget = deleteBudget,
       _calculateBudgetProgress = calculateBudgetProgress,
       super(BudgetsState(selectedPeriod: _initialPeriod(now)));

  final WatchBudgets _watchBudgets;
  final WatchTransactions _watchTransactions;
  final WatchCategories _watchCategories;
  final SaveBudget _saveBudget;
  final DeleteBudget _deleteBudget;
  final CalculateBudgetProgress _calculateBudgetProgress;

  StreamSubscription<List<Budget>>? _budgetsSubscription;
  StreamSubscription<List<FinancialTransaction>>? _transactionsSubscription;
  StreamSubscription<List<Category>>? _categoriesSubscription;

  var _budgetsReady = false;
  var _transactionsReady = false;
  var _categoriesReady = false;

  void load() {
    emit(state.copyWith(status: BudgetsStatus.loading, clearFailure: true));
    _budgetsReady = false;
    _transactionsReady = false;
    _categoriesReady = false;
    unawaited(_transactionsSubscription?.cancel());
    unawaited(_categoriesSubscription?.cancel());
    _watchSelectedPeriod();
    _transactionsSubscription = _watchTransactions().listen(
      (transactions) {
        _transactionsReady = true;
        emit(state.copyWith(transactions: transactions, clearFailure: true));
        _emitCalculatedState();
      },
      onError: _emitStorageFailure,
    );
    _categoriesSubscription =
        _watchCategories(
          type: TransactionType.expense,
          includeHidden: true,
        ).listen(
          (categories) {
            _categoriesReady = true;
            emit(state.copyWith(categories: categories, clearFailure: true));
            _emitCalculatedState();
          },
          onError: _emitStorageFailure,
        );
  }

  void previousMonth() {
    _selectPeriod(state.selectedPeriod.previous);
  }

  void nextMonth() {
    _selectPeriod(state.selectedPeriod.next);
  }

  Future<bool> save({
    required String categoryId,
    required double amount,
    String? id,
    String? note,
  }) async {
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      await _saveBudget(
        SaveBudgetInput(
          id: id,
          categoryId: categoryId,
          amount: amount,
          period: state.selectedPeriod,
          note: note,
        ),
      );
      emit(state.copyWith(isSaving: false, clearFailure: true));
      return true;
    } on DuplicateBudgetException {
      emit(
        state.copyWith(
          isSaving: false,
          failure: BudgetsFailure.duplicate,
        ),
      );
      return false;
    } on InvalidBudgetException {
      emit(
        state.copyWith(
          isSaving: false,
          failure: BudgetsFailure.validation,
        ),
      );
      return false;
    } on BudgetCategoryException {
      emit(
        state.copyWith(
          isSaving: false,
          failure: BudgetsFailure.invalidCategory,
        ),
      );
      return false;
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          failure: BudgetsFailure.storage,
        ),
      );
      return false;
    }
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      await _deleteBudget(id);
      emit(state.copyWith(isSaving: false, clearFailure: true));
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          failure: BudgetsFailure.storage,
        ),
      );
    }
  }

  void retry() {
    load();
  }

  void _selectPeriod(BudgetPeriod period) {
    if (period == state.selectedPeriod) {
      return;
    }
    _budgetsReady = false;
    emit(
      state.copyWith(
        selectedPeriod: period,
        status: BudgetsStatus.loading,
        budgets: const [],
        progress: const [],
        clearFailure: true,
      ),
    );
    _watchSelectedPeriod();
  }

  void _watchSelectedPeriod() {
    unawaited(_budgetsSubscription?.cancel());
    _budgetsSubscription = _watchBudgets(period: state.selectedPeriod).listen(
      (budgets) {
        _budgetsReady = true;
        emit(state.copyWith(budgets: budgets, clearFailure: true));
        _emitCalculatedState();
      },
      onError: _emitStorageFailure,
    );
  }

  void _emitCalculatedState() {
    if (!_budgetsReady || !_transactionsReady || !_categoriesReady) {
      return;
    }

    final progress = _calculateBudgetProgress(
      budgets: state.budgets,
      transactions: state.transactions,
    );
    emit(
      state.copyWith(
        status: progress.isEmpty ? BudgetsStatus.empty : BudgetsStatus.loaded,
        progress: progress,
        clearFailure: true,
      ),
    );
  }

  void _emitStorageFailure(Object error, StackTrace stackTrace) {
    emit(
      state.copyWith(
        status: BudgetsStatus.failure,
        failure: BudgetsFailure.storage,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _budgetsSubscription?.cancel();
    await _transactionsSubscription?.cancel();
    await _categoriesSubscription?.cancel();
    return super.close();
  }
}

BudgetPeriod _initialPeriod(DateTime Function()? now) {
  final value = now?.call() ?? DateTime.now();
  return BudgetPeriod.fromDate(value);
}
