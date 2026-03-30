import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../domain/entities/calendar_event.dart';
import '../controllers/calendar_providers.dart';

// ── Month Navigation ──────────────────────────────────────────────────────────

class CalendarMonthNotifier extends StateNotifier<DateTime> {
  CalendarMonthNotifier() : super(DateTime.now());

  void nextMonth() =>
      state = DateTime(state.year, state.month + 1);

  void previousMonth() =>
      state = DateTime(state.year, state.month - 1);

  void jumpToToday() => state = DateTime.now();
}

final calendarMonthProvider =
    StateNotifierProvider<CalendarMonthNotifier, DateTime>(
  (ref) => CalendarMonthNotifier(),
);

// ── Member Filter ─────────────────────────────────────────────────────────────

// null = show all members
final calendarMemberFilterProvider = StateProvider<String?>((ref) => null);

// ── Month Events (grouped by "yyyy-MM-dd") ────────────────────────────────────

final monthEventsMapProvider =
    Provider<Map<String, List<CalendarEvent>>>((ref) {
  final month = ref.watch(calendarMonthProvider);
  final allEvents = ref.watch(calendarEventsProvider).valueOrNull ?? [];
  final memberId = ref.watch(calendarMemberFilterProvider);

  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 1);

  final inMonth = allEvents.where((e) =>
      !e.startTime.isBefore(monthStart) && e.startTime.isBefore(monthEnd));

  final filtered = memberId == null
      ? inMonth
      : inMonth.where((e) => e.assignedTo == memberId);

  final map = <String, List<CalendarEvent>>{};
  for (final event in filtered) {
    final key =
        '${event.startTime.year}-${event.startTime.month.toString().padLeft(2, '0')}-${event.startTime.day.toString().padLeft(2, '0')}';
    (map[key] ??= []).add(event);
  }
  return map;
});

// ── Selected Day Events (filtered) ───────────────────────────────────────────

final calendarSelectedDayEventsProvider =
    Provider<List<CalendarEvent>>((ref) {
  final selected = ref.watch(selectedDayProvider);
  final map = ref.watch(monthEventsMapProvider);
  final key =
      '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
  final events = map[key] ?? [];
  return [...events]..sort((a, b) => a.startTime.compareTo(b.startTime));
});

// ── Upcoming Events (next 7 days) ─────────────────────────────────────────────

final upcomingEventsProvider =
    FutureProvider<List<CalendarEvent>>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return [];

  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final nextWeek = DateTime(now.year, now.month, now.day + 8);

  final supabase = ref.read(supabaseClientProvider);
  final data = await supabase
      .from('events')
      .select()
      .eq('household_id', householdId)
      .gte('start_time', tomorrow.toIso8601String())
      .lt('start_time', nextWeek.toIso8601String())
      .order('start_time')
      .limit(5);

  return data
      .map((r) => CalendarEvent(
            id: r['id'] as String,
            householdId: r['household_id'] as String,
            title: r['title'] as String,
            description: r['description'] as String?,
            startTime: DateTime.parse(r['start_time'] as String),
            endTime: r['end_time'] != null
                ? DateTime.parse(r['end_time'] as String)
                : null,
            isAllDay: (r['is_all_day'] as bool?) ?? false,
            assignedTo: r['assigned_to'] as String?,
            color: r['color'] as String?,
            createdBy: r['created_by'] as String? ?? '',
            createdAt: DateTime.parse(r['created_at'] as String),
          ))
      .toList();
});
