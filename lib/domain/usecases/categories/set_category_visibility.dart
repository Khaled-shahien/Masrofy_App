import '../../entities/category.dart';
import '../../repositories/category_repository.dart';
import 'category_usecase_exception.dart';

/// Hides or restores a category without deleting historical references.
class SetCategoryVisibility {
  /// Creates the category visibility updater.
  const SetCategoryVisibility(this._repository);

  final CategoryRepository _repository;

  /// Updates [categoryId] and returns the persisted category.
  Future<Category> call({
    required String categoryId,
    required bool isHidden,
  }) async {
    final categories = await _repository.getCategories(includeHidden: true);
    final category = _find(categories, categoryId);
    final updated = category.copyWith(isHidden: isHidden);
    await _repository.saveCategory(updated);
    return updated;
  }

  Category _find(List<Category> categories, String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    throw CategoryNotFoundException('Category "$id" was not found.');
  }
}
