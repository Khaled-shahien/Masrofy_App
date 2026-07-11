import '../../entities/wallet_balance.dart';
import '../../entities/wallet_type.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/wallet_balance_repository.dart';
import 'wallet_balance_calculator.dart';

class SetWalletCurrentBalance {
  SetWalletCurrentBalance({
    required WalletBalanceRepository walletBalanceRepository,
    required TransactionRepository transactionRepository,
    DateTime Function()? now,
  }) : _walletBalanceRepository = walletBalanceRepository,
       _transactionRepository = transactionRepository,
       _now = now ?? DateTime.now;

  final WalletBalanceRepository _walletBalanceRepository;
  final TransactionRepository _transactionRepository;
  final DateTime Function() _now;

  Future<void> call({
    required WalletType walletType,
    required double currentBalance,
  }) async {
    final transactions = await _transactionRepository.getTransactions();
    final transactionNet = calculateTransactionNet(
      walletType: walletType,
      transactions: transactions,
    );
    await _walletBalanceRepository.saveWalletBalance(
      WalletBalance(
        walletType: walletType,
        baseBalance: currentBalance - transactionNet,
        updatedAt: _now(),
      ),
    );
  }
}
