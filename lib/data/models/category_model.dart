import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/entities/wallet_type.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

/// Serializable representation of a transaction category.
@freezed
abstract class CategoryModel with _$CategoryModel {
  /// Creates a serializable category record.
  const factory CategoryModel({
    @Default('') String id,
    @JsonKey(unknownEnumValue: TransactionType.expense)
    @Default(TransactionType.expense)
    TransactionType type,
    @Default('') String name,
    String? localizationKey,
    @Default('category') String iconKey,
    @Default(0xFF607D8B) int colorValue,
    @Default(0) int sortOrder,
    @Default(false) bool isDefault,
    @Default(false) bool isHidden,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    WalletType? defaultWallet,
    @JsonKey(unknownEnumValue: CategoryBehavior.standard)
    @Default(CategoryBehavior.standard)
    CategoryBehavior behavior,
  }) = _CategoryModel;

  const CategoryModel._();

  /// Decodes a category while applying defaults for older stored records.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeLegacyJson(json);
    final model = _$CategoryModelFromJson(normalized);

    if (model.id.isEmpty || model.name.isEmpty) {
      throw const FormatException('Invalid or missing category identity.');
    }
    _validateEnumValue(normalized['type'], TransactionType.values, 'type');
    _validateNullableEnumValue(
      normalized['defaultWallet'],
      WalletType.values,
      'defaultWallet',
    );
    _validateEnumValue(
      normalized['behavior'],
      CategoryBehavior.values,
      'behavior',
    );
    return model;
  }

  /// Creates a storage record from a domain category.
  factory CategoryModel.fromDomain(Category category) {
    return CategoryModel(
      id: category.id,
      type: category.type,
      name: category.name,
      localizationKey: category.localizationKey,
      iconKey: category.iconKey,
      colorValue: category.colorValue,
      sortOrder: category.sortOrder,
      isDefault: category.isDefault,
      isHidden: category.isHidden,
      defaultWallet: category.defaultWallet,
      behavior: category.behavior,
    );
  }

  /// Converts this storage record to a domain category.
  Category toDomain() {
    return Category(
      id: id,
      type: type,
      name: name,
      localizationKey: localizationKey,
      iconKey: iconKey,
      colorValue: colorValue,
      sortOrder: sortOrder,
      isDefault: isDefault,
      isHidden: isHidden,
      defaultWallet: defaultWallet,
      behavior: behavior,
    );
  }
}

Map<String, dynamic> _normalizeLegacyJson(Map<String, dynamic> json) {
  return <String, dynamic>{
    ...json,
    'isHidden': json['isHidden'] ?? json['is_hidden'] ?? false,
    'defaultWallet': json['defaultWallet'] ?? json['default_wallet'],
  };
}

void _validateEnumValue<T extends Enum>(
  Object? value,
  List<T> values,
  String fieldName,
) {
  if (value == null) {
    return;
  }

  if (value is! String) {
    throw FormatException('Invalid enum value for $fieldName.');
  }

  final valid = values.any((enumValue) => enumValue.name == value);
  if (!valid) {
    throw FormatException('Invalid enum value for $fieldName.');
  }
}

void _validateNullableEnumValue<T extends Enum>(
  Object? value,
  List<T> values,
  String fieldName,
) {
  if (value == null) {
    return;
  }

  if (value is! String) {
    throw FormatException('Invalid enum value for $fieldName.');
  }

  final valid = values.any((enumValue) => enumValue.name == value);
  if (!valid) {
    throw FormatException('Invalid enum value for $fieldName.');
  }
}
