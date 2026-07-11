import '../entities/wallet_balance.dart';
import '../entities/wallet_type.dart';

abstract interface class WalletBalanceRepository {
  Stream<List<WalletBalance>> watchWalletBalances();

  Future<List<WalletBalance>> getWalletBalances();

  Future<void> saveWalletBalance(WalletBalance balance);

  Future<WalletBalance?> getWalletBalance(WalletType walletType);
}
