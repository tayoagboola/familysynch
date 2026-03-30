import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../controllers/grocery_providers.dart';
import '../providers/grocery_extra_providers.dart';

class CategoryTabs extends ConsumerWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(groceryCategoriesProvider);
    final selected = ref.watch(selectedGroceryCategoryProvider);
    final allItems = ref.watch(groceryItemsProvider).valueOrNull ?? [];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.screenPadding),
        children: [
          _CategoryChip(
            label: 'All',
            emoji: '🛒',
            isActive: selected == null,
            count: allItems.length,
            onTap: () =>
                ref.read(selectedGroceryCategoryProvider.notifier).state =
                    null,
          ),
          ...categories.map(
            (cat) {
              final catItems = allItems.where((i) =>
                  (i.category?.trim().isNotEmpty == true
                      ? i.category!
                      : 'other') ==
                  cat.key);
              return _CategoryChip(
                label: cat.label,
                emoji: cat.emoji,
                isActive: selected == cat.key,
                count: catItems.length,
                onTap: () =>
                    ref.read(selectedGroceryCategoryProvider.notifier).state =
                        selected == cat.key ? null : cat.key,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.count,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
          boxShadow: isActive ? const [HomeShadow.card] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 12,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withAlpha(60)
                      : AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: isActive
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
