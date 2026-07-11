import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction_type.dart';

part 'categories_state.freezed.dart';

/// Describes the current category-loading operation.
enum CategoriesStatus {
  /// Categories have not been requested yet.
  initial,

  /// The category stream is being connected.
  loading,

  /// At least one category is available.
  success,

  /// The selected transaction type has no categories.
  empty,

  /// Loading or mutating categories failed.
  failure,
}

/// Classifies errors without exposing storage details to the UI.
enum CategoriesFailure {
  /// User input or a requested category violated a domain rule.
  validation,

  /// Reading from or writing to the category store failed.
  storage,
}

/// Immutable state exposed by the category presentation Cubit.
@freezed
abstract class CategoriesState with _$CategoriesState {
  /// Creates a category presentation state.
  const factory CategoriesState({
    @Default(CategoriesStatus.initial) CategoriesStatus status,
    @Default(<Category>[]) List<Category> categories,
    @Default(TransactionType.expense) TransactionType selectedType,
    @Default(false) bool isSaving,
    CategoriesFailure? error,
  }) = _CategoriesState;
}
