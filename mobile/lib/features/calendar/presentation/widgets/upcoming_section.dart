import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../domain/entities/calendar_event.dart';
import '../providers/calendar_extra_providers.dart';
import 'event_color_utils.dart';

class UpcomingSection extends ConsumerWidget {
  const UpcomingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingEventsProvider);
    final membersMap = ref.watch(householdMembersMapProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: HomeSpacing.screenPadding),
          child: Row(
            children: [
              Text(
                'Coming Up',
                style: AppTypography.h2
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This week',
                  style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        upcomingAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: HomeSpacing.screenPadding),
                child: Text(
                  'Nothing coming up this week',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                ),
              );
            }
            return Column(
              children: events
                  .map((e) => _UpcomingCard(event: e, membersMap: membersMap))
                  .toList(),
            );
          },
          loading: () => const LoadingSkeletonList(
              itemCount: 2, itemHeight: 64),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HomeSpacing.screenPadding),
            child: Text(
              'Could not load upcoming events',
              style: AppTypography.body
                  .copyWith(color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.event, required this.membersMap});

  final CalendarEvent event;
  final Map<String, HouseholdMember> membersMap;

  @override
  Widget build(BuildContext context) {
    final accent = eventAccentColor(event.color);
    final assignee = event.assignedTo != null
        ? membersMap[event.assignedTo]
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(HomeSpacing.screenPadding, 0,
          HomeSpacing.screenPadding, HomeSpacing.itemGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date column
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEE').format(event.startTime).toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '${event.startTime.day}',
                  style: AppTypography.h1.copyWith(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Color bar
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.h3.copyWith(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.endTime != null
                      ? '${DateFormat('h:mm a').format(event.startTime)} – ${DateFormat('h:mm a').format(event.endTime!)}'
                      : DateFormat('h:mm a').format(event.startTime),
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (assignee != null)
            MemberAvatar(
              memberId: assignee.id,
              initials: _initials(assignee.displayName),
              size: 28,
              borderRadius: 9,
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}
