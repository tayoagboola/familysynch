import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/home_providers.dart';

class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(todayEventsProvider);
    final tasksAsync = ref.watch(todayTasksProvider);
    final groceryAsync = ref.watch(grocerySummaryProvider);

    final eventCount = eventsAsync.valueOrNull?.length ?? 0;
    final taskCount =
        tasksAsync.valueOrNull?.where((t) => !t.completed).length ?? 0;
    final groceryItems = groceryAsync.valueOrNull?.items ?? [];
    final groceryTotal = groceryAsync.valueOrNull?.total ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: HomeSpacing.screenPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _QuickCard(
                      title: 'Calendar',
                      subtitle: 'Today\'s schedule',
                      icon: Icons.calendar_month_rounded,
                      iconBg: AppColors.accentLight,
                      iconColor: AppColors.accent,
                      badge: eventCount,
                      onTap: () => context.go(Routes.calendar),
                    ),
                  ),
                  const SizedBox(width: HomeSpacing.itemGap),
                  Expanded(
                    child: _QuickCard(
                      title: 'Tasks',
                      subtitle: 'Family chores',
                      icon: Icons.check_box_rounded,
                      iconBg: AppColors.purpleLight,
                      iconColor: AppColors.purple,
                      badge: taskCount,
                      onTap: () => context.go(Routes.tasks),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HomeSpacing.itemGap),
              _GroceryCard(
                items: groceryItems,
                total: groceryTotal,
                onTap: () => context.go(Routes.grocery),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.badge = 0,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(HomeSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(HomeRadius.card),
          boxShadow: const [HomeShadow.card],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(height: 12),
                Text(title,
                    style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary)),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(HomeRadius.tag),
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroceryCard extends StatelessWidget {
  const _GroceryCard({
    required this.items,
    required this.total,
    required this.onTap,
  });

  final List items;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final remaining = total - items.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(HomeSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(HomeRadius.card),
          boxShadow: const [HomeShadow.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.yellowLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.shopping_cart_rounded,
                      color: AppColors.yellow, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grocery List',
                        style: AppTypography.h3
                            .copyWith(color: AppColors.textPrimary)),
                    Text(
                      total == 0
                          ? 'All done!'
                          : '$total item${total == 1 ? '' : 's'} remaining',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                if (total > 0)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(HomeRadius.tag),
                    ),
                    child: Center(
                      child: Text(
                        '$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...items.take(4).map((item) => _ItemChip(
                        name: item.name,
                        checked: item.checked,
                      )),
                  if (remaining > 0)
                    _MoreChip(count: remaining),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.name, required this.checked});
  final String name;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: checked ? AppColors.greenLight : AppColors.surface2,
        borderRadius: BorderRadius.circular(HomeRadius.tag),
      ),
      child: Text(
        name,
        style: AppTypography.labelSmall.copyWith(
          color: checked ? AppColors.green : AppColors.textSecondary,
          decoration: checked ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(HomeRadius.tag),
      ),
      child: Text(
        '+$count more',
        style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
      ),
    );
  }
}
