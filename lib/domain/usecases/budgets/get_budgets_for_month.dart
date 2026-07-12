import '../../entities/budget.dart';
import '../../entities/budget_period.dart';
import '../../repositories/budget_repository.dart';

/// Gets budgets for a selected month once.
class GetBudgetsForMonth {
  const GetBudgetsForMonth(this._repository);

  final BudgetRepository _repository;

  Future<List<Budget>> call({
    required BudgetPeriod period,
    bool includeArchived = false,
  }) {
    return _repository.getBudgets(
      period: period,
      includeArchived: includeArchived,
    );
  }
}
