import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/home_providers.dart';

class TodayBanner extends ConsumerStatefulWidget {
  const TodayBanner({super.key});

  @override
  ConsumerState<TodayBanner> createState() => _TodayBannerState();
}

class _TodayBannerState extends ConsumerState<TodayBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _circleController;
  late final Animation<double> _circleAnim;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _circleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(todayEventsProvider);
    final tasksAsync = ref.watch(todayTasksProvider);
    final groceryAsync = ref.watch(grocerySummaryProvider);
    final streakAsync = ref.watch(familyStreakProvider);

    final eventCount = eventsAsync.valueOrNull?.length ?? 0;
    final taskCount =
        tasksAsync.valueOrNull?.where((t) => !t.completed).length ?? 0;
    final groceryCount = groceryAsync.valueOrNull?.total ?? 0;
    final streak = streakAsync.valueOrNull ?? 0;

    final dateLabel =
        DateFormat('EEEE, MMMM d').format(DateTime.now());

    return AnimatedBuilder(
      animation: _circleAnim,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(
              HomeSpacing.screenPadding, 0, HomeSpacing.screenPadding,
              HomeSpacing.sectionGap),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeRadius.card),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.aiNavy, AppColors.aiNavy2],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x401A1A2E),
                blurRadius: 32,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Decorative circle — orange
              Positioned(
                top: -30,
                right: 60,
                child: Transform.scale(
                  scale: _circleAnim.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(25),
                    ),
                  ),
                ),
              ),
              // Decorative circle — teal
              Positioned(
                bottom: -20,
                right: -10,
                child: Transform.scale(
                  scale: 2.0 - _circleAnim.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withAlpha(20),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(HomeSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TODAY'S OVERVIEW",
                              style: AppTypography.caption.copyWith(
                                color: Colors.white.withAlpha(128),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$dateLabel 🌤️',
                              style: AppTypography.h2.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        if (streak > 0) _StreakBadge(days: streak),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.calendar_today_rounded,
                          iconColor: AppColors.accent,
                          value: '$eventCount',
                          label: 'Events',
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: AppColors.green,
                          value: '$taskCount',
                          label: 'Tasks',
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          icon: Icons.shopping_cart_outlined,
                          iconColor: AppColors.yellow,
                          value: '$groceryCount',
                          label: 'Items',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.yellow, width: 1.5),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.yellow.withAlpha(30),
      ),
      child: Text(
        '🔥 $days day streak',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.yellow,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(HomeRadius.item),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withAlpha(160),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
