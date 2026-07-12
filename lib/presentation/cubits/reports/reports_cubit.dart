import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/report_filter.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../domain/usecases/categories/watch_categories.dart';
import '../../../domain/usecases/reports/build_report.dart';
import '../../../domain/usecases/transactions/watch_transactions.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required WatchTransactions watchTransactions,
    required WatchCategories watchCategories,
    required BuildReport buildReport,
  }) : _watchTransactions = watchTransactions,
       _watchCategories = watchCategories,
       _buildReport = buildReport,
       super(const ReportsState());

  final WatchTransactions _watchTransactions;
  final WatchCategories _watchCategories;
  final BuildReport _buildReport;

  StreamSubscription<List<FinancialTransaction>>? _transactionsSubscription;
  StreamSubscription<List<Category>>? _categoriesSubscription;
  var _transactionsReady = false;
  var _categoriesReady = false;

  void load() {
    emit(state.copyWith(status: ReportsStatus.loading));
    _transactionsReady = false;
    _categoriesReady = false;
    unawaited(_transactionsSubscription?.cancel());
    unawaited(_categoriesSubscription?.cancel());

    _transactionsSubscription = _watchTransactions().listen(
      (transactions) {
        _transactionsReady = true;
        emit(state.copyWith(transactions: transactions));
        _emitReport();
      },
      onError: _emitFailure,
    );
    _categoriesSubscription = _watchCategories(includeHidden: true).listen(
      (categories) {
        _categoriesReady = true;
        emit(state.copyWith(categories: categories));
        _emitReport();
      },
      onError: _emitFailure,
    );
  }

  void setPeriod(ReportPeriodType periodType) {
    final filter = state.filter.copyWith(
      periodType: periodType,
      clearCustomRange: periodType != ReportPeriodType.custom,
    );
    emit(state.copyWith(filter: filter));
    _emitReport();
  }

  void setCustomRange(DateTime start, DateTime end) {
    final filter = state.filter.copyWith(
      periodType: ReportPeriodType.custom,
      customStart: start,
      customEnd: end,
    );
    emit(state.copyWith(filter: filter));
    _emitReport();
  }

  void setCategory(String? categoryId) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          categoryId: categoryId,
          clearCategory: categoryId == null,
        ),
      ),
    );
    _emitReport();
  }

  void setWallet(WalletType? wallet) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          wallet: wallet,
          clearWallet: wallet == null,
        ),
      ),
    );
    _emitReport();
  }

  void setTransactionType(TransactionType? transactionType) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          transactionType: transactionType,
          clearTransactionType: transactionType == null,
        ),
      ),
    );
    _emitReport();
  }

  void clearFilters() {
    final transactions = state.transactions;
    final categories = state.categories;
    emit(
      state.copyWith(
        status: ReportsStatus.loading,
        filter: const ReportFilter(),
        transactions: transactions,
        categories: categories,
      ),
    );
    _emitReport();
  }

  void retry() {
    load();
  }

  void _emitReport() {
    if (!_transactionsReady || !_categoriesReady) {
      return;
    }

    final report = _buildReport(
      transactions: state.transactions,
      filter: state.filter,
    );
    emit(
      state.copyWith(
        status: report.hasTransactions
            ? ReportsStatus.loaded
            : ReportsStatus.empty,
        report: report,
      ),
    );
  }

  void _emitFailure(Object error, StackTrace stackTrace) {
    emit(state.copyWith(status: ReportsStatus.failure));
  }

  @override
  Future<void> close() async {
    await _transactionsSubscription?.cancel();
    await _categoriesSubscription?.cancel();
    return super.close();
  }
}
