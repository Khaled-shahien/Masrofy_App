import 'package:equatable/equatable.dart';

import 'transaction_type.dart';
import 'wallet_type.dart';

/// A locally stored income or expense entry.
class FinancialTransaction extends Equatable {
  const FinancialTransaction({
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

  FinancialTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    WalletType? wallet,
    String? personName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      wallet: wallet ?? this.wallet,
      personName: personName ?? this.personName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    categoryId,
    date,
    note,
    wallet,
    personName,
    createdAt,
    updatedAt,
  ];
}
