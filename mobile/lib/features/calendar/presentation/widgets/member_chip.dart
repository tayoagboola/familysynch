import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/extensions/color_extension.dart';
import '../../../../features/household/domain/entities/household_member.dart';

class MemberChip extends StatelessWidget {
  const MemberChip({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  final HouseholdMember member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = HexColor.fromHex(member.color);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border:
              isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MemberAvatar(member: member, size: 24),
            const SizedBox(width: AppSpacing.xs),
            Text(
              member.displayName.split(' ').first,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.check, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.member, this.size = 36});

  final HouseholdMember member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = HexColor.fromHex(member.color);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Text(
        member.displayName.isNotEmpty
            ? member.displayName[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
