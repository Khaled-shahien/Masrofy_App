// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryModel {

 String get id;@JsonKey(unknownEnumValue: TransactionType.expense) TransactionType get type; String get name; String? get localizationKey; String get iconKey; int get colorValue; int get sortOrder; bool get isDefault; bool get isHidden;@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) WalletType? get defaultWallet;@JsonKey(unknownEnumValue: CategoryBehavior.standard) CategoryBehavior get behavior;
/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryModelCopyWith<CategoryModel> get copyWith => _$CategoryModelCopyWithImpl<CategoryModel>(this as CategoryModel, _$identity);

  /// Serializes this CategoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.localizationKey, localizationKey) || other.localizationKey == localizationKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.defaultWallet, defaultWallet) || other.defaultWallet == defaultWallet)&&(identical(other.behavior, behavior) || other.behavior == behavior));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,localizationKey,iconKey,colorValue,sortOrder,isDefault,isHidden,defaultWallet,behavior);

@override
String toString() {
  return 'CategoryModel(id: $id, type: $type, name: $name, localizationKey: $localizationKey, iconKey: $iconKey, colorValue: $colorValue, sortOrder: $sortOrder, isDefault: $isDefault, isHidden: $isHidden, defaultWallet: $defaultWallet, behavior: $behavior)';
}


}

/// @nodoc
abstract mixin class $CategoryModelCopyWith<$Res>  {
  factory $CategoryModelCopyWith(CategoryModel value, $Res Function(CategoryModel) _then) = _$CategoryModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: TransactionType.expense) TransactionType type, String name, String? localizationKey, String iconKey, int colorValue, int sortOrder, bool isDefault, bool isHidden,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) WalletType? defaultWallet,@JsonKey(unknownEnumValue: CategoryBehavior.standard) CategoryBehavior behavior
});




}
/// @nodoc
class _$CategoryModelCopyWithImpl<$Res>
    implements $CategoryModelCopyWith<$Res> {
  _$CategoryModelCopyWithImpl(this._self, this._then);

  final CategoryModel _self;
  final $Res Function(CategoryModel) _then;

/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? localizationKey = freezed,Object? iconKey = null,Object? colorValue = null,Object? sortOrder = null,Object? isDefault = null,Object? isHidden = null,Object? defaultWallet = freezed,Object? behavior = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,localizationKey: freezed == localizationKey ? _self.localizationKey : localizationKey // ignore: cast_nullable_to_non_nullable
as String?,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,defaultWallet: freezed == defaultWallet ? _self.defaultWallet : defaultWallet // ignore: cast_nullable_to_non_nullable
as WalletType?,behavior: null == behavior ? _self.behavior : behavior // ignore: cast_nullable_to_non_nullable
as CategoryBehavior,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryModel].
extension CategoryModelPatterns on CategoryModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryModel value)  $default,){
final _that = this;
switch (_that) {
case _CategoryModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: TransactionType.expense)  TransactionType type,  String name,  String? localizationKey,  String iconKey,  int colorValue,  int sortOrder,  bool isDefault,  bool isHidden, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  WalletType? defaultWallet, @JsonKey(unknownEnumValue: CategoryBehavior.standard)  CategoryBehavior behavior)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.localizationKey,_that.iconKey,_that.colorValue,_that.sortOrder,_that.isDefault,_that.isHidden,_that.defaultWallet,_that.behavior);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: TransactionType.expense)  TransactionType type,  String name,  String? localizationKey,  String iconKey,  int colorValue,  int sortOrder,  bool isDefault,  bool isHidden, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  WalletType? defaultWallet, @JsonKey(unknownEnumValue: CategoryBehavior.standard)  CategoryBehavior behavior)  $default,) {final _that = this;
switch (_that) {
case _CategoryModel():
return $default(_that.id,_that.type,_that.name,_that.localizationKey,_that.iconKey,_that.colorValue,_that.sortOrder,_that.isDefault,_that.isHidden,_that.defaultWallet,_that.behavior);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: TransactionType.expense)  TransactionType type,  String name,  String? localizationKey,  String iconKey,  int colorValue,  int sortOrder,  bool isDefault,  bool isHidden, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  WalletType? defaultWallet, @JsonKey(unknownEnumValue: CategoryBehavior.standard)  CategoryBehavior behavior)?  $default,) {final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.localizationKey,_that.iconKey,_that.colorValue,_that.sortOrder,_that.isDefault,_that.isHidden,_that.defaultWallet,_that.behavior);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryModel extends CategoryModel {
  const _CategoryModel({this.id = '', @JsonKey(unknownEnumValue: TransactionType.expense) this.type = TransactionType.expense, this.name = '', this.localizationKey, this.iconKey = 'category', this.colorValue = 0xFF607D8B, this.sortOrder = 0, this.isDefault = false, this.isHidden = false, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.defaultWallet, @JsonKey(unknownEnumValue: CategoryBehavior.standard) this.behavior = CategoryBehavior.standard}): super._();
  factory _CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(unknownEnumValue: TransactionType.expense) final  TransactionType type;
@override@JsonKey() final  String name;
@override final  String? localizationKey;
@override@JsonKey() final  String iconKey;
@override@JsonKey() final  int colorValue;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool isHidden;
@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  WalletType? defaultWallet;
@override@JsonKey(unknownEnumValue: CategoryBehavior.standard) final  CategoryBehavior behavior;

/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryModelCopyWith<_CategoryModel> get copyWith => __$CategoryModelCopyWithImpl<_CategoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.localizationKey, localizationKey) || other.localizationKey == localizationKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.defaultWallet, defaultWallet) || other.defaultWallet == defaultWallet)&&(identical(other.behavior, behavior) || other.behavior == behavior));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,localizationKey,iconKey,colorValue,sortOrder,isDefault,isHidden,defaultWallet,behavior);

