import 'package:equatable/equatable.dart';

import 'category.dart';
import 'financial_transaction.dart';
import 'transaction_type.dart';
import 'wallet_type.dart';

/// Immutable local filter used for transaction search and history views.
class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.categoryId,
    this.wallet,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.hasPersonName,
    this.hasNote,
  });

  final String query;
  final TransactionType? type;
  final String? categoryId;
  final WalletType? wallet;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final bool? hasPersonName;
  final bool? hasNote;

  bool get isActive =>
      query.trim().isNotEmpty ||
      type != null ||
      categoryId != null ||
      wallet != null ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null ||
      hasPersonName != null ||
      hasNote != null;

  bool matches(
    FinancialTransaction transaction, {
    required Category? category,
  }) {
    if (type != null && transaction.type != type) {
      return false;
    }
    if (categoryId != null && transaction.categoryId != categoryId) {
      return false;
    }
    if (wallet != null && transaction.wallet != wallet) {
      return false;
    }
    if (startDate != null && transaction.date.isBefore(_day(startDate!))) {
      return false;
    }
    if (endDate != null &&
        !transaction.date.isBefore(
          _day(endDate!).add(const Duration(days: 1)),
        )) {
      return false;
    }
    if (minAmount != null && transaction.amount < minAmount!) {
      return false;
    }
    if (maxAmount != null && transaction.amount > maxAmount!) {
      return false;
    }
    if (hasPersonName != null &&
        _isBlank(transaction.personName) == hasPersonName) {
      return false;
    }
    if (hasNote != null && _isBlank(transaction.note) == hasNote) {
      return false;
    }

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final fields = <String>[
      transaction.amount.toStringAsFixed(0),
      transaction.amount.toString(),
      transaction.note ?? '',
      transaction.personName ?? '',
      category?.name ?? '',
      category?.localizationKey ?? '',
    ];
    return fields.any(
      (field) => field.toLowerCase().contains(normalizedQuery),
    );
  }

  TransactionFilter copyWith({
    String? query,
    TransactionType? type,
    String? categoryId,
    WalletType? wallet,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    bool? hasPersonName,
    bool? hasNote,
    bool clearType = false,
    bool clearCategory = false,
    bool clearWallet = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearHasPersonName = false,
    bool clearHasNote = false,
  }) {
    return TransactionFilter(
      query: query ?? this.query,
      type: clearType ? null : type ?? this.type,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      wallet: clearWallet ? null : wallet ?? this.wallet,
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      minAmount: clearMinAmount ? null : minAmount ?? this.minAmount,
      maxAmount: clearMaxAmount ? null : maxAmount ?? this.maxAmount,
      hasPersonName: clearHasPersonName
          ? null
          : hasPersonName ?? this.hasPersonName,
      hasNote: clearHasNote ? null : hasNote ?? this.hasNote,
    );
  }

  @override
  List<Object?> get props => [
    query,
    type,
    categoryId,
    wallet,
    startDate,
    endDate,
    minAmount,
    maxAmount,
    hasPersonName,
    hasNote,
  ];
}

DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isBlank(String? value) => value == null || value.trim().isEmpty;
