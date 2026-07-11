import '../entities/category.dart';
import '../entities/transaction_type.dart';

/// Provides persistence operations for transaction categories.
abstract interface class CategoryRepository {
  /// Watches categories matching [type] and visibility preferences.
  Stream<List<Category>> watchCategories({
    TransactionType? type,
    bool includeHidden = false,
  });

  /// Gets categories matching [type] and visibility preferences once.
  Future<List<Category>> getCategories({
    TransactionType? type,
    bool includeHidden = false,
  });

  /// Creates or replaces one category by its stable identifier.
  Future<void> saveCategory(Category category);

  /// Creates or replaces categories by their stable identifiers.
  Future<void> saveCategories(Iterable<Category> categories);
}
