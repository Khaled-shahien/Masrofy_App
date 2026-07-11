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
    return FinancialTransactionModel(
      id: json['id'] as String? ?? '',
      type: _enumFromName(
        TransactionType.values,
        json['type'] as String?,
        TransactionType.expense,
      ),
      amount: (json['amount'] as num? ?? 0).toDouble(),
      categoryId: json['categoryId'] as String? ?? '',
      date: _dateFromJson(json['date']) ?? DateTime.now(),
      note: json['note'] as String?,
      wallet: _nullableEnumFromName(
        WalletType.values,
        json['wallet'] as String?,
      ),
      personName: json['personName'] as String?,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']) ?? DateTime.now(),
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

DateTime? _dateFromJson(Object? value) {
  if (value is! String) {
    return null;
  }
  return DateTime.tryParse(value);
}

T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  return _nullableEnumFromName(values, name) ?? fallback;
}

T? _nullableEnumFromName<T extends Enum>(List<T> values, String? name) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}
