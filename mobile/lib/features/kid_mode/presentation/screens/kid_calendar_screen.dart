import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../app/theme.dart';
import '../../../../../core/extensions/color_extension.dart';
import '../../../../../shared/providers/household_providers.dart';
import '../../../../../shared/providers/supabase_provider.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../calendar/presentation/controllers/calendar_providers.dart';

class KidCalendarScreen extends ConsumerStatefulWidget {
  const KidCalendarScreen({super.key});

  @override
  ConsumerState<KidCalendarScreen> createState() =>
      _KidCalendarScreenState();
}

class _KidCalendarScreenState
    extends ConsumerState<KidCalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  void _onDaySelected(DateTime selected, DateTime focused) {
    ref.read(selectedDayProvider.notifier).select(selected);
    setState(() => _focusedDay = focused);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId =
        ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';
    final eventsAsync = ref.watch(calendarEventsProvider);
    final eventsMap = ref.watch(calendarEventsMapProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final membersMap = ref.watch(householdMembersMapProvider);

    // Only show events assigned to this child
    final selectedEvents = ref
        .watch(eventsForSelectedDayProvider)
        .where((e) => e.assignedTo == currentUserId || e.assignedTo == null)
        .toList()
      ..sort((a, b) {
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;
        return a.startTime.compareTo(b.startTime);
      });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: Text(
              DateFormat('MMMM y').format(_focusedDay),
              style: theme.textTheme.titleLarge,
            ),
            floating: true,
            snap: true,
            surfaceTintColor: theme.colorScheme.surface,
          ),
          SliverToBoxAdapter(
            child: eventsAsync.when(
              loading: () => const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (_) => TableCalendar<CalendarEvent>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(selectedDay, d),
                onDaySelected: _onDaySelected,
                onPageChanged: (d) => setState(() => _focusedDay = d),
                eventLoader: (day) {
                  final key = DateTime.utc(day.year, day.month, day.day);
                  final all = eventsMap[key] ?? [];
                  return all
                      .where((e) =>
                          e.assignedTo == currentUserId ||
                          e.assignedTo == null)
                      .toList();
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (ctx, date, events) {
                    if (events.isEmpty) return null;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((obj) {
                        final e = obj;
                        final member = e.assignedTo != null
                            ? membersMap[e.assignedTo]
                            : null;
                        final c = e.color != null
                            ? HexColor.fromHex(e.color!)
                            : member != null
                                ? HexColor.fromHex(member.color)
                                : theme.colorScheme.primary;
                        return Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 1),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              color: c, shape: BoxShape.circle),
                        );
                      }).toList(),
                    );
                  },
                ),
                headerVisible: false,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                  weekendStyle: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  rowDecoration: const BoxDecoration(),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  defaultTextStyle:
                      const TextStyle(fontSize: 16),
                  weekendTextStyle:
                      const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          // Day header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text(
                isSameDay(selectedDay, DateTime.now())
                    ? 'Today'
                    : DateFormat('EEEE, MMMM d').format(selectedDay),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // Events for selected day
          eventsAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (_) {
              if (selectedEvents.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_available_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4)),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Nothing scheduled',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme
                                      .colorScheme.onSurfaceVariant)),
                        ]),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _KidEventTile(event: selectedEvents[i]),
                  childCount: selectedEvents.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl + 56)),
        ],
      ),
    );
  }
}

class _KidEventTile extends StatelessWidget {
  const _KidEventTile({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = event.color != null
        ? HexColor.fromHex(event.color!)
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(children: [
            Container(
              width: 6,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  if (!event.isAllDay)
                    Text(
                      '${DateFormat('h:mm a').format(event.startTime.toLocal())}'
                      '${event.endTime != null ? ' – ${DateFormat('h:mm a').format(event.endTime!.toLocal())}' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    )
                  else
                    Text('All day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
