import '../../entities/category.dart';
import '../../entities/transaction_type.dart';
import '../../entities/wallet_type.dart';
import '../../repositories/category_repository.dart';
import 'category_usecase_exception.dart';

/// Generates stable identifiers for new custom categories.
typedef CategoryIdGenerator = String Function();

/// Creates or updates a complete custom category after validation.
class SaveCustomCategory {
  /// Creates the custom-category saver.
  const SaveCustomCategory({
    required CategoryRepository repository,
    required CategoryIdGenerator generateId,
  }) : _repository = repository,
       _generateId = generateId;

  final CategoryRepository _repository;
  final CategoryIdGenerator _generateId;

  /// Saves a custom category and returns its normalized value.
  Future<Category> call({
    String? id,
    required TransactionType type,
    required String name,
    required String iconKey,
    required int colorValue,
    int? sortOrder,
    WalletType? defaultWallet,
    CategoryBehavior behavior = CategoryBehavior.standard,
  }) async {
    final normalizedName = name.trim();
    final normalizedIconKey = iconKey.trim();
    _validate(
      name: normalizedName,
      iconKey: normalizedIconKey,
      colorValue: colorValue,
    );

    final categories = await _repository.getCategories(includeHidden: true);
    final existing = _findById(categories, id);
    if (id != null && existing == null) {
      throw CategoryNotFoundException('Category "$id" was not found.');
    }
    if (existing?.isDefault ?? false) {
      throw const InvalidCategoryException(
        'Built-in categories cannot be replaced by custom categories.',
      );
    }
    _ensureUniqueName(
      categories: categories,
      type: type,
      name: normalizedName,
      excludedId: existing?.id,
    );

    final categoryId = existing?.id ?? _newId(categories);
    final category = Category(
      id: categoryId,
      type: type,
      name: normalizedName,
      localizationKey: null,
      iconKey: normalizedIconKey,
      colorValue: colorValue,
      sortOrder:
          sortOrder ?? existing?.sortOrder ?? _nextOrder(categories, type),
      isHidden: existing?.isHidden ?? false,
      defaultWallet: defaultWallet,
      behavior: behavior,
    );
    await _repository.saveCategory(category);
    return category;
  }

  String _newId(List<Category> categories) {
    final id = _generateId().trim();
    if (id.isEmpty) {
      throw const InvalidCategoryException(
        'Generated category ID cannot be empty.',
      );
    }
    if (categories.any((category) => category.id == id)) {
      throw const DuplicateCategoryException(
        'Generated category ID is already in use.',
      );
    }
    return id;
  }

  void _validate({
    required String name,
    required String iconKey,
    required int colorValue,
  }) {
    if (name.isEmpty) {
      throw const InvalidCategoryException('Category name cannot be empty.');
    }
    if (iconKey.isEmpty) {
      throw const InvalidCategoryException('Category icon cannot be empty.');
    }
    if (colorValue < 0 || colorValue > 0xFFFFFFFF) {
      throw const InvalidCategoryException('Category color is not valid ARGB.');
    }
  }

  Category? _findById(List<Category> categories, String? id) {
    if (id == null) {
      return null;
    }
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  void _ensureUniqueName({
    required List<Category> categories,
    required TransactionType type,
    required String name,
    required String? excludedId,
  }) {
    final normalizedName = name.toLowerCase();
    final isDuplicate = categories.any(
      (category) =>
          category.id != excludedId &&
          category.type == type &&
          category.name.trim().toLowerCase() == normalizedName,
    );
    if (isDuplicate) {
      throw const DuplicateCategoryException(
        'A category with this name already exists for this transaction type.',
      );
    }
  }

  int _nextOrder(List<Category> categories, TransactionType type) {
    final matchingOrders = categories
        .where((category) => category.type == type)
        .map((category) => category.sortOrder);
    if (matchingOrders.isEmpty) {
      return 0;
    }
    return matchingOrders.reduce((left, right) => left > right ? left : right) +
        1;
  }
}
