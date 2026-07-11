/// Base failure raised by category use cases.
sealed class CategoryUseCaseException implements Exception {
  /// Creates a category use-case failure.
  const CategoryUseCaseException(this.message);

  /// A developer-facing explanation of the failure.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Indicates that category input violates a domain invariant.
final class InvalidCategoryException extends CategoryUseCaseException {
  /// Creates an invalid-category failure.
  const InvalidCategoryException(super.message);
}

/// Indicates that another category already uses the requested name.
final class DuplicateCategoryException extends CategoryUseCaseException {
  /// Creates a duplicate-category failure.
  const DuplicateCategoryException(super.message);
}

/// Indicates that the requested category does not exist.
final class CategoryNotFoundException extends CategoryUseCaseException {
  /// Creates a missing-category failure.
  const CategoryNotFoundException(super.message);
}
