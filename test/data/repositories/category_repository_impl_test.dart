import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';

void main() {
  late InMemoryCategoryLocalDataSource dataSource;
  late CategoryRepositoryImpl repository;

  setUp(() {
    dataSource = InMemoryCategoryLocalDataSource([
      const CategoryModel(
        id: 'expense_second',
        type: TransactionType.expense,
        name: 'Second',
        iconKey: 'category',
        sortOrder: 2,
      ),
      const CategoryModel(
        id: 'expense_hidden',
        type: TransactionType.expense,
        name: 'Hidden',
        iconKey: 'category',
        sortOrder: 0,
        isHidden: true,
      ),
      const CategoryModel(
        id: 'expense_first',
        type: TransactionType.expense,
        name: 'First',
        iconKey: 'category',
        sortOrder: 1,
      ),
      const CategoryModel(
        id: 'income_salary',
        type: TransactionType.income,
        name: 'Salary',
        iconKey: 'payments',
        sortOrder: 0,
      ),
    ]);
    repository = CategoryRepositoryImpl(localDataSource: dataSource);
  });

  tearDown(() => dataSource.close());

  test('filters by type and visibility then sorts by order', () async {
    final categories = await repository.getCategories(
      type: TransactionType.expense,
    );

    expect(
      categories.map((category) => category.id),
      orderedEquals(const ['expense_first', 'expense_second']),
    );
  });

  test('watch emits after saving a category', () async {
    final emissions = repository
        .watchCategories(type: TransactionType.income)
        .take(2)
        .toList();

    await Future<void>.delayed(Duration.zero);
    await repository.saveCategory(
      const Category(
        id: 'income_bonus',
        type: TransactionType.income,
        name: 'Bonus',
        localizationKey: null,
        iconKey: 'payments',
        colorValue: 0xFF123456,
        sortOrder: 1,
      ),
    );
    final values = await emissions;

    expect(values.first, hasLength(1));
    expect(values.last, hasLength(2));
  });
}
