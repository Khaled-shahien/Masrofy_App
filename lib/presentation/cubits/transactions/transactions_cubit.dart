import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../domain/usecases/categories/watch_categories.dart';
import '../../../domain/usecases/transactions/delete_transaction.dart';
import '../../../domain/usecases/transactions/save_transaction.dart';
import '../../../domain/usecases/transactions/watch_transactions.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({
    required this._watchTransactions,
    required WatchCategories watchCategories,
    required this._saveTransaction,
    required this._deleteTransaction,
  }) : _watchCategories = watchCategories,
       super(const TransactionsState());

  final WatchTransactions _watchTransactions;
  final WatchCategories _watchCategories;
  final SaveTransaction _saveTransaction;
  final DeleteTransaction _deleteTransaction;

  StreamSubscription<List<FinancialTransaction>>? _transactionsSubscription;
  StreamSubscription<List<Category>>? _categoriesSubscription;
  Timer? _searchDebounce;

  void load() {
    emit(state.copyWith(status: TransactionsStatus.loading, clearError: true));
    unawaited(_transactionsSubscription?.cancel());
    unawaited(_categoriesSubscription?.cancel());

    _transactionsSubscription = _watchTransactions().listen(
      (transactions) => _emitData(transactions: transactions),
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            status: TransactionsStatus.failure,
            errorMessage: 'تعذر تحميل المعاملات',
          ),
        );
      },
    );

    _categoriesSubscription = _watchCategories(includeHidden: true).listen(
      (categories) => _emitData(categories: categories),
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
      emit(state.copyWith(isSaving: false, errorMessage: error.reason.name));
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

  void updateSearchQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _setFilter(state.filter.copyWith(query: query));
    });
  }

  void setTypeFilter(TransactionType? type) {
    _setFilter(state.filter.copyWith(type: type, clearType: type == null));
  }

  void setCategoryFilter(String? categoryId) {
    _setFilter(
      state.filter.copyWith(
        categoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );
  }

  void setWalletFilter(WalletType? wallet) {
    _setFilter(
      state.filter.copyWith(wallet: wallet, clearWallet: wallet == null),
    );
  }

  void setDateRange({DateTime? startDate, DateTime? endDate}) {
    _setFilter(
      state.filter.copyWith(
        startDate: startDate,
        endDate: endDate,
        clearStartDate: startDate == null,
        clearEndDate: endDate == null,
      ),
    );
  }

  void setAmountRange({double? minAmount, double? maxAmount}) {
    _setFilter(
      state.filter.copyWith(
        minAmount: minAmount,
        maxAmount: maxAmount,
        clearMinAmount: minAmount == null,
        clearMaxAmount: maxAmount == null,
      ),
    );
  }

  void setHasPersonName(bool? value) {
    _setFilter(
      state.filter.copyWith(
        hasPersonName: value,
        clearHasPersonName: value == null,
      ),
    );
  }

  void setHasNote(bool? value) {
    _setFilter(
      state.filter.copyWith(hasNote: value, clearHasNote: value == null),
    );
  }

  void clearFilters() {
    _searchDebounce?.cancel();
    _setFilter(const TransactionFilter());
  }

  void _setFilter(TransactionFilter filter) {
    emit(
      state.copyWith(
        filter: filter,
        filteredTransactions: _filterTransactions(
          state.transactions,
          state.categories,
          filter,
        ),
        clearError: true,
      ),
    );
  }

  void _emitData({
    List<FinancialTransaction>? transactions,
    List<Category>? categories,
  }) {
    final nextTransactions = transactions ?? state.transactions;
    final nextCategories = categories ?? state.categories;
    emit(
      state.copyWith(
        status: TransactionsStatus.ready,
        transactions: nextTransactions,
        categories: nextCategories,
        filteredTransactions: _filterTransactions(
          nextTransactions,
          nextCategories,
          state.filter,
        ),
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    await _transactionsSubscription?.cancel();
    await _categoriesSubscription?.cancel();
    return super.close();
  }
}

List<FinancialTransaction> _filterTransactions(
  List<FinancialTransaction> transactions,
  List<Category> categories,
  TransactionFilter filter,
) {
  final categoriesById = {
    for (final category in categories) category.id: category,
  };
  return transactions
      .where(
        (transaction) => filter.matches(
          transaction,
          category: categoriesById[transaction.categoryId],
        ),
      )
      .toList(growable: false);
}
