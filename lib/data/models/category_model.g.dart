// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    _CategoryModel(
      id: json['id'] as String? ?? '',
      type:
          $enumDecodeNullable(
            _$TransactionTypeEnumMap,
            json['type'],
            unknownValue: TransactionType.expense,
          ) ??
          TransactionType.expense,
      name: json['name'] as String? ?? '',
      localizationKey: json['localizationKey'] as String?,
      iconKey: json['iconKey'] as String? ?? 'category',
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF607D8B,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      defaultWallet: $enumDecodeNullable(
        _$WalletTypeEnumMap,
        json['defaultWallet'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      behavior:
          $enumDecodeNullable(
            _$CategoryBehaviorEnumMap,
            json['behavior'],
            unknownValue: CategoryBehavior.standard,
          ) ??
          CategoryBehavior.standard,
    );

Map<String, dynamic> _$CategoryModelToJson(_CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'name': instance.name,
      'localizationKey': instance.localizationKey,
      'iconKey': instance.iconKey,
      'colorValue': instance.colorValue,
      'sortOrder': instance.sortOrder,
      'isDefault': instance.isDefault,
      'isHidden': instance.isHidden,
      'defaultWallet': _$WalletTypeEnumMap[instance.defaultWallet],
      'behavior': _$CategoryBehaviorEnumMap[instance.behavior]!,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};

const _$WalletTypeEnumMap = {
  WalletType.cash: 'cash',
  WalletType.instaPay: 'instaPay',
  WalletType.vodafoneCash: 'vodafoneCash',
};

const _$CategoryBehaviorEnumMap = {
  CategoryBehavior.standard: 'standard',
  CategoryBehavior.personTransfer: 'personTransfer',
};
