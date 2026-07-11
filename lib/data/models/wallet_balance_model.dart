import '../../domain/entities/wallet_balance.dart';
import '../../domain/entities/wallet_type.dart';

/// Serializable local storage representation of a wallet balance.
class WalletBalanceModel {
  const WalletBalanceModel({
    required this.walletType,
    required this.baseBalance,
    required this.updatedAt,
  });

  final WalletType walletType;
  final double baseBalance;
  final DateTime updatedAt;

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      walletType: _enumFromName(
        WalletType.values,
        json['walletType'] as String?,
        WalletType.cash,
      ),
      baseBalance: (json['baseBalance'] as num? ?? 0).toDouble(),
      updatedAt: _dateFromJson(json['updatedAt']) ?? DateTime.now(),
    );
  }

  factory WalletBalanceModel.fromDomain(WalletBalance balance) {
    return WalletBalanceModel(
      walletType: balance.walletType,
      baseBalance: balance.baseBalance,
      updatedAt: balance.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'walletType': walletType.name,
      'baseBalance': baseBalance,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WalletBalance toDomain() {
    return WalletBalance(
      walletType: walletType,
      baseBalance: baseBalance,
      updatedAt: updatedAt,
    );
  }
}

DateTime? _dateFromJson(Object? value) {
  if (value is! String) {
    return null;
  }
  return DateTime.tryParse(value);
}

T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}
