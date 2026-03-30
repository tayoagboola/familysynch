import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../domain/entities/grocery_item.dart';
import '../controllers/grocery_providers.dart';
import '../providers/grocery_extra_providers.dart';

class GroceryItemCard extends ConsumerStatefulWidget {
  const GroceryItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final GroceryItem item;
  final VoidCallback onDelete;

  @override
  ConsumerState<GroceryItemCard> createState() => _GroceryItemCardState();
}

class _GroceryItemCardState extends ConsumerState<GroceryItemCard>
    with SingleTickerProviderStateMixin {
  late bool _checked;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;

  @override
  void initState() {
    super.initState();
    _checked = widget.item.checked;
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bounceScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.25, end: 0.9), weight: 30),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(GroceryItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.checked != widget.item.checked) {
      _checked = widget.item.checked;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _toggle() {
    final newChecked = !_checked;
    setState(() => _checked = newChecked);
    _bounceController.forward(from: 0);
    ref
        .read(groceryActionsProvider.notifier)
        .toggleCheck(widget.item.id, newChecked);
  }

  @override
  Widget build(BuildContext context) {
    final cat = GroceryCategory.fromString(widget.item.category);
    final membersMap = ref.watch(householdMembersMapProvider);
    final addedByMember = membersMap[widget.item.addedBy];

    return Dismissible(
      key: ValueKey(widget.item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: HomeSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.redLight,
          borderRadius: BorderRadius.circular(HomeRadius.card),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.red, size: 22),
      ),
      confirmDismiss: (_) async {
        widget.onDelete();
        return false; // We handle deletion ourselves
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(HomeSpacing.screenPadding, 0,
            HomeSpacing.screenPadding, HomeSpacing.itemGap),
        decoration: BoxDecoration(
          color: _checked ? AppColors.surface2 : AppColors.surface,
          borderRadius: BorderRadius.circular(HomeRadius.card),
          boxShadow: _checked ? null : const [HomeShadow.card],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 14),
            // Animated checkbox
            GestureDetector(
              onTap: _toggle,
              child: AnimatedBuilder(
                animation: _bounceScale,
                builder: (_, __) => Transform.scale(
                  scale: _bounceScale.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _checked ? AppColors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: _checked
                            ? AppColors.green
                            : AppColors.textTertiary,
                        width: 2.5,
                      ),
                    ),
                    child: _checked
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Category emoji + name + quantity
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Text(cat.emoji,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppTypography.h3.copyWith(
                              fontSize: 15,
                              color: _checked
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                              decoration: _checked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            child: Text(
                              widget.item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.item.quantity != null &&
                              widget.item.quantity!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.item.quantity!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Added-by avatar
            if (addedByMember != null) ...[
              MemberAvatar(
                memberId: addedByMember.id,
                initials: _initials(addedByMember.displayName),
                size: 28,
                borderRadius: 9,
              ),
              const SizedBox(width: 10),
            ],
            // Delete button
            GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: AppColors.textSecondary),
              ),
            ),
          ],
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
