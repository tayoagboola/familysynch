// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grocery_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GroceryItem {
  String get id => throw _privateConstructorUsedError;
  String get householdId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get quantity => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  bool get checked => throw _privateConstructorUsedError;
  String get addedBy => throw _privateConstructorUsedError;
  String? get checkedBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of GroceryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroceryItemCopyWith<GroceryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroceryItemCopyWith<$Res> {
  factory $GroceryItemCopyWith(
          GroceryItem value, $Res Function(GroceryItem) then) =
      _$GroceryItemCopyWithImpl<$Res, GroceryItem>;
  @useResult
  $Res call(
      {String id,
      String householdId,
      String name,
      String? quantity,
      String? category,
      bool checked,
      String addedBy,
      String? checkedBy,
      DateTime createdAt});
}

/// @nodoc
class _$GroceryItemCopyWithImpl<$Res, $Val extends GroceryItem>
    implements $GroceryItemCopyWith<$Res> {
  _$GroceryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroceryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? name = null,
    Object? quantity = freezed,
    Object? category = freezed,
    Object? checked = null,
    Object? addedBy = null,
    Object? checkedBy = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      checked: null == checked
          ? _value.checked
          : checked // ignore: cast_nullable_to_non_nullable
              as bool,
      addedBy: null == addedBy
          ? _value.addedBy
          : addedBy // ignore: cast_nullable_to_non_nullable
              as String,
      checkedBy: freezed == checkedBy
          ? _value.checkedBy
          : checkedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroceryItemImplCopyWith<$Res>
    implements $GroceryItemCopyWith<$Res> {
  factory _$$GroceryItemImplCopyWith(
          _$GroceryItemImpl value, $Res Function(_$GroceryItemImpl) then) =
      __$$GroceryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String householdId,
      String name,
      String? quantity,
      String? category,
      bool checked,
      String addedBy,
      String? checkedBy,
      DateTime createdAt});
}

/// @nodoc
class __$$GroceryItemImplCopyWithImpl<$Res>
    extends _$GroceryItemCopyWithImpl<$Res, _$GroceryItemImpl>
    implements _$$GroceryItemImplCopyWith<$Res> {
  __$$GroceryItemImplCopyWithImpl(
      _$GroceryItemImpl _value, $Res Function(_$GroceryItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroceryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? name = null,
    Object? quantity = freezed,
    Object? category = freezed,
    Object? checked = null,
    Object? addedBy = null,
    Object? checkedBy = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$GroceryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      checked: null == checked
          ? _value.checked
          : checked // ignore: cast_nullable_to_non_nullable
              as bool,
      addedBy: null == addedBy
          ? _value.addedBy
          : addedBy // ignore: cast_nullable_to_non_nullable
              as String,
      checkedBy: freezed == checkedBy
          ? _value.checkedBy
          : checkedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$GroceryItemImpl implements _GroceryItem {
  const _$GroceryItemImpl(
      {required this.id,
      required this.householdId,
      required this.name,
      this.quantity,
      this.category,
      this.checked = false,
      required this.addedBy,
      this.checkedBy,
      required this.createdAt});

  @override
  final String id;
  @override
  final String householdId;
  @override
  final String name;
  @override
  final String? quantity;
  @override
  final String? category;
  @override
  @JsonKey()
  final bool checked;
  @override
  final String addedBy;
  @override
  final String? checkedBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'GroceryItem(id: $id, householdId: $householdId, name: $name, quantity: $quantity, category: $category, checked: $checked, addedBy: $addedBy, checkedBy: $checkedBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroceryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.checked, checked) || other.checked == checked) &&
            (identical(other.addedBy, addedBy) || other.addedBy == addedBy) &&
            (identical(other.checkedBy, checkedBy) ||
                other.checkedBy == checkedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, householdId, name, quantity,
      category, checked, addedBy, checkedBy, createdAt);

  /// Create a copy of GroceryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroceryItemImplCopyWith<_$GroceryItemImpl> get copyWith =>
      __$$GroceryItemImplCopyWithImpl<_$GroceryItemImpl>(this, _$identity);
}

abstract class _GroceryItem implements GroceryItem {
  const factory _GroceryItem(
      {required final String id,
      required final String householdId,
      required final String name,
      final String? quantity,
      final String? category,
      final bool checked,
      required final String addedBy,
      final String? checkedBy,
      required final DateTime createdAt}) = _$GroceryItemImpl;

  @override
  String get id;
  @override
  String get householdId;
  @override
  String get name;
  @override
  String? get quantity;
  @override
  String? get category;
  @override
  bool get checked;
  @override
  String get addedBy;
  @override
  String? get checkedBy;
  @override
  DateTime get createdAt;

  /// Create a copy of GroceryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroceryItemImplCopyWith<_$GroceryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
