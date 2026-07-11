import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/catalog/default_category_catalog.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/domain/usecases/categories/category_usecase_exception.dart';
import 'package:masrofy/domain/usecases/categories/initialize_default_categories.dart';
import 'package:masrofy/domain/usecases/categories/save_custom_category.dart';
import 'package:masrofy/domain/usecases/categories/set_category_default_wallet.dart';
import 'package:masrofy/domain/usecases/categories/set_category_visibility.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';

void main() {
  late InMemoryCategoryLocalDataSource dataSource;
  late CategoryRepositoryImpl repository;

  setUp(() {
    dataSource = InMemoryCategoryLocalDataSource();
    repository = CategoryRepositoryImpl(localDataSource: dataSource);
  });

  tearDown(() => dataSource.close());

  group('InitializeDefaultCategories', () {
    test(
      'is idempotent and preserves preferences and custom records',
      () async {
        const custom = CategoryModel(
          id: 'custom_gifts',
          type: TransactionType.expense,
          name: 'Gifts',
          iconKey: 'cardGiftcard',
          colorValue: 0xFF101010,
          sortOrder: 20,
        );
        final stale = CategoryModel.fromDomain(
          defaultCategories.first.copyWith(
            name: 'Stale metadata',
            isHidden: true,
            defaultWallet: WalletType.instaPay,
          ),
        );
        await dataSource.saveCategories([custom, stale]);
        final initialize = InitializeDefaultCategories(
          repository: repository,
          defaults: defaultCategories,
        );

        await initialize();
        await initialize();
        final categories = await repository.getCategories(includeHidden: true);
        final refreshed = categories.singleWhere(
          (category) => category.id == defaultCategories.first.id,
        );

        expect(categories, hasLength(defaultCategories.length + 1));
        expect(refreshed.name, defaultCategories.first.name);
        expect(refreshed.isHidden, isTrue);
        expect(refreshed.defaultWallet, WalletType.instaPay);
        expect(
          categories.any((category) => category.id == custom.id),
          isTrue,
        );
      },
    );
  });

  group('SaveCustomCategory', () {
    test('normalizes and persists a new category', () async {
      final save = SaveCustomCategory(
        repository: repository,
        generateId: () => 'generated-id',
      );

      final result = await save(
        type: TransactionType.expense,
        name: '  Gifts  ',
        iconKey: '  cardGiftcard  ',
        colorValue: 0xFF123456,
      );

      expect(result.id, 'generated-id');
      expect(result.name, 'Gifts');
      expect(result.iconKey, 'cardGiftcard');
      expect(await repository.getCategories(), contains(result));
    });

    test('rejects duplicate names for the same transaction type', () async {
      final save = SaveCustomCategory(
        repository: repository,
        generateId: () => 'generated-id',
      );
      await save(
        type: TransactionType.expense,
        name: 'Gifts',
        iconKey: 'cardGiftcard',
        colorValue: 0xFF123456,
      );

      expect(
        () => save(
          type: TransactionType.expense,
          name: ' gifts ',
          iconKey: 'category',
          colorValue: 0xFF654321,
        ),
        throwsA(isA<DuplicateCategoryException>()),
      );
    });

    test('rejects empty input', () {
      final save = SaveCustomCategory(
        repository: repository,
        generateId: () => 'generated-id',
      );

      expect(
        () => save(
          type: TransactionType.income,
          name: ' ',
          iconKey: 'payments',
          colorValue: 0xFF123456,
        ),
        throwsA(isA<InvalidCategoryException>()),
      );
    });
  });

  test('WatchCategories forwards filters to the repository', () async {
    await repository.saveCategories(defaultCategories);
    final watch = WatchCategories(repository);

    final expense = await watch(type: TransactionType.expense).first;

    expect(expense, hasLength(12));
    expect(
      expense.every((category) => category.type == TransactionType.expense),
      isTrue,
    );
  });

  test('SetCategoryVisibility hides without deleting', () async {
    await repository.saveCategory(defaultCategories.first);
    final setVisibility = SetCategoryVisibility(repository);

    final hidden = await setVisibility(
      categoryId: defaultCategories.first.id,
      isHidden: true,
    );

    expect(hidden.isHidden, isTrue);
    expect(await repository.getCategories(), isEmpty);
    expect(
      await repository.getCategories(includeHidden: true),
      contains(hidden),
    );
  });

  test('SetCategoryDefaultWallet assigns and clears a wallet', () async {
    await repository.saveCategory(defaultCategories.first);
    final setWallet = SetCategoryDefaultWallet(repository);

    final assigned = await setWallet(
      categoryId: defaultCategories.first.id,
      defaultWallet: WalletType.vodafoneCash,
    );
    final cleared = await setWallet(
      categoryId: defaultCategories.first.id,
      defaultWallet: null,
    );

    expect(assigned.defaultWallet, WalletType.vodafoneCash);
    expect(cleared.defaultWallet, isNull);
  });

  test('preference use cases report a missing category', () async {
    final setVisibility = SetCategoryVisibility(repository);

    expect(
      () => setVisibility(categoryId: 'missing', isHidden: true),
      throwsA(isA<CategoryNotFoundException>()),
    );
  });
}
