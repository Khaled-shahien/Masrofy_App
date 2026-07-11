import '../../entities/category.dart';
import '../../entities/transaction_type.dart';
import '../../repositories/category_repository.dart';

/// Watches the category list used by transaction and management screens.
class WatchCategories {
  /// Creates the category watcher.
  const WatchCategories(this._repository);

  final CategoryRepository _repository;

  /// Returns a stream filtered by [type] and visibility.
  Stream<List<Category>> call({
    TransactionType? type,
    bool includeHidden = false,
  }) {
    return _repository.watchCategories(
      type: type,
      includeHidden: includeHidden,
    );
  }
}
