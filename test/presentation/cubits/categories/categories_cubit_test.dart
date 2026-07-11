import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/domain/repositories/category_repository.dart';
import 'package:masrofy/domain/usecases/categories/save_custom_category.dart';
import 'package:masrofy/domain/usecases/categories/set_category_default_wallet.dart';
import 'package:masrofy/domain/usecases/categories/set_category_visibility.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';
import 'package:masrofy/presentation/cubits/categories/categories_cubit.dart';

void main() {
  const expenseCategory = Category(
    id: 'food',
    type: TransactionType.expense,
    name: '',
    localizationKey: 'categoryFood',
    iconKey: 'restaurant',
    colorValue: 0xFF4CAF50,
    sortOrder: 0,
    isDefault: true,
  );
  const incomeCategory = Category(
    id: 'salary',
    type: TransactionType.income,
    name: '',
    localizationKey: 'categorySalary',
    iconKey: 'payments',
    colorValue: 0xFF2196F3,
    sortOrder: 0,
    isDefault: true,
  );

  late _FakeCategoryRepository repository;

  CategoriesCubit buildCubit() => CategoriesCubit(
    watchCategories: WatchCategories(repository),
    saveCustomCategory: SaveCustomCategory(
      repository: repository,
      generateId: () => 'custom-id',
    ),
    setCategoryVisibility: SetCategoryVisibility(repository),
    setCategoryDefaultWallet: SetCategoryDefaultWallet(repository),
  );

  setUp(() {
    repository = _FakeCategoryRepository();
  });

  tearDown(() async {
    await repository.close();
  });

  test('starts with expense selected and no operation in progress', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state, const CategoriesState());
    expect(cubit.state.selectedType, TransactionType.expense);
    expect(cubit.state.status, CategoriesStatus.initial);
    expect(cubit.state.isSaving, isFalse);
  });

  blocTest<CategoriesCubit, CategoriesState>(
    'emits loading then success when categories arrive',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      repository.emit(const [expenseCategory]);
    },
    expect: () => const [
      CategoriesState(status: CategoriesStatus.loading),
      CategoriesState(
        status: CategoriesStatus.success,
        categories: [expenseCategory],
      ),
    ],
    verify: (_) {
      expect(repository.lastWatchedType, TransactionType.expense);
      expect(repository.lastIncludeHidden, isTrue);
    },
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'emits empty when the selected type has no categories',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      repository.emit(const []);
    },
    expect: () => const [
      CategoriesState(status: CategoriesStatus.loading),
      CategoriesState(status: CategoriesStatus.empty),
    ],
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'maps category stream failures to storage errors',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      repository.emitError(StateError('read failed'));
    },
    expect: () => const [
      CategoriesState(status: CategoriesStatus.loading),
      CategoriesState(
        status: CategoriesStatus.failure,
        error: CategoriesFailure.storage,
      ),
    ],
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'selectType reconnects the stream with the selected income type',
    build: buildCubit,
    act: (cubit) async {
      await cubit.selectType(TransactionType.income);
      repository.emit(const [incomeCategory]);
    },
    expect: () => const [
      CategoriesState(
        status: CategoriesStatus.loading,
        selectedType: TransactionType.income,
      ),
      CategoriesState(
        status: CategoriesStatus.success,
        categories: [incomeCategory],
        selectedType: TransactionType.income,
      ),
    ],
    verify: (_) {
      expect(repository.lastWatchedType, TransactionType.income);
    },
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'setVisibility exposes saving and persists the inverse hidden value',
    setUp: () {
      repository.storedCategories = const [expenseCategory];
    },
    build: buildCubit,
    seed: () => const CategoriesState(
      status: CategoriesStatus.success,
      categories: [expenseCategory],
    ),
    act: (cubit) => cubit.setVisibility(expenseCategory.id, false),
    expect: () => const [
      CategoriesState(
        status: CategoriesStatus.success,
        categories: [expenseCategory],
        isSaving: true,
      ),
      CategoriesState(
        status: CategoriesStatus.success,
        categories: [expenseCategory],
      ),
    ],
    verify: (_) {
      expect(repository.savedCategory?.id, expenseCategory.id);
      expect(repository.savedCategory?.isHidden, isTrue);
    },
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'saveCustomCategory uses the selected type and chosen wallet',
    build: buildCubit,
    seed: () => const CategoriesState(status: CategoriesStatus.empty),
    act: (cubit) => cubit.saveCustomCategory(
      name: '  Coffee  ',
      iconKey: 'coffee',
      colorValue: 0xFF795548,
      defaultWallet: WalletType.instaPay,
    ),
    expect: () => const [
      CategoriesState(status: CategoriesStatus.empty, isSaving: true),
      CategoriesState(status: CategoriesStatus.empty),
    ],
    verify: (_) {
      expect(repository.savedCategory?.id, 'custom-id');
      expect(repository.savedCategory?.name, 'Coffee');
      expect(repository.savedCategory?.type, TransactionType.expense);
      expect(repository.savedCategory?.defaultWallet, WalletType.instaPay);
    },
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'maps invalid custom category input to a validation error',
    build: buildCubit,
    seed: () => const CategoriesState(status: CategoriesStatus.empty),
    act: (cubit) => cubit.saveCustomCategory(
      name: '   ',
      iconKey: 'coffee',
      colorValue: 0xFF795548,
    ),
    expect: () => const [
      CategoriesState(status: CategoriesStatus.empty, isSaving: true),
      CategoriesState(
        status: CategoriesStatus.failure,
        error: CategoriesFailure.validation,
      ),
    ],
    verify: (_) {
      expect(repository.savedCategory, isNull);
    },
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'setDefaultWallet maps repository failures to storage errors',
    setUp: () {
      repository
        ..storedCategories = const [expenseCategory]
        ..saveError = StateError('write failed');
    },
    build: buildCubit,
    seed: () => const CategoriesState(
      status: CategoriesStatus.success,
      categories: [expenseCategory],
    ),
    act: (cubit) => cubit.setDefaultWallet(
      expenseCategory.id,
      WalletType.vodafoneCash,
    ),
    expect: () => const [
      CategoriesState(
        status: CategoriesStatus.success,
        categories: [expenseCategory],
        isSaving: true,
      ),
      CategoriesState(
        status: CategoriesStatus.failure,
        categories: [expenseCategory],
        error: CategoriesFailure.storage,
      ),
    ],
  );
}

