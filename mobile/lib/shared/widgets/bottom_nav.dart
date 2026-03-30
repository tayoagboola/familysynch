import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
    this.taskBadgeCount = 0,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;
  final int taskBadgeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            activeIndex: activeIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
            index: 1,
            activeIndex: activeIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.check_box_rounded,
            label: 'Tasks',
            index: 2,
            activeIndex: activeIndex,
            onTap: onTap,
            badgeCount: taskBadgeCount,
          ),
          _NavItem(
            icon: Icons.shopping_cart_rounded,
            label: 'Grocery',
            index: 3,
            activeIndex: activeIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.forum_rounded,
            label: 'Feed',
            index: 4,
            activeIndex: activeIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.activeIndex,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final int index;
  final int activeIndex;
  final ValueChanged<int> onTap;
  final int badgeCount;

  bool get isActive => index == activeIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Icon with optional badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isActive ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    size: 19,
                    color: isActive ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color:
                    isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
