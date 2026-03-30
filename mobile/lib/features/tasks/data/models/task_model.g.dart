// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      assignedTo: json['assigned_to'] as String?,
      points: (json['points'] as num).toInt(),
      completed: json['completed'] as bool,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      completedBy: json['completed_by'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'title': instance.title,
      'description': instance.description,
      'due_date': instance.dueDate?.toIso8601String(),
      'assigned_to': instance.assignedTo,
      'points': instance.points,
      'completed': instance.completed,
      'completed_at': instance.completedAt?.toIso8601String(),
      'completed_by': instance.completedBy,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
    };
