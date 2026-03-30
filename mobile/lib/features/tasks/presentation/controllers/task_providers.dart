import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_providers.g.dart';

@riverpod
TaskRemoteDatasource taskRemoteDatasource(Ref ref) {
  return TaskRemoteDatasource(ref.watch(supabaseClientProvider));
}

@riverpod
TaskRepository taskRepository(Ref ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDatasourceProvider));
}

@riverpod
Stream<List<Task>> tasks(Ref ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();
  return ref.watch(taskRepositoryProvider).watchTasks(householdId);
}

// Derived: tasks grouped by assignee userId (null key = unassigned)
@riverpod
Map<String?, List<Task>> tasksGrouped(Ref ref) {
  final all = ref.watch(tasksProvider).valueOrNull ?? [];
  final map = <String?, List<Task>>{};
  for (final t in all) {
    (map[t.assignedTo] ??= []).add(t);
  }
  return map;
}

// Derived: incomplete tasks for a specific user
@riverpod
List<Task> pendingTasksForMember(Ref ref, String userId) {
  final all = ref.watch(tasksProvider).valueOrNull ?? [];
  return all
      .where((t) => t.assignedTo == userId && !t.completed)
      .toList();
}

// Streak: consecutive days with at least one completed task by a user
@riverpod
int streakForMember(Ref ref, String userId) {
  final all = ref.watch(tasksProvider).valueOrNull ?? [];
  final completed = all
      .where((t) => t.completedBy == userId && t.completedAt != null)
      .map((t) => DateTime(
            t.completedAt!.toLocal().year,
            t.completedAt!.toLocal().month,
            t.completedAt!.toLocal().day,
          ))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  if (completed.isEmpty) return 0;

  final today = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int streak = 0;
  DateTime cursor = today;

  for (final day in completed) {
    if (day == cursor || day == cursor.subtract(const Duration(days: 1))) {
      streak++;
      cursor = day.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

@riverpod
class TaskActions extends _$TaskActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points = 0,
  }) async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(taskRepositoryProvider)
        .createTask(
          householdId: householdId,
          title: title,
          description: description,
          dueDate: dueDate,
          assignedTo: assignedTo,
          points: points,
        ));
    return !state.hasError;
  }

  Future<bool> updateTask({
    required String id,
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    int points = 0,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(taskRepositoryProvider)
        .updateTask(
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          assignedTo: assignedTo,
          points: points,
        ));
    return !state.hasError;
  }

  Future<bool> toggleComplete(String id, bool completed) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(taskRepositoryProvider).toggleComplete(id, completed));
    return !state.hasError;
  }

  Future<bool> deleteTask(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(taskRepositoryProvider).deleteTask(id));
    return !state.hasError;
  }
}
