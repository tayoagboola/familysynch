// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HouseholdMember {
  String get id => throw _privateConstructorUsedError;
  String get householdId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError; // 'adult' | 'child'
  DateTime get joinedAt => throw _privateConstructorUsedError;

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdMemberCopyWith<HouseholdMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseholdMemberCopyWith<$Res> {
  factory $HouseholdMemberCopyWith(
          HouseholdMember value, $Res Function(HouseholdMember) then) =
      _$HouseholdMemberCopyWithImpl<$Res, HouseholdMember>;
  @useResult
  $Res call(
      {String id,
      String householdId,
      String userId,
      String displayName,
      String? avatarUrl,
      String color,
      String role,
      DateTime joinedAt});
}

/// @nodoc
class _$HouseholdMemberCopyWithImpl<$Res, $Val extends HouseholdMember>
    implements $HouseholdMemberCopyWith<$Res> {
  _$HouseholdMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? userId = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? color = null,
    Object? role = null,
    Object? joinedAt = null,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HouseholdMemberImplCopyWith<$Res>
    implements $HouseholdMemberCopyWith<$Res> {
  factory _$$HouseholdMemberImplCopyWith(_$HouseholdMemberImpl value,
          $Res Function(_$HouseholdMemberImpl) then) =
      __$$HouseholdMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String householdId,
      String userId,
      String displayName,
      String? avatarUrl,
      String color,
      String role,
      DateTime joinedAt});
}

/// @nodoc
class __$$HouseholdMemberImplCopyWithImpl<$Res>
    extends _$HouseholdMemberCopyWithImpl<$Res, _$HouseholdMemberImpl>
    implements _$$HouseholdMemberImplCopyWith<$Res> {
  __$$HouseholdMemberImplCopyWithImpl(
      _$HouseholdMemberImpl _value, $Res Function(_$HouseholdMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? userId = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? color = null,
    Object? role = null,
    Object? joinedAt = null,
  }) {
    return _then(_$HouseholdMemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$HouseholdMemberImpl implements _HouseholdMember {
  const _$HouseholdMemberImpl(
      {required this.id,
      required this.householdId,
      required this.userId,
      required this.displayName,
      this.avatarUrl,
      required this.color,
      required this.role,
      required this.joinedAt});

  @override
  final String id;
  @override
  final String householdId;
  @override
  final String userId;
  @override
  final String displayName;
  @override
  final String? avatarUrl;
  @override
  final String color;
  @override
  final String role;
// 'adult' | 'child'
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'HouseholdMember(id: $id, householdId: $householdId, userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, color: $color, role: $role, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, householdId, userId,
      displayName, avatarUrl, color, role, joinedAt);

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdMemberImplCopyWith<_$HouseholdMemberImpl> get copyWith =>
      __$$HouseholdMemberImplCopyWithImpl<_$HouseholdMemberImpl>(
          this, _$identity);
}

abstract class _HouseholdMember implements HouseholdMember {
  const factory _HouseholdMember(
      {required final String id,
      required final String householdId,
      required final String userId,
      required final String displayName,
      final String? avatarUrl,
      required final String color,
      required final String role,
      required final DateTime joinedAt}) = _$HouseholdMemberImpl;

  @override
  String get id;
  @override
  String get householdId;
  @override
  String get userId;
  @override
  String get displayName;
  @override
  String? get avatarUrl;
  @override
  String get color;
  @override
  String get role; // 'adult' | 'child'
  @override
  DateTime get joinedAt;

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdMemberImplCopyWith<_$HouseholdMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
