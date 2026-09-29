import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/wallet_balance.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/wallet_balance_repository.dart';
import '../../../domain/usecases/wallets/set_wallet_current_balance.dart';
import '../../../domain/usecases/wallets/wallet_balance_calculator.dart';
import 'wallet_balances_state.dart';

class WalletBalancesCubit extends Cubit<WalletBalancesState> {
  WalletBalancesCubit({
    required this._walletBalanceRepository,
    required TransactionRepository transactionRepository,
    required this._setWalletCurrentBalance,
  }) : _transactionRepository = transactionRepository,
       super(const WalletBalancesState());

  final WalletBalanceRepository _walletBalanceRepository;
  final TransactionRepository _transactionRepository;
  final SetWalletCurrentBalance _setWalletCurrentBalance;

  StreamSubscription<List<WalletBalance>>? _balancesSubscription;
  StreamSubscription<List<FinancialTransaction>>? _transactionsSubscription;
  List<WalletBalance> _balances = const [];
  List<FinancialTransaction> _transactions = const [];
  bool _hasBalancesSnapshot = false;
  bool _hasTransactionsSnapshot = false;

  void load() {
    emit(
      state.copyWith(status: WalletBalancesStatus.loading, clearError: true),
    );
    unawaited(_balancesSubscription?.cancel());
    unawaited(_transactionsSubscription?.cancel());
    _hasBalancesSnapshot = false;
    _hasTransactionsSnapshot = false;

    _balancesSubscription = _walletBalanceRepository
        .watchWalletBalances()
        .listen(
          (balances) {
            _balances = balances;
            _hasBalancesSnapshot = true;
            _emitReady();
          },
          onError: _emitFailure,
        );

    _transactionsSubscription = _transactionRepository
        .watchTransactions()
        .listen(
          (transactions) {
            _transactions = transactions;
            _hasTransactionsSnapshot = true;
            _emitReady();
          },
          onError: _emitFailure,
        );
  }

  Future<void> setCurrentBalance({
    required WalletType walletType,
    required double currentBalance,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _setWalletCurrentBalance(
        walletType: walletType,
        currentBalance: currentBalance,
      );
      emit(state.copyWith(isSaving: false, clearError: true));
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'تعذر حفظ رصيد المحفظة',
        ),
      );
    }
  }

  void _emitReady() {
    if (!_hasBalancesSnapshot || !_hasTransactionsSnapshot) {
      emit(
        state.copyWith(status: WalletBalancesStatus.loading, clearError: true),
      );
      return;
    }
    emit(
      state.copyWith(
        status: WalletBalancesStatus.ready,
        summaries: buildWalletBalanceSummaries(
          balances: _balances,
          transactions: _transactions,
        ),
        clearError: true,
      ),
    );
  }

  void _emitFailure(Object error, StackTrace stackTrace) {
    emit(
      state.copyWith(
        status: WalletBalancesStatus.failure,
        errorMessage: 'تعذر تحميل أرصدة المحافظ',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _balancesSubscription?.cancel();
    await _transactionsSubscription?.cancel();
    return super.close();
  }
}
