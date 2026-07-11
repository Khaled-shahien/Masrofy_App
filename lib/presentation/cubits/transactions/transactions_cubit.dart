import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/usecases/categories/watch_categories.dart';
import '../../../domain/usecases/transactions/delete_transaction.dart';
import '../../../domain/usecases/transactions/save_transaction.dart';
import '../../../domain/usecases/transactions/watch_transactions.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({
    required WatchTransactions watchTransactions,
    required WatchCategories watchCategories,
    required SaveTransaction saveTransaction,
    required DeleteTransaction deleteTransaction,
  }) : _watchTransactions = watchTransactions,
       _watchCategories = watchCategories,
       _saveTransaction = saveTransaction,
       _deleteTransaction = deleteTransaction,
       super(const TransactionsState());

  final WatchTransactions _watchTransactions;
  final WatchCategories _watchCategories;
  final SaveTransaction _saveTransaction;
  final DeleteTransaction _deleteTransaction;

  StreamSubscription<List<FinancialTransaction>>? _transactionsSubscription;
  StreamSubscription<List<Category>>? _categoriesSubscription;

  void load() {
    emit(state.copyWith(status: TransactionsStatus.loading, clearError: true));
    unawaited(_transactionsSubscription?.cancel());
    unawaited(_categoriesSubscription?.cancel());

    _transactionsSubscription = _watchTransactions().listen(
      (transactions) => emit(
        state.copyWith(
          status: TransactionsStatus.ready,
          transactions: transactions,
          clearError: true,
        ),
      ),
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            status: TransactionsStatus.failure,
            errorMessage: 'تعذر تحميل المعاملات',
          ),
        );
      },
    );

    _categoriesSubscription = _watchCategories(includeHidden: false).listen(
      (categories) => emit(state.copyWith(categories: categories)),
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            status: TransactionsStatus.failure,
            errorMessage: 'تعذر تحميل التصنيفات',
          ),
        );
      },
    );
  }

  Future<bool> save(SaveTransactionInput input) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _saveTransaction(input);
      emit(state.copyWith(isSaving: false, clearError: true));
      return true;
    } on TransactionValidationException catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.message));
      return false;
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'تعذر حفظ المعاملة',
        ),
      );
      return false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteTransaction(id);
    } on Object {
      emit(state.copyWith(errorMessage: 'تعذر حذف المعاملة'));
    }
  }

  @override
  Future<void> close() async {
    await _transactionsSubscription?.cancel();
    await _categoriesSubscription?.cancel();
    return super.close();
  }
}
