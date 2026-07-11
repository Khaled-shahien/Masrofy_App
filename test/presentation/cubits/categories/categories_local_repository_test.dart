import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/catalog/default_category_catalog.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/categories/initialize_default_categories.dart';
import 'package:masrofy/domain/usecases/categories/save_custom_category.dart';
import 'package:masrofy/domain/usecases/categories/set_category_default_wallet.dart';
import 'package:masrofy/domain/usecases/categories/set_category_visibility.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';
import 'package:masrofy/presentation/cubits/categories/categories_cubit.dart';

void main() {
  test(
    'reacts to local changes and can switch watched transaction type',
    () async {
      final dataSource = InMemoryCategoryLocalDataSource();
      final repository = CategoryRepositoryImpl(localDataSource: dataSource);
      await InitializeDefaultCategories(
        repository: repository,
        defaults: defaultCategories,
      )();
      final cubit = CategoriesCubit(
        watchCategories: WatchCategories(repository),
        saveCustomCategory: SaveCustomCategory(
          repository: repository,
          generateId: () => 'custom-id',
        ),
        setCategoryVisibility: SetCategoryVisibility(repository),
        setCategoryDefaultWallet: SetCategoryDefaultWallet(repository),
      );
      addTearDown(() async {
        await cubit.close();
        await dataSource.close();
      });

      final expensesLoaded = cubit.stream.firstWhere(
        (state) => state.status == CategoriesStatus.success,
      );
      await cubit.load();
      await expensesLoaded;

      final hidden = cubit.stream.firstWhere(
        (state) => state.categories.any(
          (category) =>
              category.id == 'expense_food_drink' && category.isHidden,
        ),
      );
      await cubit.setVisibility('expense_food_drink', false);
      await hidden.timeout(const Duration(seconds: 2));

      final incomeLoaded = cubit.stream.firstWhere(
        (state) =>
            state.selectedType == TransactionType.income &&
            state.status == CategoriesStatus.success,
      );
      await cubit.selectType(TransactionType.income);
      await incomeLoaded.timeout(const Duration(seconds: 2));
    },
  );
}
