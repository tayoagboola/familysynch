import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  const TaskModel({
    required this.id,
    required this.householdId,
    required this.title,
    this.description,
    this.dueDate,
    this.assignedTo,
    required this.points,
    required this.completed,
    this.completedAt,
    this.completedBy,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  @JsonKey(name: 'household_id')
  final String householdId;
  final String title;
  final String? description;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @JsonKey(name: 'assigned_to')
  final String? assignedTo;
  final int points;
  final bool completed;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'completed_by')
  final String? completedBy;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  Task toDomain() => Task(
        id: id,
        householdId: householdId,
        title: title,
        description: description,
        dueDate: dueDate,
        assignedTo: assignedTo,
        points: points,
        completed: completed,
        completedAt: completedAt,
        completedBy: completedBy,
        createdBy: createdBy,
        createdAt: createdAt,
      );
}
