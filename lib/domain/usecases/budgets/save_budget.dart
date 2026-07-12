import 'package:uuid/uuid.dart';

import '../../entities/budget.dart';
import '../../entities/budget_period.dart';
import '../../entities/transaction_type.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/category_repository.dart';
import 'budget_usecase_exception.dart';

class SaveBudgetInput {
  const SaveBudgetInput({
    required this.categoryId,
    required this.amount,
    required this.period,
    this.id,
    this.note,
  });

  final String? id;
  final String categoryId;
  final double amount;
  final BudgetPeriod period;
  final String? note;
}

/// Validates and persists monthly category budgets.
class SaveBudget {
  SaveBudget({
    required BudgetRepository budgetRepository,
    required CategoryRepository categoryRepository,
    String Function()? generateId,
    DateTime Function()? now,
  }) : _budgetRepository = budgetRepository,
       _categoryRepository = categoryRepository,
       _generateId = generateId ?? const Uuid().v4,
       _now = now ?? DateTime.now;

  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;
  final String Function() _generateId;
  final DateTime Function() _now;

  Future<void> call(SaveBudgetInput input) async {
    if (input.amount <= 0) {
      throw const InvalidBudgetException(
        'Budget amount must be greater than zero.',
      );
    }
    if (input.categoryId.trim().isEmpty) {
      throw const BudgetCategoryException('Budget category is required.');
    }

    final categories = await _categoryRepository.getCategories(
      includeHidden: true,
    );
    final matching = categories.where(
      (category) => category.id == input.categoryId,
    );
    if (matching.isEmpty) {
      throw const BudgetCategoryException('Budget category was not found.');
    }
    final category = matching.single;
    if (category.type != TransactionType.expense) {
      throw const BudgetCategoryException(
        'Only expense categories can have budgets.',
      );
    }

    final existing = await _budgetRepository.getBudgets(
      period: input.period,
      includeArchived: false,
    );
    final duplicate = existing.any(
      (budget) =>
          budget.categoryId == input.categoryId &&
          budget.id != input.id &&
          !budget.isArchived,
    );
    if (duplicate) {
      throw const DuplicateBudgetException(
        'A budget already exists for this category and month.',
      );
    }

    final now = _now();
    final id = input.id ?? _generateId();
    final current = input.id == null ? null : _findBudget(existing, input.id!);

    await _budgetRepository.saveBudget(
      Budget(
        id: id,
        categoryId: input.categoryId,
        amount: input.amount,
        period: input.period,
        note: _blankToNull(input.note),
        isArchived: current?.isArchived ?? false,
        createdAt: current?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

Budget? _findBudget(Iterable<Budget> budgets, String id) {
  for (final budget in budgets) {
    if (budget.id == id) {
      return budget;
    }
  }
  return null;
}
