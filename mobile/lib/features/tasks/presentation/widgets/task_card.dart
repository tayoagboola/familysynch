import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme.dart';
import '../../../../../core/extensions/color_extension.dart';
import '../../../../../features/household/domain/entities/household_member.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_providers.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.membersMap,
    required this.onTap,
  });

  final Task task;
  final Map<String, HouseholdMember> membersMap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final member = task.assignedTo != null ? membersMap[task.assignedTo] : null;
    final memberColor =
        member != null ? HexColor.fromHex(member.color) : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(children: [
            // Checkbox
            GestureDetector(
              onTap: () => ref
                  .read(taskActionsProvider.notifier)
                  .toggleComplete(task.id, !task.completed),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.completed ? memberColor : Colors.transparent,
                  border: Border.all(
                    color: task.completed
                        ? memberColor
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: task.completed
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.completed
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                  if (task.dueDate != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _DueDateChip(dueDate: task.dueDate!, completed: task.completed),
                  ],
                ],
              ),
            ),

            // Points badge + member avatar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (task.points > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '+${task.points}',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                if (member != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: memberColor,
                    backgroundImage: member.avatarUrl != null
                        ? NetworkImage(member.avatarUrl!)
                        : null,
                    child: member.avatarUrl == null
                        ? Text(
                            member.displayName.isNotEmpty
                                ? member.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class _DueDateChip extends StatelessWidget {
  const _DueDateChip({required this.dueDate, required this.completed});

  final DateTime dueDate;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isOverdue =
        !completed && dueDate.isBefore(DateTime(now.year, now.month, now.day));
    final isToday = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;

    Color color;
    String label;
    if (completed) {
      color = theme.colorScheme.onSurfaceVariant;
      label = DateFormat('MMM d').format(dueDate);
    } else if (isOverdue) {
      color = theme.colorScheme.error;
      label = 'Overdue · ${DateFormat('MMM d').format(dueDate)}';
    } else if (isToday) {
      color = const Color(0xFFE65100);
      label = 'Today';
    } else {
      color = theme.colorScheme.onSurfaceVariant;
      label = DateFormat('MMM d').format(dueDate);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.calendar_today_outlined, size: 12, color: color),
      const SizedBox(width: 2),
      Text(label,
          style: theme.textTheme.labelSmall?.copyWith(color: color)),
    ]);
  }
}
