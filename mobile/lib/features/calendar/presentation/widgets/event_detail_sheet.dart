import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/extensions/color_extension.dart';
import '../../../../features/household/domain/entities/household_member.dart';
import '../../domain/entities/calendar_event.dart';
import '../controllers/calendar_providers.dart';

class EventDetailSheet extends ConsumerWidget {
  const EventDetailSheet({
    super.key,
    required this.event,
    required this.membersMap,
  });

  final CalendarEvent event;
  final Map<String, HouseholdMember> membersMap;

  Color _resolveColor() {
    if (event.color != null) return HexColor.fromHex(event.color!);
    if (event.assignedTo != null) {
      final m = membersMap[event.assignedTo];
      if (m != null) return HexColor.fromHex(m.color);
    }
    return const Color(0xFF2E7D6B);
  }

  String _formatDateRange() {
    if (event.isAllDay) {
      return DateFormat('EEEE, MMMM d, y').format(event.startTime.toLocal());
    }
    final date =
        DateFormat('EEEE, MMMM d, y').format(event.startTime.toLocal());
    final start = DateFormat('h:mm a').format(event.startTime.toLocal());
    if (event.endTime == null) return '$date at $start';
    final end = DateFormat('h:mm a').format(event.endTime!.toLocal());
    return '$date\n$start – $end';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text(
            '"${event.title}" will be removed for all household members.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await ref
        .read(calendarActionsProvider.notifier)
        .deleteEvent(event.id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _resolveColor();
    final assignee =
        event.assignedTo != null ? membersMap[event.assignedTo] : null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: Text(event.title,
                        style: theme.textTheme.titleLarge)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _Row(
                    icon: Icons.schedule_outlined,
                    label: 'When',
                    value: _formatDateRange()),
                const SizedBox(height: AppSpacing.md),
                _Row(
                  icon: Icons.person_outline,
                  label: 'Assigned to',
                  value: assignee?.displayName ?? 'Everyone',
                  trailing: assignee != null
                      ? CircleAvatar(
                          radius: 16,
                          backgroundColor: HexColor.fromHex(assignee.color),
                          child: Text(assignee.displayName[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)))
                      : null,
                ),
                if (event.description?.isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Row(
                      icon: Icons.notes_outlined,
                      label: 'Notes',
                      value: event.description!),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(Routes.eventEdit, extra: event);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                      label: Text('Delete',
                          style:
                              TextStyle(color: theme.colorScheme.error)),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color:
                                  theme.colorScheme.error.withOpacity(0.5))),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.icon,
      required this.label,
      required this.value,
      this.trailing});
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
