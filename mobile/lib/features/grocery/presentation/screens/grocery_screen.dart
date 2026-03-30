import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/ai_fab.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../controllers/grocery_providers.dart';
import '../providers/grocery_extra_providers.dart';
import '../widgets/category_tabs.dart';
import '../widgets/grocery_item_card.dart';

class GroceryScreen extends ConsumerWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      floatingActionButton: const AIFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const _GroceryHeader(),
          Expanded(
            child: _GroceryList(),
          ),
          const _AddItemBar(),
        ],
      ),
    );
  }
}

// ── Fixed Header ──────────────────────────────────────────────────────────────

class _GroceryHeader extends ConsumerWidget {
  const _GroceryHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(groceryProgressProvider);
    final hasChecked = progress.checked > 0;

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  HomeSpacing.screenPadding, 12,
                  HomeSpacing.screenPadding, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grocery List',
                          style: AppTypography.h1
                              .copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          progress.total == 0
                              ? 'All done! 🎉'
                              : '${progress.total - progress.checked} item${(progress.total - progress.checked) == 1 ? '' : 's'} remaining',
                          style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (hasChecked)
                    GestureDetector(
                      onTap: () =>
                          _confirmClearChecked(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.delete_sweep_outlined,
                                size: 15, color: AppColors.red),
                            const SizedBox(width: 5),
                            Text(
                              'Clear ${progress.checked}',
                              style: AppTypography.label.copyWith(
                                  color: AppColors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            if (progress.total > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeSpacing.screenPadding),
                child: _ProgressBar(
                  fraction: progress.checked / progress.total,
                  checked: progress.checked,
                  total: progress.total,
                ),
              ),
            const SizedBox(height: 12),
            // Category tabs
            const CategoryTabs(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearChecked(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HomeRadius.card)),
        title: Text('Clear checked items?',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'All checked items will be removed from the list.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTypography.label
                    .copyWith(color: AppColors.textSecondary)),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(ctx, true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(HomeRadius.button),
              ),
              child: Text('Clear',
                  style: AppTypography.label.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(groceryActionsProvider.notifier).clearChecked();
    }
  }
}

// ── Progress Bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.fraction,
    required this.checked,
    required this.total,
  });

  final double fraction;
  final int checked;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.surface2,
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$checked of $total done',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Grocery List ──────────────────────────────────────────────────────────────

class _GroceryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(groceryItemsProvider);
    final grouped = ref.watch(filteredGroupedGroceryProvider);

    return itemsAsync.when(
      loading: () => const LoadingSkeletonList(
          itemCount: 5, itemHeight: 64,
          padding: EdgeInsets.fromLTRB(24, 16, 24, 0)),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text('Could not load grocery list',
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => ref.invalidate(groceryItemsProvider),
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
        if (grouped.isEmpty) {
          return _EmptyState();
        }
        return ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          children: grouped.entries.map((entry) {
            return _CategorySection(
              category: GroceryCategory.fromString(entry.key),
              items: entry.value,
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Category Section ──────────────────────────────────────────────────────────

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    required this.category,
    required this.items,
  });

  final GroceryCategory category;
  final List items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checked = items.where((i) => i.checked).length;
    final total = items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              HomeSpacing.screenPadding, 8,
              HomeSpacing.screenPadding, 8),
          child: Row(
            children: [
              Text(category.emoji,
                  style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 7),
              Text(
                category.label,
                style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  checked > 0 ? '$checked/$total' : '$total',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => GroceryItemCard(
              key: ValueKey(item.id),
              item: item,
              onDelete: () =>
                  ref.read(groceryActionsProvider.notifier).deleteItem(item.id),
            )),
        const SizedBox(height: 8),
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
              child: Text('🛒', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your list is empty',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Add items below and shop together',
            style: AppTypography.body
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Add Item Bar ──────────────────────────────────────────────────────────────

class _AddItemBar extends ConsumerStatefulWidget {
  const _AddItemBar();

  @override
  ConsumerState<_AddItemBar> createState() => _AddItemBarState();
}

class _AddItemBarState extends ConsumerState<_AddItemBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final category = inferGroceryCategory(text);
    _controller.clear();
    _focusNode.unfocus();

    final success = await ref.read(groceryActionsProvider.notifier).addItem(
          name: text,
          category: category == 'other' ? null : category,
        );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item',
              style:
                  AppTypography.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.fromLTRB(
          HomeSpacing.screenPadding,
          12,
          HomeSpacing.screenPadding,
          12 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
            top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141A1A2E),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(HomeRadius.button),
                border: Border.all(
                  color: _isFocused ? AppColors.primary : AppColors.border,
                  width: _isFocused ? 2 : 1.5,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: (_) => _submit(),
                style: AppTypography.body
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '+ Add item…',
                  hintStyle: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Add button
          AnimatedOpacity(
            opacity: _isFocused ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(HomeRadius.button),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
