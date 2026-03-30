import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme.dart';
import '../../../../../core/extensions/color_extension.dart';
import '../../../../../shared/providers/household_providers.dart';
import '../../../../../shared/providers/supabase_provider.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/controllers/task_providers.dart';
import '../../../tasks/presentation/widgets/streak_badge.dart';

class KidTasksScreen extends ConsumerWidget {
  const KidTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserId =
        ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';
    final tasksAsync = ref.watch(tasksProvider);
    final membersMap = ref.watch(householdMembersMapProvider);
    final member = membersMap[currentUserId];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member != null ? 'Hi, ${member.displayName}! 👋' : 'My Tasks',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (member != null) ...[
                  const SizedBox(height: 2),
                  StreakBadge(userId: currentUserId),
                ],
              ],
            ),
            expandedHeight: 100,
            floating: true,
            snap: true,
            surfaceTintColor: theme.colorScheme.surface,
          ),
          tasksAsync.when(
            loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator())),
            error: (_, __) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.warning_amber_outlined, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    const Text('Could not load tasks.'),
                    TextButton(
                      onPressed: () => ref.invalidate(tasksProvider),
                      child: const Text('Try again'),
                    ),
                  ]),
                ),
              ),
            ),
            data: (allTasks) {
              final myTasks = allTasks
                  .where((t) => t.assignedTo == currentUserId)
                  .toList();
              final pending =
                  myTasks.where((t) => !t.completed).toList();
              final done = myTasks.where((t) => t.completed).toList();

              if (myTasks.isEmpty) {
                return SliverToBoxAdapter(child: _KidEmpty());
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  if (pending.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'To Do',
                      count: pending.length,
                      color: theme.colorScheme.primary,
                    ),
                    ...pending.map((t) => _KidTaskTile(
                          task: t,
                          memberColor: member != null
                              ? HexColor.fromHex(member.color)
                              : theme.colorScheme.primary,
                          onToggle: () => ref
                              .read(taskActionsProvider.notifier)
                              .toggleComplete(t.id, true),
                        )),
                  ],
                  if (done.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Done today 🎉',
                      count: done.length,
                      color: const Color(0xFF4CAF50),
                    ),
                    ...done.map((t) => _KidTaskTile(
                          task: t,
                          memberColor: const Color(0xFF4CAF50),
                          onToggle: () => ref
                              .read(taskActionsProvider.notifier)
                              .toggleComplete(t.id, false),
                        )),
                  ],
                  const SizedBox(height: AppSpacing.xxl + 56),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(children: [
        Text(label,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text('$count',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _KidTaskTile extends StatelessWidget {
  const _KidTaskTile({
    required this.task,
    required this.memberColor,
    required this.onToggle,
  });

  final Task task;
  final Color memberColor;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Material(
        color: task.completed
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        elevation: task.completed ? 0 : 1,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(children: [
              // Large check circle — min 56px touch target
              SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.completed
                          ? memberColor
                          : Colors.transparent,
                      border: Border.all(
                        color: task.completed
                            ? memberColor
                            : theme.colorScheme.outline,
                        width: 2.5,
                      ),
                    ),
                    child: task.completed
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    if (task.description != null)
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (task.points > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Column(children: [
                  Text('⭐',
                      style: const TextStyle(fontSize: 20)),
                  Text('${task.points}',
                      style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF9800))),
                ]),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class _KidEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 64)),
        const SizedBox(height: AppSpacing.md),
        Text('All done!',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Text('No tasks right now. Great job!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}
