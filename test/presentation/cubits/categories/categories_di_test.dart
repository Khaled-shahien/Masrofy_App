import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/catalog/default_category_catalog.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/di/service_locator.dart';
import 'package:masrofy/domain/repositories/category_repository.dart';
import 'package:masrofy/presentation/cubits/categories/categories_cubit.dart';

void main() {
  tearDown(serviceLocator.reset);

  test('registers an in-memory category graph and seeds defaults', () async {
    await configureDependencies();

    expect(
      serviceLocator<CategoryLocalDataSource>(),
      isA<InMemoryCategoryLocalDataSource>(),
    );
    final categories = await serviceLocator<CategoryRepository>().getCategories(
      includeHidden: true,
    );
    expect(categories, hasLength(defaultCategories.length));
    expect(
      categories.map((category) => category.id),
      containsAll(defaultCategories.map((category) => category.id)),
    );

    final firstCubit = serviceLocator<CategoriesCubit>();
    final secondCubit = serviceLocator<CategoriesCubit>();
    addTearDown(firstCubit.close);
    addTearDown(secondCubit.close);
    expect(identical(firstCubit, secondCubit), isFalse);
  });
}
