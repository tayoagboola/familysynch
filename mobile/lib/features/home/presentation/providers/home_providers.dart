import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/calendar/domain/entities/calendar_event.dart';
import '../../../../features/grocery/domain/entities/grocery_item.dart';
import '../../../../features/tasks/domain/entities/task.dart';
import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';

// ── Grocery Summary ───────────────────────────────────────────────────────────

class GrocerySummary {
  const GrocerySummary({required this.total, required this.items});
  final int total;
  final List<GroceryItem> items;
}

final grocerySummaryProvider = FutureProvider<GrocerySummary>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const GrocerySummary(total: 0, items: []);

  final supabase = ref.read(supabaseClientProvider);
  final data = await supabase
      .from('grocery_items')
      .select()
      .eq('household_id', householdId)
      .eq('is_checked', false)
      .order('created_at');

  final all = data
      .map((r) => GroceryItem(
            id: r['id'] as String,
            householdId: r['household_id'] as String,
            name: r['name'] as String,
            quantity: r['quantity'] as String?,
            category: r['category'] as String?,
            checked: (r['is_checked'] as bool?) ?? false,
            addedBy: r['added_by'] as String? ?? '',
            checkedBy: r['checked_by'] as String?,
            createdAt: DateTime.parse(r['created_at'] as String),
          ))
      .toList();

  return GrocerySummary(total: all.length, items: all.take(4).toList());
});

// ── Today's Tasks ─────────────────────────────────────────────────────────────

final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return [];

  final today = DateTime.now().toIso8601String().split('T')[0];
  final supabase = ref.read(supabaseClientProvider);

  final data = await supabase
      .from('tasks')
      .select()
      .eq('household_id', householdId)
      .eq('due_date', today)
      .order('is_completed')
      .order('created_at');

  return data
      .map((r) => Task(
            id: r['id'] as String,
            householdId: r['household_id'] as String,
            title: r['title'] as String,
            description: r['description'] as String?,
            dueDate: r['due_date'] != null
                ? DateTime.parse(r['due_date'] as String)
                : null,
            assignedTo: r['assigned_to'] as String?,
            points: (r['points'] as int?) ?? 0,
            completed: (r['is_completed'] as bool?) ?? false,
            completedAt: r['completed_at'] != null
                ? DateTime.parse(r['completed_at'] as String)
                : null,
            completedBy: r['completed_by'] as String?,
            createdBy: r['created_by'] as String? ?? '',
            createdAt: DateTime.parse(r['created_at'] as String),
          ))
      .toList();
});

// ── Today's Events ────────────────────────────────────────────────────────────

final todayEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return [];

  final today = DateTime.now();
  final todayStr = today.toIso8601String().split('T')[0];
  final tomorrowStr =
      today.add(const Duration(days: 1)).toIso8601String().split('T')[0];

  final supabase = ref.read(supabaseClientProvider);
  final data = await supabase
      .from('events')
      .select()
      .eq('household_id', householdId)
      .gte('start_time', todayStr)
      .lt('start_time', tomorrowStr)
      .order('start_time');

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

// ── Family Streak ─────────────────────────────────────────────────────────────

final familyStreakProvider = FutureProvider<int>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return 0;

  final supabase = ref.read(supabaseClientProvider);
  final data = await supabase
      .from('households')
      .select('streak_days')
      .eq('id', householdId)
      .maybeSingle();

  return (data?['streak_days'] as int?) ?? 0;
});

// ── Recent Feed Posts ─────────────────────────────────────────────────────────

final recentFeedPostsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return [];

  final supabase = ref.read(supabaseClientProvider);
  final data = await supabase
      .from('feed_posts')
      .select()
      .eq('household_id', householdId)
      .order('created_at', ascending: false)
      .limit(3);

  return List<Map<String, dynamic>>.from(data);
});
