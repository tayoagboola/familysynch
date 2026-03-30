// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedPost {
  String get id => throw _privateConstructorUsedError;
  String get householdId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedPostCopyWith<FeedPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedPostCopyWith<$Res> {
  factory $FeedPostCopyWith(FeedPost value, $Res Function(FeedPost) then) =
      _$FeedPostCopyWithImpl<$Res, FeedPost>;
  @useResult
  $Res call(
      {String id,
      String householdId,
      String content,
      String? imageUrl,
      String authorId,
      DateTime createdAt});
}

/// @nodoc
class _$FeedPostCopyWithImpl<$Res, $Val extends FeedPost>
    implements $FeedPostCopyWith<$Res> {
  _$FeedPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? authorId = null,
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
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedPostImplCopyWith<$Res>
    implements $FeedPostCopyWith<$Res> {
  factory _$$FeedPostImplCopyWith(
          _$FeedPostImpl value, $Res Function(_$FeedPostImpl) then) =
      __$$FeedPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String householdId,
      String content,
      String? imageUrl,
      String authorId,
      DateTime createdAt});
}

/// @nodoc
class __$$FeedPostImplCopyWithImpl<$Res>
    extends _$FeedPostCopyWithImpl<$Res, _$FeedPostImpl>
    implements _$$FeedPostImplCopyWith<$Res> {
  __$$FeedPostImplCopyWithImpl(
      _$FeedPostImpl _value, $Res Function(_$FeedPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? authorId = null,
    Object? createdAt = null,
  }) {
    return _then(_$FeedPostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$FeedPostImpl implements _FeedPost {
  const _$FeedPostImpl(
      {required this.id,
      required this.householdId,
      required this.content,
      this.imageUrl,
      required this.authorId,
      required this.createdAt});

  @override
  final String id;
  @override
  final String householdId;
  @override
  final String content;
  @override
  final String? imageUrl;
  @override
  final String authorId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FeedPost(id: $id, householdId: $householdId, content: $content, imageUrl: $imageUrl, authorId: $authorId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedPostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, householdId, content, imageUrl, authorId, createdAt);

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedPostImplCopyWith<_$FeedPostImpl> get copyWith =>
      __$$FeedPostImplCopyWithImpl<_$FeedPostImpl>(this, _$identity);
}

abstract class _FeedPost implements FeedPost {
  const factory _FeedPost(
      {required final String id,
      required final String householdId,
      required final String content,
      final String? imageUrl,
      required final String authorId,
      required final DateTime createdAt}) = _$FeedPostImpl;

  @override
  String get id;
  @override
  String get householdId;
  @override
  String get content;
  @override
  String? get imageUrl;
  @override
  String get authorId;
  @override
  DateTime get createdAt;

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedPostImplCopyWith<_$FeedPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
