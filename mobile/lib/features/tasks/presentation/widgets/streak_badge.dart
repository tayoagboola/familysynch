import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme.dart';
import '../controllers/task_providers.dart';

class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakForMemberProvider(userId));
    if (streak == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔥', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          '$streak day${streak == 1 ? '' : 's'}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFFE65100),
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}
