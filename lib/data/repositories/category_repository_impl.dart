import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/categories/category_local_data_source.dart';
import '../models/category_model.dart';

/// Implements category persistence using a local source of truth.
class CategoryRepositoryImpl implements CategoryRepository {
  /// Creates a category repository backed by [_localDataSource].
  const CategoryRepositoryImpl({
    required this._localDataSource,
  });

  final CategoryLocalDataSource _localDataSource;

  @override
  Future<List<Category>> getCategories({
    TransactionType? type,
    bool includeHidden = false,
  }) async {
    final models = await _localDataSource.getCategories();
    return _mapFilterAndSort(
      models,
      type: type,
      includeHidden: includeHidden,
    );
  }

  @override
  Future<void> saveCategories(Iterable<Category> categories) {
    return _localDataSource.saveCategories(
      categories.map(CategoryModel.fromDomain),
    );
  }

  @override
  Future<void> saveCategory(Category category) {
    return _localDataSource.saveCategory(CategoryModel.fromDomain(category));
  }

  @override
  Stream<List<Category>> watchCategories({
    TransactionType? type,
    bool includeHidden = false,
  }) {
    return _localDataSource.watchCategories().map(
      (models) => _mapFilterAndSort(
        models,
        type: type,
        includeHidden: includeHidden,
      ),
    );
  }

  List<Category> _mapFilterAndSort(
    Iterable<CategoryModel> models, {
    required TransactionType? type,
    required bool includeHidden,
  }) {
    final categories = models
        .map((model) => model.toDomain())
        .where(
          (category) =>
              (type == null || category.type == type) &&
              (includeHidden || !category.isHidden),
        )
        .toList();
    categories.sort(_compareCategories);
    return List<Category>.unmodifiable(categories);
  }

  int _compareCategories(Category left, Category right) {
    final typeComparison = left.type.index.compareTo(right.type.index);
    if (typeComparison != 0) {
      return typeComparison;
    }
    final orderComparison = left.sortOrder.compareTo(right.sortOrder);
    if (orderComparison != 0) {
      return orderComparison;
    }
    return left.id.compareTo(right.id);
  }
}
