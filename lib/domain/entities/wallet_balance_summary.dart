import 'package:equatable/equatable.dart';

import 'wallet_type.dart';

/// Presents the current balance for a wallet after transaction activity.
class WalletBalanceSummary extends Equatable {
  const WalletBalanceSummary({
    required this.walletType,
    required this.baseBalance,
    required this.transactionNet,
  });

  final WalletType walletType;
  final double baseBalance;
  final double transactionNet;

  double get currentBalance => baseBalance + transactionNet;

  @override
  List<Object> get props => [walletType, baseBalance, transactionNet];
}
