// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEventModelImpl _$$CalendarEventModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarEventModelImpl(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      isAllDay: json['is_all_day'] as bool,
      assignedTo: json['assigned_to'] as String?,
      color: json['color'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CalendarEventModelImplToJson(
        _$CalendarEventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'title': instance.title,
      'description': instance.description,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'is_all_day': instance.isAllDay,
      'assigned_to': instance.assignedTo,
      'color': instance.color,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
    };
