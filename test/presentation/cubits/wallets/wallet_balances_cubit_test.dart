import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_balance.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/domain/repositories/transaction_repository.dart';
import 'package:masrofy/domain/repositories/wallet_balance_repository.dart';
import 'package:masrofy/domain/usecases/wallets/set_wallet_current_balance.dart';
import 'package:masrofy/presentation/cubits/wallets/wallet_balances_cubit.dart';
import 'package:masrofy/presentation/cubits/wallets/wallet_balances_state.dart';

void main() {
  test('stays loading until balances and transactions both emit', () async {
    final walletRepository = _StreamWalletBalanceRepository();
    final transactionRepository = _StreamTransactionRepository();
    final cubit = WalletBalancesCubit(
      walletBalanceRepository: walletRepository,
      transactionRepository: transactionRepository,
      setWalletCurrentBalance: SetWalletCurrentBalance(
        walletBalanceRepository: walletRepository,
        transactionRepository: transactionRepository,
        now: () => DateTime(2026, 7, 13),
      ),
    );
    addTearDown(cubit.close);
    addTearDown(walletRepository.close);
    addTearDown(transactionRepository.close);

    cubit.load();
    walletRepository.emit([
      WalletBalance(
        walletType: WalletType.instaPay,
        baseBalance: 100,
        updatedAt: DateTime(2026, 7, 13),
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, WalletBalancesStatus.loading);

    transactionRepository.emit([
      _transaction(
        type: TransactionType.expense,
        amount: 25,
        wallet: WalletType.instaPay,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, WalletBalancesStatus.ready);
    final summary = cubit.state.summaries.singleWhere(
      (summary) => summary.walletType == WalletType.instaPay,
    );
    expect(summary.currentBalance, 75);
  });
}

FinancialTransaction _transaction({
  required TransactionType type,
  required double amount,
  required WalletType wallet,
}) {
  return FinancialTransaction(
    id: 'tx-1',
    type: type,
    amount: amount,
    categoryId: 'category',
    wallet: wallet,
    date: DateTime(2026, 7, 13),
    createdAt: DateTime(2026, 7, 13),
    updatedAt: DateTime(2026, 7, 13),
  );
}

class _StreamWalletBalanceRepository implements WalletBalanceRepository {
  final _controller = StreamController<List<WalletBalance>>();
  var _balances = <WalletBalance>[];

  void emit(List<WalletBalance> balances) {
    _balances = balances;
    _controller.add(balances);
  }

  Future<void> close() => _controller.close();

  @override
  Future<WalletBalance?> getWalletBalance(WalletType walletType) async {
    return _balances
        .where((balance) => balance.walletType == walletType)
        .firstOrNull;
  }

  @override
  Future<List<WalletBalance>> getWalletBalances() async => _balances;

  @override
  Future<void> saveWalletBalance(WalletBalance balance) async {
    _balances = [
      for (final existing in _balances)
        if (existing.walletType != balance.walletType) existing,
      balance,
    ];
    _controller.add(_balances);
  }

  @override
  Stream<List<WalletBalance>> watchWalletBalances() => _controller.stream;
}

class _StreamTransactionRepository implements TransactionRepository {
  final _controller = StreamController<List<FinancialTransaction>>();
  var _transactions = <FinancialTransaction>[];

  void emit(List<FinancialTransaction> transactions) {
    _transactions = transactions;
    _controller.add(transactions);
  }

  Future<void> close() => _controller.close();

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<List<FinancialTransaction>> getTransactions() async => _transactions;

  @override
  Future<void> saveTransaction(FinancialTransaction transaction) async {}

  @override
  Stream<List<FinancialTransaction>> watchTransactions() => _controller.stream;
}
