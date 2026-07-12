import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_period.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budgets/budget_local_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl({
    required BudgetLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final BudgetLocalDataSource _localDataSource;

  @override
  Future<List<Budget>> getBudgets({
    BudgetPeriod? period,
    bool includeArchived = false,
  }) async {
    final models = await _localDataSource.getBudgets();
    return _mapFilterAndSort(
      models,
      period: period,
      includeArchived: includeArchived,
    );
  }

  @override
  Future<void> saveBudget(Budget budget) {
    return _localDataSource.saveBudget(BudgetModel.fromDomain(budget));
  }

  @override
  Future<void> deleteBudget(String id) {
    return _localDataSource.deleteBudget(id);
  }

  @override
  Stream<List<Budget>> watchBudgets({
    BudgetPeriod? period,
    bool includeArchived = false,
  }) {
    return _localDataSource.watchBudgets().map(
      (models) => _mapFilterAndSort(
        models,
        period: period,
        includeArchived: includeArchived,
      ),
    );
  }

  List<Budget> _mapFilterAndSort(
    Iterable<BudgetModel> models, {
    required BudgetPeriod? period,
    required bool includeArchived,
  }) {
    final budgets = models
        .map((model) => model.toDomain())
        .where(
          (budget) =>
              (period == null || budget.period == period) &&
              (includeArchived || !budget.isArchived),
        )
        .toList();
    budgets.sort(_compareBudgets);
    return List<Budget>.unmodifiable(budgets);
  }

  int _compareBudgets(Budget left, Budget right) {
    final dateComparison = right.period.start.compareTo(left.period.start);
    if (dateComparison != 0) {
      return dateComparison;
    }
    return left.categoryId.compareTo(right.categoryId);
  }
}
