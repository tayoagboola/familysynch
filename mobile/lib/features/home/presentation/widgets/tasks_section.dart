import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/routes.dart';
import '../../../../features/tasks/domain/entities/task.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/home_providers.dart';

class TasksSection extends ConsumerWidget {
  const TasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Today's Tasks",
          linkText: 'See all →',
          onLinkTap: () => context.go(Routes.tasks),
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeSpacing.screenPadding),
                child: Text(
                  'No tasks due today 🎉',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                ),
              );
            }
            return Column(
              children: tasks
                  .take(4)
                  .map((t) => _TaskItem(task: t))
                  .toList(),
            );
          },
          loading: () => const LoadingSkeletonList(itemCount: 3, itemHeight: 56),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HomeSpacing.screenPadding),
            child: Text(
              'Could not load tasks',
              style: AppTypography.body
                  .copyWith(color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends ConsumerStatefulWidget {
  const _TaskItem({required this.task});
  final Task task;

  @override
  ConsumerState<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<_TaskItem>
    with SingleTickerProviderStateMixin {
  late bool _completed;
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _completed = widget.task.completed;
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _completed = !_completed);
    _checkController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final membersMap = ref.watch(householdMembersMapProvider);
    final assignee = widget.task.assignedTo != null
        ? membersMap[widget.task.assignedTo]
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(HomeSpacing.screenPadding, 0,
          HomeSpacing.screenPadding, HomeSpacing.itemGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          GestureDetector(
            onTap: _toggle,
            child: AnimatedBuilder(
              animation: _checkScale,
              builder: (context, _) => Transform.scale(
                scale: _checkScale.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _completed ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _completed ? AppColors.green : AppColors.textTertiary,
                      width: 2.5,
                    ),
                  ),
                  child: _completed
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTypography.h3.copyWith(
                    fontSize: 14,
                    color: _completed
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    decoration: _completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  child: Text(
                    widget.task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.task.dueDate != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Due today',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (assignee != null)
            MemberAvatar(
              memberId: assignee.id,
              initials: _initials(assignee.displayName),
              size: 28,
              borderRadius: 9,
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}
