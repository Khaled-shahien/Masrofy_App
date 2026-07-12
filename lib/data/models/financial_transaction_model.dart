import '../../domain/entities/financial_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/entities/wallet_type.dart';

/// Serializable local storage representation of a financial transaction.
class FinancialTransactionModel {
  const FinancialTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.wallet,
    this.personName,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final WalletType? wallet;
  final String? personName;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FinancialTransactionModel.fromJson(Map<String, dynamic> json) {
    final typeValue = json['type'];
    final walletValue = json['wallet'];
    final date = _requiredDate(json['date'], 'date');
    final createdAt = _optionalDate(json['createdAt']) ?? date;
    final updatedAt = _optionalDate(json['updatedAt']) ?? createdAt;

    _validateNullableString(typeValue, 'type');
    _validateNullableString(walletValue, 'wallet');

    return FinancialTransactionModel(
      id: _requiredString(json, 'id'),
      type: _enumFromName(
        TransactionType.values,
        typeValue as String?,
        TransactionType.expense,
      ),
      amount: _requiredDouble(json, 'amount'),
      categoryId: _requiredString(json, 'categoryId'),
      date: date,
      note: json['note'] as String?,
      wallet: _nullableEnumFromName(WalletType.values, walletValue as String?),
      personName: json['personName'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FinancialTransactionModel.fromDomain(
    FinancialTransaction transaction,
  ) {
    return FinancialTransactionModel(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      date: transaction.date,
      note: transaction.note,
      wallet: transaction.wallet,
      personName: transaction.personName,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'wallet': wallet?.name,
      'personName': personName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  FinancialTransaction toDomain() {
    return FinancialTransaction(
      id: id,
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      wallet: wallet,
      personName: personName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

DateTime _requiredDate(Object? value, String fieldName) {
  final parsed = _optionalDate(value);
  if (parsed == null) {
    throw FormatException('Invalid or missing $fieldName.');
  }
  return parsed;
}

DateTime? _optionalDate(Object? value) {
  if (value is! String) {
    return null;
  }
  return DateTime.tryParse(value);
}

double _requiredDouble(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('Invalid or missing $fieldName.');
}

String _requiredString(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Invalid or missing $fieldName.');
}

T _enumFromName<T extends Enum>(
  List<T> values,
  String? name,
  T fallback,
) {
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

T? _nullableEnumFromName<T extends Enum>(List<T> values, String? name) {
  if (name == null) {
    return null;
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
