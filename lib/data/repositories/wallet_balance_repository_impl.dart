import '../../domain/entities/wallet_balance.dart';
import '../../domain/entities/wallet_type.dart';
import '../../domain/repositories/wallet_balance_repository.dart';
import '../datasources/wallets/wallet_balance_local_data_source.dart';
import '../models/wallet_balance_model.dart';

class WalletBalanceRepositoryImpl implements WalletBalanceRepository {
  const WalletBalanceRepositoryImpl({
    required WalletBalanceLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final WalletBalanceLocalDataSource _localDataSource;

  @override
  Future<List<WalletBalance>> getWalletBalances() async {
    final models = await _localDataSource.getWalletBalances();
    return models.map((model) => model.toDomain()).toList(growable: false);
  }

  @override
  Future<WalletBalance?> getWalletBalance(WalletType walletType) async {
    return (await _localDataSource.getWalletBalance(walletType))?.toDomain();
  }

  @override
  Future<void> saveWalletBalance(WalletBalance balance) {
    return _localDataSource.saveWalletBalance(
      WalletBalanceModel.fromDomain(balance),
    );
  }

  @override
  Stream<List<WalletBalance>> watchWalletBalances() {
    return _localDataSource.watchWalletBalances().map(
      (models) => models
          .map((model) => model.toDomain())
          .toList(
            growable: false,
          ),
    );
  }
}
