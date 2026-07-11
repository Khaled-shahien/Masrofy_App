import 'package:equatable/equatable.dart';

import 'wallet_type.dart';

/// Stores the calibrated base balance for a wallet.
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.walletType,
    required this.baseBalance,
    required this.updatedAt,
  });

  final WalletType walletType;
  final double baseBalance;
  final DateTime updatedAt;

  @override
  List<Object> get props => [walletType, baseBalance, updatedAt];
}
