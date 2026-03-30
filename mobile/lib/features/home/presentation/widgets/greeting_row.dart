import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../../../shared/providers/household_providers.dart';

class GreetingRow extends ConsumerWidget {
  const GreetingRow({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(currentHouseholdMemberProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          HomeSpacing.screenPadding, 8, HomeSpacing.screenPadding, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting().toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                memberAsync.when(
                  data: (member) => _GreetingText(member: member),
                  loading: () => _GreetingText(member: null),
                  error: (_, __) => _GreetingText(member: null),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _NotificationButton(),
          const SizedBox(width: 8),
          memberAsync.when(
            data: (member) => _AvatarButton(member: member),
            loading: () => _AvatarButton(member: null),
            error: (_, __) => _AvatarButton(member: null),
          ),
        ],
      ),
    );
  }
}

class _GreetingText extends StatelessWidget {
  const _GreetingText({required this.member});
  final HouseholdMember? member;

  @override
  Widget build(BuildContext context) {
    final firstName = member?.displayName.split(' ').first ?? 'there';
    return RichText(
      text: TextSpan(
        style: AppTypography.display.copyWith(color: AppColors.textPrimary),
        children: [
          const TextSpan(text: 'Hey, '),
          TextSpan(
            text: firstName,
            style: AppTypography.display.copyWith(color: AppColors.primary),
          ),
          const TextSpan(text: ' 👋'),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [HomeShadow.card],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.member});
  final HouseholdMember? member;

  String _initials() {
    if (member == null) return '?';
    final parts = member!.displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFFFF9A6C)],
        ),
      ),
      child: Center(
        child: Text(
          _initials(),
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
