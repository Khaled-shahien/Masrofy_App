import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_balance.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/domain/repositories/transaction_repository.dart';
import 'package:masrofy/domain/repositories/wallet_balance_repository.dart';
import 'package:masrofy/domain/usecases/wallets/set_wallet_current_balance.dart';
import 'package:masrofy/domain/usecases/wallets/wallet_balance_calculator.dart';

void main() {
  test(
    'buildWalletBalanceSummaries applies income and expenses per wallet',
    () {
      final summaries = buildWalletBalanceSummaries(
        balances: [
          WalletBalance(
            walletType: WalletType.instaPay,
            baseBalance: 500,
            updatedAt: DateTime(2026),
          ),
        ],
        transactions: [
          _transaction(
            id: 'income',
            type: TransactionType.income,
            amount: 200,
            wallet: WalletType.instaPay,
          ),
          _transaction(
            id: 'expense',
            type: TransactionType.expense,
            amount: 75,
            wallet: WalletType.instaPay,
          ),
          _transaction(
            id: 'vodafone-expense',
            type: TransactionType.expense,
            amount: 20,
            wallet: WalletType.vodafoneCash,
          ),
        ],
      );

      expect(summaries, hasLength(2));
      expect(summaries.first.walletType, WalletType.instaPay);
      expect(summaries.first.transactionNet, 125);
      expect(summaries.first.currentBalance, 625);
      expect(summaries.last.walletType, WalletType.vodafoneCash);
      expect(summaries.last.currentBalance, -20);
    },
  );

  test(
    'SetWalletCurrentBalance calibrates base balance from current value',
    () async {
      final walletRepository = _FakeWalletBalanceRepository();
      final transactionRepository = _FakeTransactionRepository([
        _transaction(
          id: 'expense',
          type: TransactionType.expense,
          amount: 120,
          wallet: WalletType.vodafoneCash,
        ),
        _transaction(
          id: 'income',
          type: TransactionType.income,
          amount: 50,
          wallet: WalletType.vodafoneCash,
        ),
      ]);
      final useCase = SetWalletCurrentBalance(
        walletBalanceRepository: walletRepository,
        transactionRepository: transactionRepository,
        now: () => DateTime(2026, 7, 11),
      );

      await useCase(
        walletType: WalletType.vodafoneCash,
        currentBalance: 300,
      );

      final saved = walletRepository.savedBalance;
      expect(saved?.walletType, WalletType.vodafoneCash);
      expect(saved?.baseBalance, 370);
      expect(saved?.updatedAt, DateTime(2026, 7, 11));
    },
  );
}

FinancialTransaction _transaction({
  required String id,
  required TransactionType type,
  required double amount,
  required WalletType wallet,
}) {
  return FinancialTransaction(
    id: id,
    type: type,
    amount: amount,
    categoryId: 'category',
    date: DateTime(2026, 7, 11),
    wallet: wallet,
    createdAt: DateTime(2026, 7, 11),
    updatedAt: DateTime(2026, 7, 11),
  );
}

class _FakeWalletBalanceRepository implements WalletBalanceRepository {
  WalletBalance? savedBalance;

  @override
  Future<WalletBalance?> getWalletBalance(WalletType walletType) async {
    return savedBalance?.walletType == walletType ? savedBalance : null;
  }

  @override
  Future<List<WalletBalance>> getWalletBalances() async {
    return [?savedBalance];
  }

  @override
  Future<void> saveWalletBalance(WalletBalance balance) async {
    savedBalance = balance;
  }

  @override
  Stream<List<WalletBalance>> watchWalletBalances() {
    return Stream.value([?savedBalance]);
  }
}

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this._transactions);

  final List<FinancialTransaction> _transactions;

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<List<FinancialTransaction>> getTransactions() async {
    return _transactions;
  }

  @override
  Future<void> saveTransaction(FinancialTransaction transaction) async {}

  @override
  Stream<List<FinancialTransaction>> watchTransactions() {
    return Stream.value(_transactions);
  }
}