class _FakeCategoryRepository implements CategoryRepository {
  final StreamController<List<Category>> _controller =
      StreamController<List<Category>>.broadcast(sync: true);

  List<Category> storedCategories = const [];
  Category? savedCategory;
  Object? saveError;
  TransactionType? lastWatchedType;
  bool? lastIncludeHidden;

  @override
  Stream<List<Category>> watchCategories({
    TransactionType? type,
    bool includeHidden = false,
  }) {
    lastWatchedType = type;
    lastIncludeHidden = includeHidden;
    return _controller.stream;
  }

  @override
  Future<List<Category>> getCategories({
    TransactionType? type,
    bool includeHidden = false,
  }) async {
    return storedCategories
        .where(
          (category) =>
              (type == null || category.type == type) &&
              (includeHidden || !category.isHidden),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveCategory(Category category) async {
    final error = saveError;
    if (error != null) {
      throw error;
    }

    savedCategory = category;
    storedCategories = [
      for (final stored in storedCategories)
        if (stored.id != category.id) stored,
      category,
    ];
  }

  @override
  Future<void> saveCategories(Iterable<Category> categories) async {
    for (final category in categories) {
      await saveCategory(category);
    }
  }

  void emit(List<Category> categories) => _controller.add(categories);

  void emitError(Object error) {
    _controller.addError(error, StackTrace.current);
  }

  Future<void> close() => _controller.close();
}
