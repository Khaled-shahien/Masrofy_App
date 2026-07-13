import 'package:uuid/uuid.dart';

import '../../entities/financial_transaction.dart';
import '../../entities/transaction_type.dart';
import '../../entities/wallet_type.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/transaction_repository.dart';

enum TransactionValidationFailureReason {
  invalidAmount,
  missingCategory,
  unknownCategory,
  categoryTypeMismatch,
}

class SaveTransactionInput {
  const SaveTransactionInput({
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.id,
    this.createdAt,
    this.note,
    this.wallet,
    this.personName,
  });

  final String? id;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final DateTime? createdAt;
  final String? note;
  final WalletType? wallet;
  final String? personName;
}

class TransactionValidationException implements Exception {
  const TransactionValidationException(this.reason, this.message);

  final TransactionValidationFailureReason reason;
  final String message;
}

class SaveTransaction {
  SaveTransaction({
    required TransactionRepository repository,
    required CategoryRepository categoryRepository,
    String Function()? generateId,
    DateTime Function()? now,
  }) : _repository = repository,
       _categoryRepository = categoryRepository,
       _generateId = generateId ?? const Uuid().v4,
       _now = now ?? DateTime.now;

  final TransactionRepository _repository;
  final CategoryRepository _categoryRepository;
  final String Function() _generateId;
  final DateTime Function() _now;

  Future<void> call(SaveTransactionInput input) async {
    final amount = input.amount;
    if (amount <= 0) {
      throw const TransactionValidationException(
        TransactionValidationFailureReason.invalidAmount,
        'Transaction amount must be greater than zero.',
      );
    }
    if (input.categoryId.trim().isEmpty) {
      throw const TransactionValidationException(
        TransactionValidationFailureReason.missingCategory,
        'Transaction category is required.',
      );
    }
    final categories = await _categoryRepository.getCategories(
      includeHidden: true,
    );
    final category = categories.where(
      (category) => category.id == input.categoryId,
    );
    final matchedCategory = category.isEmpty ? null : category.first;
    if (matchedCategory == null) {
      throw const TransactionValidationException(
        TransactionValidationFailureReason.unknownCategory,
        'Transaction category does not exist.',
      );
    }
    if (matchedCategory.type != input.type) {
      throw const TransactionValidationException(
        TransactionValidationFailureReason.categoryTypeMismatch,
        'Transaction category does not match the transaction type.',
      );
    }

    final now = _now();
    return _repository.saveTransaction(
      FinancialTransaction(
        id: input.id ?? _generateId(),
        type: input.type,
        amount: amount,
        categoryId: input.categoryId,
        date: input.date,
        note: _blankToNull(input.note),
        wallet: input.wallet,
        personName: _blankToNull(input.personName),
        createdAt: input.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
