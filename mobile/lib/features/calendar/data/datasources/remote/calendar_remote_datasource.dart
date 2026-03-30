import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/calendar_event_model.dart';

class CalendarRemoteDatasource {
  CalendarRemoteDatasource(this._client);

  final SupabaseClient _client;

  Stream<List<CalendarEventModel>> watchEvents(String householdId) {
    return _client
        .from('calendar_events')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('start_time')
        .map((rows) => rows.map(CalendarEventModel.fromJson).toList());
  }

  Future<CalendarEventModel> createEvent({
    required String householdId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  }) async {
    final data = await _client.from('calendar_events').insert({
      'household_id': householdId,
      'title': title,
      'description': description,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime?.toUtc().toIso8601String(),
      'is_all_day': isAllDay,
      'assigned_to': assignedTo,
      'color': color,
      'created_by': _client.auth.currentUser!.id,
    }).select().single();
    return CalendarEventModel.fromJson(data);
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  }) async {
    await _client.from('calendar_events').update({
      'title': title,
      'description': description,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime?.toUtc().toIso8601String(),
      'is_all_day': isAllDay,
      'assigned_to': assignedTo,
      'color': color,
    }).eq('id', id);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('calendar_events').delete().eq('id', id);
  }
}
