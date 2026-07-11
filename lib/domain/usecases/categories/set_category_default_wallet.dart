import '../../entities/category.dart';
import '../../entities/wallet_type.dart';
import '../../repositories/category_repository.dart';
import 'category_usecase_exception.dart';

/// Assigns or clears the wallet suggested for a category.
class SetCategoryDefaultWallet {
  /// Creates the default-wallet updater.
  const SetCategoryDefaultWallet(this._repository);

  final CategoryRepository _repository;

  /// Updates [categoryId] and returns the persisted category.
  Future<Category> call({
    required String categoryId,
    required WalletType? defaultWallet,
  }) async {
    final categories = await _repository.getCategories(includeHidden: true);
    final category = _find(categories, categoryId);
    final updated = category.copyWith(defaultWallet: defaultWallet);
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
