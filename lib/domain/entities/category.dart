import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_type.dart';
import 'wallet_type.dart';

part 'category.freezed.dart';

/// Describes behavior that is specific to a category.
enum CategoryBehavior {
  /// A regular income or expense category.
  standard,

  /// An expense category that also captures a person's name.
  personTransfer,
}

/// Defines a transaction category independently of storage and Flutter UI.
@freezed
abstract class Category with _$Category {
  /// Creates a transaction category.
  const factory Category({
    required String id,
    required TransactionType type,
    required String name,
    required String? localizationKey,
    required String iconKey,
    required int colorValue,
    required int sortOrder,
    @Default(false) bool isDefault,
    @Default(false) bool isHidden,
    WalletType? defaultWallet,
    @Default(CategoryBehavior.standard) CategoryBehavior behavior,
  }) = _Category;
}
