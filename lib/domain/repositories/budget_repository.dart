import '../entities/budget.dart';
import '../entities/budget_period.dart';

/// Provides local persistence for monthly category budgets.
abstract interface class BudgetRepository {
  Future<List<Budget>> getBudgets({
    BudgetPeriod? period,
    bool includeArchived = false,
  });

  Stream<List<Budget>> watchBudgets({
    BudgetPeriod? period,
    bool includeArchived = false,
  });

  Future<void> saveBudget(Budget budget);

  Future<void> deleteBudget(String id);
}
