import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme.dart';
import '../controllers/grocery_providers.dart';

const _kCategories = [
  'Produce',
  'Dairy',
  'Meat & Fish',
  'Bakery',
  'Frozen',
  'Pantry',
  'Drinks',
  'Snacks',
  'Household',
  'Other',
];

class AddItemSheet extends ConsumerStatefulWidget {
  const AddItemSheet({super.key});

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(groceryActionsProvider.notifier).addItem(
          name: _nameCtrl.text.trim(),
          quantity: _qtyCtrl.text.trim().isEmpty ? null : _qtyCtrl.text.trim(),
          category: _category,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add item.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(groceryActionsProvider).isLoading;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('Add item', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),

            // Name
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Name is required'
                  : null,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Quantity
            TextFormField(
              controller: _qtyCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Quantity (optional)',
                hintText: 'e.g. 2 litres, 500g',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              hint: const Text('Category (optional)'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _kCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _save,
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Add to list'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
