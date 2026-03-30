import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/extensions/color_extension.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../domain/entities/calendar_event.dart';

class EventListTile extends StatelessWidget {
  const EventListTile({
    super.key,
    required this.event,
    required this.membersMap,
    required this.onTap,
  });

  final CalendarEvent event;
  final Map<String, HouseholdMember> membersMap;
  final VoidCallback onTap;

  Color _color() {
    if (event.color != null) return HexColor.fromHex(event.color!);
    if (event.assignedTo != null) {
      final m = membersMap[event.assignedTo];
      if (m != null) return HexColor.fromHex(m.color);
    }
    return const Color(0xFF2E7D6B);
  }

  String _time() {
    if (event.isAllDay) return 'All day';
    final start = DateFormat('h:mm a').format(event.startTime.toLocal());
    if (event.endTime == null) return start;
    return '$start – ${DateFormat('h:mm a').format(event.endTime!.toLocal())}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color();
    final assignee =
        event.assignedTo != null ? membersMap[event.assignedTo] : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(_time(),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (assignee != null)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: HexColor.fromHex(assignee.color),
                  child: Text(
                    assignee.displayName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
