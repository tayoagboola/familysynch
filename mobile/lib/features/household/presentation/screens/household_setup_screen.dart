import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/providers/household_providers.dart';

const List<String> _avatarEmojis = [
  '🏠', '🏡', '🌻', '🌈', '⭐', '🦁', '🐻', '🦊', '🐼', '🦋',
  '🌊', '🏔️', '🌙', '☀️', '🍀', '🎯', '🚀', '🎸',
];

class HouseholdSetupScreen extends ConsumerStatefulWidget {
  const HouseholdSetupScreen({super.key});

  @override
  ConsumerState<HouseholdSetupScreen> createState() =>
      _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState
    extends ConsumerState<HouseholdSetupScreen> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '🏠';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(householdRepositoryProvider).createHousehold(
            name: name,
            avatarEmoji: _selectedEmoji,
          );
      if (!mounted) return;
      // Invalidate so household providers reload
      ref.invalidate(currentHouseholdMemberProvider);
      context.go(Routes.inviteSent);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create household: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Create your household')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What do you call your household?',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'e.g. The Smiths, Casa Garcia',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Choose an icon', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _avatarEmojis.map((e) {
                final selected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                        child:
                            Text(e, style: const TextStyle(fontSize: 24))),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (canSave && !_isLoading) ? _create : null,
              child: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create household'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
