import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../domain/usecases/categories/category_usecase_exception.dart';
import '../../../domain/usecases/categories/save_custom_category.dart';
import '../../../domain/usecases/categories/set_category_default_wallet.dart';
import '../../../domain/usecases/categories/set_category_visibility.dart';
import '../../../domain/usecases/categories/watch_categories.dart';
import 'categories_state.dart';

export 'categories_state.dart';

/// Coordinates category queries and mutations for the presentation layer.
class CategoriesCubit extends Cubit<CategoriesState> {
  /// Creates a category Cubit backed by domain use cases.
  CategoriesCubit({
    required this._watchCategories,
    required SaveCustomCategory saveCustomCategory,
    required this._setCategoryVisibility,
    required this._setCategoryDefaultWallet,
  }) : _saveCustomCategory = saveCustomCategory,
       super(const CategoriesState());

  final WatchCategories _watchCategories;
  final SaveCustomCategory _saveCustomCategory;
  final SetCategoryVisibility _setCategoryVisibility;
  final SetCategoryDefaultWallet _setCategoryDefaultWallet;

  StreamSubscription<List<Category>>? _subscription;

  /// Loads categories for the currently selected transaction type.
  Future<void> load() => _watch(state.selectedType);

  /// Selects a transaction type and loads its categories.
  Future<void> selectType(TransactionType type) async {
    if (type == state.selectedType &&
        state.status != CategoriesStatus.initial &&
        state.status != CategoriesStatus.failure) {
      return;
    }

    await _watch(type);
  }

  /// Shows or hides a category without deleting it.
  Future<void> setVisibility(String categoryId, bool isVisible) {
    return _mutate(
      () => _setCategoryVisibility(
        categoryId: categoryId,
        isHidden: !isVisible,
      ),
    );
  }

  /// Creates or updates a custom category using normalized domain rules.
  Future<void> saveCustomCategory({
    String? id,
    TransactionType? type,
    required String name,
    required String iconKey,
    required int colorValue,
    int? sortOrder,
    WalletType? defaultWallet,
    CategoryBehavior behavior = CategoryBehavior.standard,
  }) {
    return _mutate(
      () => _saveCustomCategory(
        id: id,
        type: type ?? state.selectedType,
        name: name,
        iconKey: iconKey,
        colorValue: colorValue,
        sortOrder: sortOrder,
        defaultWallet: defaultWallet,
        behavior: behavior,
      ),
    );
  }

  /// Assigns or clears the wallet suggested for a category.
  Future<void> setDefaultWallet(
    String categoryId,
    WalletType? defaultWallet,
  ) {
    return _mutate(
      () => _setCategoryDefaultWallet(
        categoryId: categoryId,
        defaultWallet: defaultWallet,
      ),
    );
  }

  Future<void> _watch(TransactionType type) async {
    await _subscription?.cancel();
    emit(
      state.copyWith(
        status: CategoriesStatus.loading,
        selectedType: type,
        isSaving: false,
        error: null,
      ),
    );

    try {
      _subscription = _watchCategories(
        type: type,
        includeHidden: true,
      ).listen(_categoriesChanged, onError: _watchFailed);
    } on Object catch (error) {
      _emitFailure(error);
    }
  }

  void _categoriesChanged(List<Category> categories) {
    emit(
      state.copyWith(
        status: categories.isEmpty
            ? CategoriesStatus.empty
            : CategoriesStatus.success,
        categories: categories,
        isSaving: false,
        error: null,
      ),
    );
  }

  void _watchFailed(Object error, StackTrace _) {
    _emitFailure(error);
  }

  Future<void> _mutate(Future<Object?> Function() operation) async {
    emit(
      state.copyWith(
        status: _mutationStatus(state),
        isSaving: true,
        error: null,
      ),
    );
    try {
      await operation();
      emit(state.copyWith(isSaving: false, error: null));
    } on Object catch (error) {
      _emitFailure(error);
    }
  }

  void _emitFailure(Object error) {
    emit(
      state.copyWith(
        status: CategoriesStatus.failure,
        isSaving: false,
        error: _mapFailure(error),
      ),
    );
  }

  CategoriesFailure _mapFailure(Object error) => switch (error) {
    CategoryUseCaseException() => CategoriesFailure.validation,
    _ => CategoriesFailure.storage,
  };

  CategoriesStatus _mutationStatus(CategoriesState current) =>
      switch (current.status) {
        CategoriesStatus.initial || CategoriesStatus.failure =>
          current.categories.isEmpty
              ? CategoriesStatus.empty
              : CategoriesStatus.success,
        final status => status,
      };

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
