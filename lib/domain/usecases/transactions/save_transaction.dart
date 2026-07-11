import 'package:uuid/uuid.dart';

import '../../entities/financial_transaction.dart';
import '../../entities/transaction_type.dart';
import '../../entities/wallet_type.dart';
import '../../repositories/transaction_repository.dart';

class SaveTransactionInput {
  const SaveTransactionInput({
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.wallet,
    this.personName,
  });

  final TransactionType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final WalletType? wallet;
  final String? personName;
}

class TransactionValidationException implements Exception {
  const TransactionValidationException(this.message);

  final String message;
}

class SaveTransaction {
  SaveTransaction({
    required TransactionRepository repository,
    String Function()? generateId,
    DateTime Function()? now,
  }) : _repository = repository,
       _generateId = generateId ?? const Uuid().v4,
       _now = now ?? DateTime.now;

  final TransactionRepository _repository;
  final String Function() _generateId;
  final DateTime Function() _now;

  Future<void> call(SaveTransactionInput input) {
    final amount = input.amount;
    if (amount <= 0) {
      throw const TransactionValidationException(
        'Transaction amount must be greater than zero.',
      );
    }
    if (input.categoryId.trim().isEmpty) {
      throw const TransactionValidationException(
        'Transaction category is required.',
      );
    }

    final now = _now();
    return _repository.saveTransaction(
      FinancialTransaction(
        id: _generateId(),
        type: input.type,
        amount: amount,
        categoryId: input.categoryId,
        date: input.date,
        note: _blankToNull(input.note),
        wallet: input.wallet,
        personName: _blankToNull(input.personName),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
