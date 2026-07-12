/// Base failure raised by budget use cases.
sealed class BudgetUseCaseException implements Exception {
  const BudgetUseCaseException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Indicates that budget input violates a domain invariant.
final class InvalidBudgetException extends BudgetUseCaseException {
  const InvalidBudgetException(super.message);
}

/// Indicates that another active budget already targets the same month.
final class DuplicateBudgetException extends BudgetUseCaseException {
  const DuplicateBudgetException(super.message);
}

/// Indicates that the requested category cannot be budgeted.
final class BudgetCategoryException extends BudgetUseCaseException {
  const BudgetCategoryException(super.message);
}
