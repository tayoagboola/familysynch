import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/providers/household_providers.dart';

class InviteConfirmationScreen extends ConsumerStatefulWidget {
  const InviteConfirmationScreen({super.key});

  @override
  ConsumerState<InviteConfirmationScreen> createState() =>
      _InviteConfirmationScreenState();
}

class _InviteConfirmationScreenState
    extends ConsumerState<InviteConfirmationScreen> {
  String? _inviteLink;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateLink();
  }

  Future<void> _generateLink() async {
    setState(() => _isGenerating = true);
    try {
      final householdId = ref.read(currentHouseholdIdProvider);
      if (householdId == null) return;
      final link = await ref
          .read(householdRepositoryProvider)
          .generateInviteLink(householdId);
      if (mounted) setState(() => _inviteLink = link);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _copyLink() async {
    if (_inviteLink == null) return;
    await Clipboard.setData(ClipboardData(text: _inviteLink!));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Link copied!')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invite your family 🎉',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Share this link with family members to add them to your household.',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_isGenerating)
                const Center(child: CircularProgressIndicator())
              else if (_inviteLink != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _inviteLink!,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: _copyLink,
                        tooltip: 'Copy link',
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              if (_inviteLink != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy invite link'),
                  onPressed: _copyLink,
                ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
                onPressed: () => context.go(Routes.calendar),
                child: const Text('Skip for now — go to app'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
