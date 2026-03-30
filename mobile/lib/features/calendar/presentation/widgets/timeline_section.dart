import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../domain/entities/calendar_event.dart';
import '../providers/calendar_extra_providers.dart';
import 'event_color_utils.dart';

// 8 AM → 9 PM = hours 8 to 21
const _kStartHour = 8;
const _kEndHour = 21;

class TimelineSection extends ConsumerWidget {
  const TimelineSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarSelectedDayEventsProvider);
    final membersMap = ref.watch(householdMembersMapProvider);
    final dayEvents =
        events.where((e) => !e.isAllDay).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: HomeSpacing.screenPadding),
      child: Column(
        children: List.generate(_kEndHour - _kStartHour + 1, (i) {
          final hour = _kStartHour + i;
          final hourEvents = dayEvents
              .where((e) => e.startTime.hour == hour)
              .toList();
          final isLastBlock = i == _kEndHour - _kStartHour;
          return _TimeBlock(
            hour: hour,
            events: hourEvents,
            membersMap: membersMap,
            isLastBlock: isLastBlock,
          );
        }),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.hour,
    required this.events,
    required this.membersMap,
    required this.isLastBlock,
  });

  final int hour;
  final List<CalendarEvent> events;
  final Map<String, HouseholdMember> membersMap;
  final bool isLastBlock;

  String _hourLabel() {
    if (hour == 12) return '12 PM';
    return hour < 12 ? '$hour AM' : '${hour - 12} PM';
  }

  bool get _isCurrentHour => DateTime.now().hour == hour;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _hourLabel(),
                textAlign: TextAlign.right,
                style: AppTypography.labelSmall.copyWith(
                  color: _isCurrentHour
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Timeline column: dot + line
          SizedBox(
            width: 16,
            child: Column(
              children: [
                _TimelineDot(isCurrentHour: _isCurrentHour, hasEvent: events.isNotEmpty),
                if (!isLastBlock)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: events.isEmpty
                  ? _EmptySlot(hour: hour)
                  : Column(
                      children: events
                          .map((e) => _EventCard(
                                event: e,
                                membersMap: membersMap,
                              ))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatefulWidget {
  const _TimelineDot(
      {required this.isCurrentHour, required this.hasEvent});
  final bool isCurrentHour;
  final bool hasEvent;

  @override
  State<_TimelineDot> createState() => _TimelineDotState();
}

class _TimelineDotState extends State<_TimelineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCurrentHour) {
      return AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryLight, width: 3),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: widget.hasEvent ? AppColors.primary : AppColors.bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.hasEvent ? AppColors.primary : AppColors.border,
          width: 2.5,
        ),
      ),
    );
  }
}

class _EmptySlot extends StatefulWidget {
  const _EmptySlot({required this.hour});
  final int hour;

  @override
  State<_EmptySlot> createState() => _EmptySlotState();
}

class _EmptySlotState extends State<_EmptySlot> {
  bool _tapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _tapped = true),
      onTapUp: (_) => setState(() => _tapped = false),
      onTapCancel: () => setState(() => _tapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _tapped ? AppColors.primary : AppColors.border,
            width: 1.5,
            // Note: Dart doesn't support CSS dashed borders natively;
            // using solid with low opacity for the dashed effect
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Text(
            '+ Add event',
            style: AppTypography.labelSmall.copyWith(
              color: _tapped ? AppColors.primary : AppColors.textTertiary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.membersMap});

  final CalendarEvent event;
  final Map<String, HouseholdMember> membersMap;

  @override
  Widget build(BuildContext context) {
    final accent = eventAccentColor(event.color);
    final lightBg = eventLightBgColor(event.color);
    final assignee = event.assignedTo != null
        ? membersMap[event.assignedTo]
        : null;

    final timeLabel = event.endTime != null
        ? '${DateFormat('h:mm a').format(event.startTime)} – ${DateFormat('h:mm a').format(event.endTime!)}'
        : DateFormat('h:mm a').format(event.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(HomeRadius.item),
        boxShadow: const [HomeShadow.card],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left accent bar
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(HomeRadius.item),
                bottomLeft: Radius.circular(HomeRadius.item),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: AppTypography.h3.copyWith(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          event.description!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (assignee != null) ...[
                    const SizedBox(height: 8),
                    MemberAvatar(
                      memberId: assignee.id,
                      initials: _initials(assignee.displayName),
                      size: 24,
                      borderRadius: 8,
                    ),
                  ],
                ],
              ),
            ),
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
