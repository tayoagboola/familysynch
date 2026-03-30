import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme.dart';
import '../../domain/entities/grocery_item.dart';
import '../controllers/grocery_providers.dart';

class GroceryItemTile extends ConsumerWidget {
  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final GroceryItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete_outline,
            color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: GestureDetector(
          onTap: () => ref
              .read(groceryActionsProvider.notifier)
              .toggleCheck(item.id, !item.checked),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.checked
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              border: Border.all(
                color: item.checked
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: item.checked
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          item.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration:
                item.checked ? TextDecoration.lineThrough : null,
            color: item.checked
                ? theme.colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: item.quantity != null
            ? Text(
                item.quantity!,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: IconButton(
          icon: Icon(Icons.close,
              size: 18, color: theme.colorScheme.onSurfaceVariant),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
