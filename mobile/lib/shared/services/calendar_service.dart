/// CalendarService — event CRUD. No WebSocket — Flutter refetches after mutations.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService(ref.read(apiClientProvider));
});

class CalendarService {
  final ApiClient _api;
  CalendarService(this._api);

  Future<Map<String, dynamic>> getEvents({
    String? dateFrom,
    String? dateTo,
    String? memberId,
  }) =>
      _api.get('/calendar', queryParameters: {
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (memberId != null) 'member_id': memberId,
      });

  Future<Map<String, dynamic>> getDayEvents(String date) =>
      _api.get('/calendar/day', queryParameters: {'date': date});

  Future<Map<String, dynamic>> getEvent(String eventId) =>
      _api.get('/calendar/$eventId');

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> body) =>
      _api.post('/calendar', body: body);

  Future<Map<String, dynamic>> updateEvent(
          String eventId, Map<String, dynamic> body) =>
      _api.put('/calendar/$eventId', body: body);

  Future<void> deleteEvent(String eventId) =>
      _api.delete('/calendar/$eventId');

  Future<Map<String, dynamic>> addEventMembers(
          String eventId, List<String> memberIds) =>
      _api.post('/calendar/$eventId/members',
          body: {'member_ids': memberIds});

  Future<Map<String, dynamic>> removeEventMember(
          String eventId, String memberId) =>
      _api.delete('/calendar/$eventId/members/$memberId');
}
