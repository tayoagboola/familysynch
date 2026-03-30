import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../controllers/task_providers.dart';

// ── Filter state ──────────────────────────────────────────────────────────────

// 'all' | 'todo' | 'inprogress' | 'done'
final kanbanFilterProvider = StateProvider<String>((ref) => 'all');

// null = all members
final taskMemberFilterProvider = StateProvider<String?>((ref) => null);

// ── Task grouping ─────────────────────────────────────────────────────────────

enum TaskGroup { urgent, todo, done }

class TaskSection {
  const TaskSection({required this.group, required this.tasks});
  final TaskGroup group;
  final List<Task> tasks;
}

/// Groups tasks into urgent / todo / done based on completion + due date.
/// Urgent = not completed AND (dueDate == today OR overdue).
/// Todo    = not completed AND (no due date OR due in future).
/// Done    = completed.
final groupedTasksProvider = Provider<List<TaskSection>>((ref) {
  final all = ref.watch(tasksProvider).valueOrNull ?? [];
  final memberFilter = ref.watch(taskMemberFilterProvider);
  final kanban = ref.watch(kanbanFilterProvider);

  final filtered = memberFilter == null
      ? all
      : all.where((t) => t.assignedTo == memberFilter).toList();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final urgent = <Task>[];
  final todo = <Task>[];
  final done = <Task>[];

  for (final task in filtered) {
    if (task.completed) {
      done.add(task);
    } else if (task.dueDate != null) {
      final due = DateTime(
          task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      if (!due.isAfter(today)) {
        urgent.add(task);
      } else {
        todo.add(task);
      }
    } else {
      todo.add(task);
    }
  }

  // Sort within groups
  urgent.sort((a, b) {
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  });
  todo.sort((a, b) {
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  });
  done.sort((a, b) => (b.completedAt ?? b.createdAt)
      .compareTo(a.completedAt ?? a.createdAt));

  final sections = <TaskSection>[];

  if (kanban == 'all' || kanban == 'inprogress') {
    if (urgent.isNotEmpty) {
      sections.add(TaskSection(group: TaskGroup.urgent, tasks: urgent));
    }
  }
  if (kanban == 'all' || kanban == 'todo') {
    if (todo.isNotEmpty) {
      sections.add(TaskSection(group: TaskGroup.todo, tasks: todo));
    }
  }
  if (kanban == 'all' || kanban == 'done') {
    if (done.isNotEmpty) {
      sections.add(TaskSection(group: TaskGroup.done, tasks: done));
    }
  }

  return sections;
});

// ── Stats ─────────────────────────────────────────────────────────────────────

final taskStatsProvider =
    Provider<({int urgent, int inProgress, int done})>((ref) {
  final all = ref.watch(tasksProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int urgent = 0;
  int inProgress = 0;
  int done = 0;

  for (final task in all) {
    if (task.completed) {
      done++;
    } else if (task.dueDate != null) {
      final due = DateTime(
          task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      if (!due.isAfter(today)) {
        urgent++;
      } else {
        inProgress++;
      }
    } else {
      inProgress++;
    }
  }

  return (urgent: urgent, inProgress: inProgress, done: done);
});
