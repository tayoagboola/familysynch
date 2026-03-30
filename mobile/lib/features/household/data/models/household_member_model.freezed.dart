// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HouseholdMemberModel _$HouseholdMemberModelFromJson(Map<String, dynamic> json) {
  return _HouseholdMemberModel.fromJson(json);
}

/// @nodoc
mixin _$HouseholdMemberModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String get householdId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime get joinedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'fcm_token')
  String? get fcmToken => throw _privateConstructorUsedError;

  /// Serializes this HouseholdMemberModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HouseholdMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdMemberModelCopyWith<HouseholdMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseholdMemberModelCopyWith<$Res> {
  factory $HouseholdMemberModelCopyWith(HouseholdMemberModel value,
          $Res Function(HouseholdMemberModel) then) =
      _$HouseholdMemberModelCopyWithImpl<$Res, HouseholdMemberModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'household_id') String householdId,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'display_name') String displayName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String color,
      String role,
      @JsonKey(name: 'joined_at') DateTime joinedAt,
      @JsonKey(name: 'fcm_token') String? fcmToken});
}

/// @nodoc
class _$HouseholdMemberModelCopyWithImpl<$Res,
        $Val extends HouseholdMemberModel>
    implements $HouseholdMemberModelCopyWith<$Res> {
  _$HouseholdMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HouseholdMemberModel
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
    Object? fcmToken = freezed,
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
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HouseholdMemberModelImplCopyWith<$Res>
    implements $HouseholdMemberModelCopyWith<$Res> {
  factory _$$HouseholdMemberModelImplCopyWith(_$HouseholdMemberModelImpl value,
          $Res Function(_$HouseholdMemberModelImpl) then) =
      __$$HouseholdMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'household_id') String householdId,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'display_name') String displayName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String color,
      String role,
      @JsonKey(name: 'joined_at') DateTime joinedAt,
      @JsonKey(name: 'fcm_token') String? fcmToken});
}

/// @nodoc
class __$$HouseholdMemberModelImplCopyWithImpl<$Res>
    extends _$HouseholdMemberModelCopyWithImpl<$Res, _$HouseholdMemberModelImpl>
    implements _$$HouseholdMemberModelImplCopyWith<$Res> {
  __$$HouseholdMemberModelImplCopyWithImpl(_$HouseholdMemberModelImpl _value,
      $Res Function(_$HouseholdMemberModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HouseholdMemberModel
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
    Object? fcmToken = freezed,
  }) {
    return _then(_$HouseholdMemberModelImpl(
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
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseholdMemberModelImpl implements _HouseholdMemberModel {
  const _$HouseholdMemberModelImpl(
      {required this.id,
      @JsonKey(name: 'household_id') required this.householdId,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'display_name') required this.displayName,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      required this.color,
      required this.role,
      @JsonKey(name: 'joined_at') required this.joinedAt,
      @JsonKey(name: 'fcm_token') this.fcmToken});

  factory _$HouseholdMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseholdMemberModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'household_id')
  final String householdId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  final String color;
  @override
  final String role;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;
  @override
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  @override
  String toString() {
    return 'HouseholdMemberModel(id: $id, householdId: $householdId, userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, color: $color, role: $role, joinedAt: $joinedAt, fcmToken: $fcmToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdMemberModelImpl &&
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
                other.joinedAt == joinedAt) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, householdId, userId,
      displayName, avatarUrl, color, role, joinedAt, fcmToken);

  /// Create a copy of HouseholdMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdMemberModelImplCopyWith<_$HouseholdMemberModelImpl>
      get copyWith =>
          __$$HouseholdMemberModelImplCopyWithImpl<_$HouseholdMemberModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseholdMemberModelImplToJson(
      this,
    );
  }
}

abstract class _HouseholdMemberModel implements HouseholdMemberModel {
  const factory _HouseholdMemberModel(
          {required final String id,
          @JsonKey(name: 'household_id') required final String householdId,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'display_name') required final String displayName,
          @JsonKey(name: 'avatar_url') final String? avatarUrl,
          required final String color,
          required final String role,
          @JsonKey(name: 'joined_at') required final DateTime joinedAt,
          @JsonKey(name: 'fcm_token') final String? fcmToken}) =
      _$HouseholdMemberModelImpl;

  factory _HouseholdMemberModel.fromJson(Map<String, dynamic> json) =
      _$HouseholdMemberModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'household_id')
  String get householdId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  String get color;
  @override
  String get role;
  @override
  @JsonKey(name: 'joined_at')
  DateTime get joinedAt;
  @override
  @JsonKey(name: 'fcm_token')
  String? get fcmToken;

  /// Create a copy of HouseholdMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdMemberModelImplCopyWith<_$HouseholdMemberModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
