/// TaskService — task CRUD + WebSocket real-time stream.
///
/// watchTasks() returns a Stream that:
///   1. Connects to /ws/tasks on first call
///   2. Emits full list on connect (tasks:initial)
///   3. Updates list on every WebSocket event (task_added, completed, etc.)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';
import 'package:familysynch/shared/services/ws_client.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.read(apiClientProvider), ref.read(wsClientProvider));
});

class TaskService {
  final ApiClient _api;
  final WsClient _ws;
  TaskService(this._api, this._ws);

  // ── REST ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTasks({
    String? memberId,
    bool? isCompleted,
    String? priority,
    String? dueDate,
  }) =>
      _api.get('/tasks', queryParameters: {
        if (memberId != null) 'member_id': memberId,
        if (isCompleted != null) 'is_completed': isCompleted,
        if (priority != null) 'priority': priority,
        if (dueDate != null) 'due_date': dueDate,
      });

  Future<Map<String, dynamic>> getTask(String taskId) =>
      _api.get('/tasks/$taskId');

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> body) =>
      _api.post('/tasks', body: body);

  Future<Map<String, dynamic>> updateTask(
          String taskId, Map<String, dynamic> body) =>
      _api.put('/tasks/$taskId', body: body);

  Future<Map<String, dynamic>> completeTask(String taskId) =>
      _api.post('/tasks/$taskId/complete');

  Future<Map<String, dynamic>> uncompleteTask(String taskId) =>
      _api.post('/tasks/$taskId/uncomplete');

  Future<void> deleteTask(String taskId) => _api.delete('/tasks/$taskId');

  Future<Map<String, dynamic>> createSubtask(String taskId, String title) =>
      _api.post('/tasks/$taskId/subtasks', body: {'title': title});

  Future<Map<String, dynamic>> updateSubtask(
          String taskId, String subtaskId, Map<String, dynamic> body) =>
      _api.put('/tasks/$taskId/subtasks/$subtaskId', body: body);

  Future<void> deleteSubtask(String taskId, String subtaskId) =>
      _api.delete('/tasks/$taskId/subtasks/$subtaskId');

  // ── WebSocket ──────────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> watchTasks() => _ws.connect('/ws/tasks');
}
