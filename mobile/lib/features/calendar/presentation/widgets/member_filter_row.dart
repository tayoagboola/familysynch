import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../providers/calendar_extra_providers.dart';

class MemberFilterRow extends ConsumerWidget {
  const MemberFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(householdMembersProvider).valueOrNull ?? [];
    final activeFilter = ref.watch(calendarMemberFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.screenPadding, vertical: 4),
        children: [
          _AllChip(isActive: activeFilter == null),
          ...members.map(
            (m) => _MemberFilterChip(
              member: m,
              isActive: activeFilter == m.id,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllChip extends ConsumerWidget {
  const _AllChip({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(calendarMemberFilterProvider.notifier).state = null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
          boxShadow: isActive
              ? const [HomeShadow.card]
              : null,
        ),
        child: Text(
          'All',
          style: AppTypography.label.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MemberFilterChip extends ConsumerWidget {
  const _MemberFilterChip(
      {required this.member, required this.isActive});
  final HouseholdMember member;
  final bool isActive;

  String _initials() {
    final parts = member.displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(calendarMemberFilterProvider.notifier).state =
          isActive ? null : member.id,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MemberAvatar(
              memberId: member.id,
              initials: _initials(),
              size: 24,
              borderRadius: 8,
            ),
            const SizedBox(width: 6),
            Text(
              member.displayName.split(' ').first,
              style: AppTypography.label.copyWith(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
