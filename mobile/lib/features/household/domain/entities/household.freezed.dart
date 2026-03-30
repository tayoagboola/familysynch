// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Household {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarEmoji => throw _privateConstructorUsedError;
  String get inviteCode => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of Household
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdCopyWith<Household> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseholdCopyWith<$Res> {
  factory $HouseholdCopyWith(Household value, $Res Function(Household) then) =
      _$HouseholdCopyWithImpl<$Res, Household>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? avatarEmoji,
      String inviteCode,
      String createdBy,
      DateTime createdAt});
}

/// @nodoc
class _$HouseholdCopyWithImpl<$Res, $Val extends Household>
    implements $HouseholdCopyWith<$Res> {
  _$HouseholdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Household
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarEmoji = freezed,
    Object? inviteCode = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarEmoji: freezed == avatarEmoji
          ? _value.avatarEmoji
          : avatarEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HouseholdImplCopyWith<$Res>
    implements $HouseholdCopyWith<$Res> {
  factory _$$HouseholdImplCopyWith(
          _$HouseholdImpl value, $Res Function(_$HouseholdImpl) then) =
      __$$HouseholdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? avatarEmoji,
      String inviteCode,
      String createdBy,
      DateTime createdAt});
}

/// @nodoc
class __$$HouseholdImplCopyWithImpl<$Res>
    extends _$HouseholdCopyWithImpl<$Res, _$HouseholdImpl>
    implements _$$HouseholdImplCopyWith<$Res> {
  __$$HouseholdImplCopyWithImpl(
      _$HouseholdImpl _value, $Res Function(_$HouseholdImpl) _then)
      : super(_value, _then);

  /// Create a copy of Household
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarEmoji = freezed,
    Object? inviteCode = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(_$HouseholdImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarEmoji: freezed == avatarEmoji
          ? _value.avatarEmoji
          : avatarEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$HouseholdImpl implements _Household {
  const _$HouseholdImpl(
      {required this.id,
      required this.name,
      this.avatarEmoji,
      required this.inviteCode,
      required this.createdBy,
      required this.createdAt});

  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatarEmoji;
  @override
  final String inviteCode;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Household(id: $id, name: $name, avatarEmoji: $avatarEmoji, inviteCode: $inviteCode, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarEmoji, avatarEmoji) ||
                other.avatarEmoji == avatarEmoji) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, avatarEmoji, inviteCode, createdBy, createdAt);

  /// Create a copy of Household
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdImplCopyWith<_$HouseholdImpl> get copyWith =>
      __$$HouseholdImplCopyWithImpl<_$HouseholdImpl>(this, _$identity);
}

abstract class _Household implements Household {
  const factory _Household(
      {required final String id,
      required final String name,
      final String? avatarEmoji,
      required final String inviteCode,
      required final String createdBy,
      required final DateTime createdAt}) = _$HouseholdImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get avatarEmoji;
  @override
  String get inviteCode;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of Household
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdImplCopyWith<_$HouseholdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
