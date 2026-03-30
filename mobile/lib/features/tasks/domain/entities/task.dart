import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String householdId,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    @Default(0) int points,
    @Default(false) bool completed,
    DateTime? completedAt,
    String? completedBy,
    required String createdBy,
    required DateTime createdAt,
  }) = _Task;
}
