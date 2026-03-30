import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event.freezed.dart';

@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String householdId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    @Default(false) bool isAllDay,
    String? assignedTo,
    String? color,
    required String createdBy,
    required DateTime createdAt,
  }) = _CalendarEvent;
}
