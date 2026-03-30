import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/task_model.dart';

class TaskRemoteDatasource {
  TaskRemoteDatasource(this._client);

  final SupabaseClient _client;

  Stream<List<TaskModel>> watchTasks(String householdId) {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(TaskModel.fromJson).toList());
  }

  Future<void> createTask({
    required String householdId,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points = 0,
  }) async {
    await _client.from('tasks').insert({
      'household_id': householdId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toUtc().toIso8601String(),
      'assigned_to': assignedTo,
      'points': points,
      'completed': false,
      'created_by': _client.auth.currentUser!.id,
    });
  }

  Future<void> updateTask({
    required String id,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points = 0,
  }) async {
    await _client.from('tasks').update({
      'title': title,
      'description': description,
      'due_date': dueDate?.toUtc().toIso8601String(),
      'assigned_to': assignedTo,
      'points': points,
    }).eq('id', id);
  }

  Future<void> toggleComplete(String id, bool completed) async {
    await _client.from('tasks').update({
      'completed': completed,
      'completed_at':
          completed ? DateTime.now().toUtc().toIso8601String() : null,
      'completed_by': completed ? _client.auth.currentUser!.id : null,
    }).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}
