import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/remote/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._datasource);

  final TaskRemoteDatasource _datasource;

  @override
  Stream<List<Task>> watchTasks(String householdId) {
    return _datasource
        .watchTasks(householdId)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Future<void> createTask({
    required String householdId,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points = 0,
  }) =>
      _datasource.createTask(
        householdId: householdId,
        title: title,
        description: description,
        dueDate: dueDate,
        assignedTo: assignedTo,
        points: points,
      );

  @override
  Future<void> updateTask({
    required String id,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points = 0,
  }) =>
      _datasource.updateTask(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        assignedTo: assignedTo,
        points: points,
      );

  @override
  Future<void> toggleComplete(String id, bool completed) =>
      _datasource.toggleComplete(id, completed);

  @override
  Future<void> deleteTask(String id) => _datasource.deleteTask(id);
}
