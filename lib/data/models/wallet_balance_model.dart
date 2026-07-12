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
    final walletTypeValue = json['walletType'];
    final updatedAt = _requiredDate(json['updatedAt'], 'updatedAt');

    _validateNullableString(walletTypeValue, 'walletType');

    return WalletBalanceModel(
      walletType: _enumFromName(
        WalletType.values,
        walletTypeValue as String?,
        WalletType.cash,
      ),
      baseBalance: _requiredDouble(json, 'baseBalance'),
      updatedAt: updatedAt,
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

DateTime _requiredDate(Object? value, String fieldName) {
  if (value is! String) {
    throw FormatException('Invalid or missing $fieldName.');
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Invalid or missing $fieldName.');
  }
  return parsed;
}

double _requiredDouble(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is num) {
    return value.toDouble();
  }

  throw FormatException('Invalid or missing $fieldName.');
}

T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) {
    return fallback;
  }

  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }

  throw FormatException('Invalid enum value for storage record.');
}

void _validateNullableString(Object? value, String fieldName) {
  if (value != null && value is! String) {
    throw FormatException('Invalid enum value for $fieldName.');
  }
}
