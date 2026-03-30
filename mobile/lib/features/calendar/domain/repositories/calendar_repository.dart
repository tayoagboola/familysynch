import '../entities/calendar_event.dart';

abstract class CalendarRepository {
  Stream<List<CalendarEvent>> watchEvents(String householdId);

  Future<CalendarEvent> createEvent({
    required String householdId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  });

  Future<void> updateEvent({
    required String id,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  });

  Future<void> deleteEvent(String id);
}
