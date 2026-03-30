import '../entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks(String householdId);

  Future<void> createTask({
    required String householdId,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points,
  });

  Future<void> updateTask({
    required String id,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points,
  });

  Future<void> toggleComplete(String id, bool completed);

  Future<void> deleteTask(String id);
}
