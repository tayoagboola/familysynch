// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalendarEventModel _$CalendarEventModelFromJson(Map<String, dynamic> json) {
  return _CalendarEventModel.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String get householdId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  DateTime? get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_all_day')
  bool get isAllDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_to')
  String? get assignedTo => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CalendarEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventModelCopyWith<CalendarEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventModelCopyWith<$Res> {
  factory $CalendarEventModelCopyWith(
          CalendarEventModel value, $Res Function(CalendarEventModel) then) =
      _$CalendarEventModelCopyWithImpl<$Res, CalendarEventModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'household_id') String householdId,
      String title,
      String? description,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime? endTime,
      @JsonKey(name: 'is_all_day') bool isAllDay,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      String? color,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$CalendarEventModelCopyWithImpl<$Res, $Val extends CalendarEventModel>
    implements $CalendarEventModelCopyWith<$Res> {
  _$CalendarEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? title = null,
    Object? description = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? isAllDay = null,
    Object? assignedTo = freezed,
    Object? color = freezed,
    Object? createdBy = null,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$CalendarEventModelImplCopyWith<$Res>
    implements $CalendarEventModelCopyWith<$Res> {
  factory _$$CalendarEventModelImplCopyWith(_$CalendarEventModelImpl value,
          $Res Function(_$CalendarEventModelImpl) then) =
      __$$CalendarEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'household_id') String householdId,
      String title,
      String? description,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime? endTime,
      @JsonKey(name: 'is_all_day') bool isAllDay,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      String? color,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$CalendarEventModelImplCopyWithImpl<$Res>
    extends _$CalendarEventModelCopyWithImpl<$Res, _$CalendarEventModelImpl>
    implements _$$CalendarEventModelImplCopyWith<$Res> {
  __$$CalendarEventModelImplCopyWithImpl(_$CalendarEventModelImpl _value,
      $Res Function(_$CalendarEventModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? title = null,
    Object? description = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? isAllDay = null,
    Object? assignedTo = freezed,
    Object? color = freezed,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(_$CalendarEventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
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
@JsonSerializable()
class _$CalendarEventModelImpl implements _CalendarEventModel {
  const _$CalendarEventModelImpl(
      {required this.id,
      @JsonKey(name: 'household_id') required this.householdId,
      required this.title,
      this.description,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') this.endTime,
      @JsonKey(name: 'is_all_day') required this.isAllDay,
      @JsonKey(name: 'assigned_to') this.assignedTo,
      this.color,
      @JsonKey(name: 'created_by') required this.createdBy,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$CalendarEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'household_id')
  final String householdId;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @override
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  @override
  @JsonKey(name: 'is_all_day')
  final bool isAllDay;
  @override
  @JsonKey(name: 'assigned_to')
  final String? assignedTo;
  @override
  final String? color;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'CalendarEventModel(id: $id, householdId: $householdId, title: $title, description: $description, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, assignedTo: $assignedTo, color: $color, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      householdId,
      title,
      description,
      startTime,
      endTime,
      isAllDay,
      assignedTo,
      color,
      createdBy,
      createdAt);

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventModelImplCopyWith<_$CalendarEventModelImpl> get copyWith =>
      __$$CalendarEventModelImplCopyWithImpl<_$CalendarEventModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventModelImplToJson(
      this,
    );
  }
}

abstract class _CalendarEventModel implements CalendarEventModel {
  const factory _CalendarEventModel(
          {required final String id,
          @JsonKey(name: 'household_id') required final String householdId,
          required final String title,
          final String? description,
          @JsonKey(name: 'start_time') required final DateTime startTime,
          @JsonKey(name: 'end_time') final DateTime? endTime,
          @JsonKey(name: 'is_all_day') required final bool isAllDay,
          @JsonKey(name: 'assigned_to') final String? assignedTo,
          final String? color,
          @JsonKey(name: 'created_by') required final String createdBy,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$CalendarEventModelImpl;

  factory _CalendarEventModel.fromJson(Map<String, dynamic> json) =
      _$CalendarEventModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'household_id')
  String get householdId;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;
  @override
  @JsonKey(name: 'end_time')
  DateTime? get endTime;
  @override
  @JsonKey(name: 'is_all_day')
  bool get isAllDay;
  @override
  @JsonKey(name: 'assigned_to')
  String? get assignedTo;
  @override
  String? get color;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventModelImplCopyWith<_$CalendarEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
