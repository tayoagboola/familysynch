import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/ai_fab.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_providers.dart';
import '../providers/task_extra_providers.dart';

class TaskBoardScreen extends ConsumerStatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  ConsumerState<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends ConsumerState<TaskBoardScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: const AIFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const _TaskHeader(),
          const _KanbanFilterTabs(),
          const _MemberFilterRow(),
          const Expanded(child: _TaskList()),
        ],
      ),
    );
  }
}

// ── Dark Header ───────────────────────────────────────────────────────────────

class _TaskHeader extends ConsumerWidget {
  const _TaskHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TaskHeaderTop(),
              const SizedBox(height: 16),
              const _TaskStatsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskHeaderTop extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.h1.copyWith(fontSize: 22),
              children: const [
                TextSpan(
                  text: 'Task ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Board',
                  style: TextStyle(color: AppColors.yellow),
                ),
              ],
            ),
          ),
        ),
        // Filter button
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded,
                    size: 13, color: Colors.white.withAlpha(179)),
                const SizedBox(width: 5),
                Text(
                  'Filter',
                  style: AppTypography.label.copyWith(
                    fontSize: 12,
                    color: Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // New task button
        GestureDetector(
          onTap: () => context.push(Routes.taskNew),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(11),
              boxShadow: const [HomeShadow.card],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 13, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  'New',
                  style: AppTypography.label.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stat Chips ────────────────────────────────────────────────────────────────

class _TaskStatsRow extends ConsumerWidget {
  const _TaskStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(taskStatsProvider);

    return Row(
      children: [
        Expanded(
          child: _TaskStatChip(
            label: 'URGENT',
            count: stats.urgent,
            color: AppColors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TaskStatChip(
            label: 'IN PROGRESS',
            count: stats.inProgress,
            color: AppColors.yellow,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TaskStatChip(
            label: 'DONE',
            count: stats.done,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }
}

class _TaskStatChip extends StatelessWidget {
  const _TaskStatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: count),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, value, __) => Text(
              '$value',
              style: AppTypography.h1.copyWith(
                fontSize: 20,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: Colors.white.withAlpha(115),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kanban Filter Tabs ────────────────────────────────────────────────────────

class _KanbanFilterTabs extends ConsumerWidget {
  const _KanbanFilterTabs();

  static const _tabs = [
    ('all', 'All'),
    ('todo', 'To Do'),
    ('inprogress', 'In Progress'),
    ('done', 'Done'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(kanbanFilterProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isActive = selected == tab.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(kanbanFilterProvider.notifier).state = tab.$1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isActive ? const [HomeShadow.card] : null,
                ),
                child: Center(
                  child: Text(
                    tab.$2,
                    style: AppTypography.label.copyWith(
                      fontSize: 12,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Member Filter Row ─────────────────────────────────────────────────────────

class _MemberFilterRow extends ConsumerWidget {
  const _MemberFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(householdMembersProvider).valueOrNull ?? [];
    final selected = ref.watch(taskMemberFilterProvider);

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
            HomeSpacing.screenPadding, 8, HomeSpacing.screenPadding, 4),
        children: [
          GestureDetector(
            onTap: () =>
                ref.read(taskMemberFilterProvider.notifier).state = null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: selected == null
                    ? AppColors.primaryLight
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected == null
                      ? AppColors.primary
                      : AppColors.border,
                  width: selected == null ? 2 : 1.5,
                ),
              ),
              child: Text(
                'All',
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  color: selected == null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          ...members.map((member) {
            final isSelected = selected == member.id;
            final initials = _initials(member.displayName);
            return GestureDetector(
              onTap: () =>
                  ref.read(taskMemberFilterProvider.notifier).state =
                      isSelected ? null : member.id,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MemberAvatar(
                      memberId: member.id,
                      initials: initials,
                      size: 20,
                      borderRadius: 6,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      member.displayName.split(' ').first,
                      style: AppTypography.label.copyWith(
                        fontSize: 12,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

// ── Task List ─────────────────────────────────────────────────────────────────

class _TaskList extends ConsumerWidget {
  const _TaskList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final sections = ref.watch(groupedTasksProvider);

    return tasksAsync.when(
      loading: () => const LoadingSkeletonList(
          itemCount: 4,
          itemHeight: 80,
          padding: EdgeInsets.fromLTRB(22, 16, 22, 0)),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text('Could not load tasks',
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => ref.invalidate(tasksProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Retry',
                    style: AppTypography.label
                        .copyWith(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
      data: (_) {
        if (sections.isEmpty) {
          return _EmptyState();
        }
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 120),
          children: sections.map((section) {
            return _TaskColumnSection(section: section);
          }).toList(),
        );
      },
    );
  }
}

// ── Column Section ────────────────────────────────────────────────────────────

class _TaskColumnSection extends StatefulWidget {
  const _TaskColumnSection({required this.section});
  final TaskSection section;

  @override
  State<_TaskColumnSection> createState() => _TaskColumnSectionState();
}

class _TaskColumnSectionState extends State<_TaskColumnSection>
    with SingleTickerProviderStateMixin {
  bool _collapsed = false;
  late final AnimationController _chevronController;
  late final Animation<double> _chevronAngle;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _chevronAngle = Tween<double>(begin: 0, end: 0.25).animate(
        CurvedAnimation(
            parent: _chevronController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _collapsed = !_collapsed);
    if (_collapsed) {
      _chevronController.forward();
    } else {
      _chevronController.reverse();
    }
  }

  Color get _dotColor {
    return switch (widget.section.group) {
      TaskGroup.urgent => AppColors.red,
      TaskGroup.todo => AppColors.primary,
      TaskGroup.done => AppColors.green,
    };
  }

  String get _title {
    return switch (widget.section.group) {
      TaskGroup.urgent => 'URGENT',
      TaskGroup.todo => 'TO DO',
      TaskGroup.done => 'DONE TODAY',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _title,
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '${widget.section.tasks.length}',
                    style: AppTypography.label.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                RotationTransition(
                  turns: _chevronAngle,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _collapsed
                ? const SizedBox.shrink()
                : Column(
                    children: widget.section.tasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: HomeSpacing.itemGap),
                        child: _TaskCard(
                          task: task,
                          group: widget.section.group,
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────

class _TaskCard extends ConsumerStatefulWidget {
  const _TaskCard({required this.task, required this.group});
  final Task task;
  final TaskGroup group;

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard>
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
          tween: Tween<double>(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _checkController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.completed != widget.task.completed) {
      _completed = widget.task.completed;
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _toggleCheck() {
    final newVal = !_completed;
    setState(() => _completed = newVal);
    _checkController.forward(from: 0);
    ref
        .read(taskActionsProvider.notifier)
        .toggleComplete(widget.task.id, newVal);
  }

  Color get _borderColor {
    if (_completed) return AppColors.green;
    return switch (widget.group) {
      TaskGroup.urgent => AppColors.red,
      TaskGroup.todo => AppColors.primary,
      TaskGroup.done => AppColors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final membersMap = ref.watch(householdMembersMapProvider);
    final assignee = widget.task.assignedTo != null
        ? membersMap[widget.task.assignedTo]
        : null;

    return AnimatedOpacity(
      opacity: _completed ? 0.65 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(HomeRadius.card),
            boxShadow: _completed ? null : const [HomeShadow.card],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Priority left border
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _borderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(HomeRadius.card),
                      bottomLeft: Radius.circular(HomeRadius.card),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + priority tag
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AnimatedDefaultTextStyle(
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PriorityTag(
                                group: widget.group, completed: _completed),
                          ],
                        ),
                        // Due badge
                        if (widget.task.dueDate != null) ...[
                          const SizedBox(height: 6),
                          _DueBadge(dueDate: widget.task.dueDate!),
                        ],
                        // Bottom row: assignee + check
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (assignee != null) ...[
                              MemberAvatar(
                                memberId: assignee.id,
                                initials: _initials(assignee.displayName),
                                size: 26,
                                borderRadius: 8,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                assignee.displayName.split(' ').first,
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const Spacer(),
                            GestureDetector(
                              onTap: _toggleCheck,
                              child: AnimatedBuilder(
                                animation: _checkScale,
                                builder: (_, __) => Transform.scale(
                                  scale: _checkScale.value,
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: _completed
                                          ? AppColors.green
                                          : AppColors.surface2,
                                      borderRadius: BorderRadius.circular(9),
                                      border: _completed
                                          ? null
                                          : Border.all(
                                              color: _borderColor,
                                              width: 2,
                                            ),
                                    ),
                                    child: _completed
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class _PriorityTag extends StatelessWidget {
  const _PriorityTag({required this.group, required this.completed});
  final TaskGroup group;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return _Tag(
          label: 'Done',
          bgColor: AppColors.greenLight,
          textColor: AppColors.green);
    }
    return switch (group) {
      TaskGroup.urgent => _Tag(
          label: 'Urgent',
          bgColor: AppColors.redLight,
          textColor: AppColors.red),
      TaskGroup.todo => _Tag(
          label: 'To Do',
          bgColor: AppColors.primaryLight,
          textColor: AppColors.primary),
      TaskGroup.done => _Tag(
          label: 'Done',
          bgColor: AppColors.greenLight,
          textColor: AppColors.green),
    };
  }
}

class _Tag extends StatelessWidget {
  const _Tag(
      {required this.label,
      required this.bgColor,
      required this.textColor});
  final String label;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(HomeRadius.tag),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          fontSize: 10,
          color: textColor,
        ),
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.dueDate});
  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    final String label;
    final Color bgColor;
    final Color textColor;

    if (diff < 0) {
      label = 'Overdue';
      bgColor = AppColors.redLight;
      textColor = AppColors.red;
    } else if (diff == 0) {
      label = 'Today!';
      bgColor = AppColors.redLight;
      textColor = AppColors.red;
    } else if (diff <= 2) {
      label = '⚠ Due soon';
      bgColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFFB8860B);
    } else {
      label = DateFormat('MMM d').format(dueDate);
      bgColor = AppColors.surface2;
      textColor = AppColors.textTertiary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calendar_today_outlined,
            size: 11, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 10,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text('✅', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'No tasks here. Enjoy the day!',
            style: AppTypography.body
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
