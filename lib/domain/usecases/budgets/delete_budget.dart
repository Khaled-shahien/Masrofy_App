import '../../repositories/budget_repository.dart';

/// Removes a monthly budget by identifier.
class DeleteBudget {
  const DeleteBudget(this._repository);

  final BudgetRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteBudget(id);
  }
}
