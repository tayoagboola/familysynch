import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../data/datasources/remote/calendar_remote_datasource.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

part 'calendar_providers.g.dart';

DateTime _toDateKey(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

@riverpod
CalendarRemoteDatasource calendarRemoteDatasource(
    CalendarRemoteDatasourceRef ref) {
  return CalendarRemoteDatasource(ref.watch(supabaseClientProvider));
}

@riverpod
CalendarRepository calendarRepository(CalendarRepositoryRef ref) {
  return CalendarRepositoryImpl(ref.watch(calendarRemoteDatasourceProvider));
}

@riverpod
Stream<List<CalendarEvent>> calendarEvents(CalendarEventsRef ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();
  return ref.watch(calendarRepositoryProvider).watchEvents(householdId);
}

@riverpod
Map<DateTime, List<CalendarEvent>> calendarEventsMap(
    CalendarEventsMapRef ref) {
  final events = ref.watch(calendarEventsProvider).valueOrNull ?? [];
  final map = <DateTime, List<CalendarEvent>>{};
  for (final event in events) {
    final key = _toDateKey(event.startTime);
    (map[key] ??= []).add(event);
  }
  return map;
}

@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  DateTime build() => DateTime.now();
  void select(DateTime day) => state = day;
}

@riverpod
List<CalendarEvent> eventsForSelectedDay(EventsForSelectedDayRef ref) {
  final map = ref.watch(calendarEventsMapProvider);
  final selected = ref.watch(selectedDayProvider);
  return map[_toDateKey(selected)] ?? [];
}

@riverpod
class CalendarActions extends _$CalendarActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  }) async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(calendarRepositoryProvider).createEvent(
              householdId: householdId,
              title: title,
              description: description,
              startTime: startTime,
              endTime: endTime,
              isAllDay: isAllDay,
              assignedTo: assignedTo,
              color: color,
            ));
    return !state.hasError;
  }

  Future<bool> updateEvent({
    required String id,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(calendarRepositoryProvider).updateEvent(
              id: id,
              title: title,
              description: description,
              startTime: startTime,
              endTime: endTime,
              isAllDay: isAllDay,
              assignedTo: assignedTo,
              color: color,
            ));
    return !state.hasError;
  }

  Future<bool> deleteEvent(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(calendarRepositoryProvider).deleteEvent(id));
    return !state.hasError;
  }
}
