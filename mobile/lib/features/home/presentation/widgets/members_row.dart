import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/member_avatar.dart';

class MembersRow extends ConsumerWidget {
  const MembersRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);

    return SizedBox(
      height: 50,
      child: membersAsync.when(
        data: (members) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: HomeSpacing.screenPadding),
          children: [
            ...members.map((m) => _MemberChip(member: m)),
            const _AddMemberButton(),
          ],
        ),
        loading: () => _LoadingChips(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _MemberChip extends StatefulWidget {
  const _MemberChip({required this.member});
  final HouseholdMember member;

  @override
  State<_MemberChip> createState() => _MemberChipState();
}

class _MemberChipState extends State<_MemberChip> {
  double _scale = 1.0;

  String _initials() {
    final parts = widget.member.displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding:
              const EdgeInsets.fromLTRB(5, 5, 10, 5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [HomeShadow.card],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MemberAvatar(
                memberId: widget.member.id,
                initials: _initials(),
                size: 28,
                borderRadius: 10,
              ),
              const SizedBox(width: 6),
              Text(
                widget.member.displayName.split(' ').first,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              // Online dot (static for now — presence tracking in Screen 5)
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
          // Dashed border requires a custom painter — using solid for now
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            'Add',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: HomeSpacing.screenPadding),
      children: List.generate(
        3,
        (_) => Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
