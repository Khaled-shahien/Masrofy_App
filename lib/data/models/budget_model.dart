import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_period.dart';

/// Serializable local storage representation of a monthly budget.
class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.isArchived = false,
  });

  final String id;
  final String categoryId;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;
  final bool isArchived;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final month = _requiredInt(json, 'month');
    if (month < 1 || month > 12) {
      throw const FormatException('Budget month must be between 1 and 12.');
    }

    return BudgetModel(
      id: _requiredString(json, 'id'),
      categoryId: _requiredString(json, 'categoryId'),
      amount: _requiredDouble(json, 'amount'),
      month: month,
      year: _requiredInt(json, 'year'),
      note: json['note'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: _requiredDate(json['createdAt'], 'createdAt'),
      updatedAt: _requiredDate(json['updatedAt'], 'updatedAt'),
    );
  }

  factory BudgetModel.fromDomain(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryId: budget.categoryId,
      amount: budget.amount,
      month: budget.period.month,
      year: budget.period.year,
      note: budget.note,
      isArchived: budget.isArchived,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
      'note': note,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Budget toDomain() {
    return Budget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      period: BudgetPeriod(year: year, month: month),
      note: note,
      isArchived: isArchived,
      createdAt: createdAt,
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

int _requiredInt(Map<String, dynamic> json, String fieldName) {
  final value = json[fieldName];
  if (value is int) {
    return value;
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
