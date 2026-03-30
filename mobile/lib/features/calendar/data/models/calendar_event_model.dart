import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/calendar_event.dart';

part 'calendar_event_model.freezed.dart';
part 'calendar_event_model.g.dart';

@freezed
class CalendarEventModel with _$CalendarEventModel {
  const factory CalendarEventModel({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    required String title,
    String? description,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') DateTime? endTime,
    @JsonKey(name: 'is_all_day') required bool isAllDay,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    String? color,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CalendarEventModel;

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);
}

extension CalendarEventModelX on CalendarEventModel {
  CalendarEvent toDomain() => CalendarEvent(
        id: id,
        householdId: householdId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        isAllDay: isAllDay,
        assignedTo: assignedTo,
        color: color,
        createdBy: createdBy,
        createdAt: createdAt,
      );
}
