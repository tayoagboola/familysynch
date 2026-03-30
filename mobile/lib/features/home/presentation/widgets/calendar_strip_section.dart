import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/routes.dart';
import '../../../../features/calendar/domain/entities/calendar_event.dart';
import '../../../../features/calendar/presentation/controllers/calendar_providers.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../../../shared/widgets/section_header.dart';

class CalendarStripSection extends ConsumerWidget {
  const CalendarStripSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final eventsForDay = ref.watch(eventsForSelectedDayProvider);

    // Build 7-day strip centred on today
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final base = today.subtract(Duration(days: today.weekday - 1));
      return base.add(Duration(days: i));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'This Week',
          linkText: 'Full calendar →',
          onLinkTap: () => context.go(Routes.calendar),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: HomeSpacing.screenPadding),
          child: Row(
            children: days
                .map((d) => _DayChip(day: d, selectedDay: selectedDay))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (eventsForDay.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HomeSpacing.screenPadding),
            child: Text(
              'No events today',
              style: AppTypography.body
                  .copyWith(color: AppColors.textTertiary),
            ),
          )
        else
          ...eventsForDay
              .take(3)
              .map((e) => _EventItem(event: e)),
      ],
    );
  }
}

class _DayChip extends ConsumerWidget {
  const _DayChip({required this.day, required this.selectedDay});
  final DateTime day;
  final DateTime selectedDay;

  bool get isSelected =>
      day.year == selectedDay.year &&
      day.month == selectedDay.month &&
      day.day == selectedDay.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsMap = ref.watch(calendarEventsMapProvider);
    final dayKey = DateTime.utc(day.year, day.month, day.day);
    final hasEvents = eventsMap[dayKey]?.isNotEmpty ?? false;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(selectedDayProvider.notifier).select(day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(HomeRadius.item),
            boxShadow: isSelected ? const [HomeShadow.card] : null,
          ),
          child: Column(
            children: [
              Text(
                DateFormat('E').format(day).toUpperCase().substring(0, 2),
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? Colors.white70
                      : AppColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${day.day}',
                style: AppTypography.h3.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: hasEvents
                      ? (isSelected
                          ? Colors.white
                          : AppColors.accent)
                      : Colors.transparent,
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

class _EventItem extends ConsumerWidget {
  const _EventItem({required this.event});
  final CalendarEvent event;

  Color _eventColor() {
    switch (event.color) {
      case 'teal':
        return AppColors.accent;
      case 'yellow':
        return AppColors.yellow;
      case 'purple':
        return AppColors.purple;
      case 'green':
        return AppColors.green;
      case 'blue':
        return AppColors.blue;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersMap = ref.watch(householdMembersMapProvider);
    final assignee = event.assignedTo != null
        ? membersMap[event.assignedTo]
        : null;

    final timeLabel = DateFormat('h:mm').format(event.startTime);
    final amPm = DateFormat('a').format(event.startTime);
    final color = _eventColor();

    return Padding(
      padding: const EdgeInsets.fromLTRB(HomeSpacing.screenPadding, 0,
          HomeSpacing.screenPadding, HomeSpacing.itemGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time column
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeLabel,
                    style: AppTypography.h3.copyWith(
                        fontSize: 13, color: AppColors.textPrimary)),
                Text(amPm,
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Colored bar
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: color,
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
                      fontSize: 14, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.endTime != null)
                  Text(
                    '${DateFormat('h:mm a').format(event.startTime)} – ${DateFormat('h:mm a').format(event.endTime!)}',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary),
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