@override
String toString() {
  return 'CategoryModel(id: $id, type: $type, name: $name, localizationKey: $localizationKey, iconKey: $iconKey, colorValue: $colorValue, sortOrder: $sortOrder, isDefault: $isDefault, isHidden: $isHidden, defaultWallet: $defaultWallet, behavior: $behavior)';
}


}

/// @nodoc
abstract mixin class _$CategoryModelCopyWith<$Res> implements $CategoryModelCopyWith<$Res> {
  factory _$CategoryModelCopyWith(_CategoryModel value, $Res Function(_CategoryModel) _then) = __$CategoryModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: TransactionType.expense) TransactionType type, String name, String? localizationKey, String iconKey, int colorValue, int sortOrder, bool isDefault, bool isHidden,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) WalletType? defaultWallet,@JsonKey(unknownEnumValue: CategoryBehavior.standard) CategoryBehavior behavior
});




}
/// @nodoc
class __$CategoryModelCopyWithImpl<$Res>
    implements _$CategoryModelCopyWith<$Res> {
  __$CategoryModelCopyWithImpl(this._self, this._then);

  final _CategoryModel _self;
  final $Res Function(_CategoryModel) _then;

/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? localizationKey = freezed,Object? iconKey = null,Object? colorValue = null,Object? sortOrder = null,Object? isDefault = null,Object? isHidden = null,Object? defaultWallet = freezed,Object? behavior = null,}) {
  return _then(_CategoryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,localizationKey: freezed == localizationKey ? _self.localizationKey : localizationKey // ignore: cast_nullable_to_non_nullable
as String?,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,defaultWallet: freezed == defaultWallet ? _self.defaultWallet : defaultWallet // ignore: cast_nullable_to_non_nullable
as WalletType?,behavior: null == behavior ? _self.behavior : behavior // ignore: cast_nullable_to_non_nullable
as CategoryBehavior,
  ));
}


}

// dart format on
