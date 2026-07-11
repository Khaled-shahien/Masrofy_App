import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Adds or refreshes the built-in category catalog without losing preferences.
class InitializeDefaultCategories {
  /// Creates the default-category initializer.
  const InitializeDefaultCategories({
    required CategoryRepository repository,
    required List<Category> defaults,
  }) : _repository = repository,
       _defaults = defaults;

  final CategoryRepository _repository;
  final List<Category> _defaults;

  /// Upserts catalog metadata while preserving visibility and wallet choices.
  Future<void> call() async {
    final stored = await _repository.getCategories(includeHidden: true);
    final storedById = {for (final category in stored) category.id: category};
    final refreshed = _defaults.map((category) {
      final existing = storedById[category.id];
      return existing == null
          ? category
          : category.copyWith(
              isHidden: existing.isHidden,
              defaultWallet: existing.defaultWallet,
            );
    });

    await _repository.saveCategories(refreshed);
  }
}
