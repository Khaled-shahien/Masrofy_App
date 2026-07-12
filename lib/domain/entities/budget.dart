import 'package:equatable/equatable.dart';

import 'budget_period.dart';

/// A monthly spending limit for one expense category.
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.isArchived = false,
  });

  final String id;
  final String categoryId;
  final double amount;
  final BudgetPeriod period;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;
  final bool isArchived;

  Budget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    BudgetPeriod? period,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
    bool? isArchived,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    amount,
    period,
    createdAt,
    updatedAt,
    note,
    isArchived,
  ];
}
