// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Category {

 String get id; TransactionType get type; String get name; String? get localizationKey; String get iconKey; int get colorValue; int get sortOrder; bool get isDefault; bool get isHidden; WalletType? get defaultWallet; CategoryBehavior get behavior;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.localizationKey, localizationKey) || other.localizationKey == localizationKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.defaultWallet, defaultWallet) || other.defaultWallet == defaultWallet)&&(identical(other.behavior, behavior) || other.behavior == behavior));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,localizationKey,iconKey,colorValue,sortOrder,isDefault,isHidden,defaultWallet,behavior);

@override
String toString() {
  return 'Category(id: $id, type: $type, name: $name, localizationKey: $localizationKey, iconKey: $iconKey, colorValue: $colorValue, sortOrder: $sortOrder, isDefault: $isDefault, isHidden: $isHidden, defaultWallet: $defaultWallet, behavior: $behavior)';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, TransactionType type, String name, String? localizationKey, String iconKey, int colorValue, int sortOrder, bool isDefault, bool isHidden, WalletType? defaultWallet, CategoryBehavior behavior
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
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


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TransactionType type,  String name,  String? localizationKey,  String iconKey,  int colorValue,  int sortOrder,  bool isDefault,  bool isHidden,  WalletType? defaultWallet,  CategoryBehavior behavior)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TransactionType type,  String name,  String? localizationKey,  String iconKey,  int colorValue,  int sortOrder,  bool isDefault,  bool isHidden,  WalletType? defaultWallet,  CategoryBehavior behavior)  $default,) {final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TransactionType type,  String name,  String? localizationKey,  String iconKey,  int colorValue,  int sortOrder,  bool isDefault,  bool isHidden,  WalletType? defaultWallet,  CategoryBehavior behavior)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.localizationKey,_that.iconKey,_that.colorValue,_that.sortOrder,_that.isDefault,_that.isHidden,_that.defaultWallet,_that.behavior);case _:
  return null;

}
}

}

/// @nodoc


class _Category implements Category {
  const _Category({required this.id, required this.type, required this.name, required this.localizationKey, required this.iconKey, required this.colorValue, required this.sortOrder, this.isDefault = false, this.isHidden = false, this.defaultWallet, this.behavior = CategoryBehavior.standard});
  

@override final  String id;
@override final  TransactionType type;
@override final  String name;
@override final  String? localizationKey;
@override final  String iconKey;
@override final  int colorValue;
@override final  int sortOrder;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool isHidden;
@override final  WalletType? defaultWallet;
@override@JsonKey() final  CategoryBehavior behavior;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.localizationKey, localizationKey) || other.localizationKey == localizationKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.defaultWallet, defaultWallet) || other.defaultWallet == defaultWallet)&&(identical(other.behavior, behavior) || other.behavior == behavior));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,localizationKey,iconKey,colorValue,sortOrder,isDefault,isHidden,defaultWallet,behavior);

@override
String toString() {
  return 'Category(id: $id, type: $type, name: $name, localizationKey: $localizationKey, iconKey: $iconKey, colorValue: $colorValue, sortOrder: $sortOrder, isDefault: $isDefault, isHidden: $isHidden, defaultWallet: $defaultWallet, behavior: $behavior)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, TransactionType type, String name, String? localizationKey, String iconKey, int colorValue, int sortOrder, bool isDefault, bool isHidden, WalletType? defaultWallet, CategoryBehavior behavior
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? localizationKey = freezed,Object? iconKey = null,Object? colorValue = null,Object? sortOrder = null,Object? isDefault = null,Object? isHidden = null,Object? defaultWallet = freezed,Object? behavior = null,}) {
  return _then(_Category(
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
