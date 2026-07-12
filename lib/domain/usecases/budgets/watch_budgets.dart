import '../../entities/budget.dart';
import '../../entities/budget_period.dart';
import '../../repositories/budget_repository.dart';

/// Watches budgets for a selected month.
class WatchBudgets {
  const WatchBudgets(this._repository);

  final BudgetRepository _repository;

  Stream<List<Budget>> call({
    BudgetPeriod? period,
    bool includeArchived = false,
  }) {
    return _repository.watchBudgets(
      period: period,
      includeArchived: includeArchived,
    );
  }
}
