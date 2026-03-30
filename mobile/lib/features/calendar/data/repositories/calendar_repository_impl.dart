import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/remote/calendar_remote_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._remote);

  final CalendarRemoteDatasource _remote;

  @override
  Stream<List<CalendarEvent>> watchEvents(String householdId) {
    return _remote
        .watchEvents(householdId)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Future<CalendarEvent> createEvent({
    required String householdId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  }) async {
    final model = await _remote.createEvent(
      householdId: householdId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      assignedTo: assignedTo,
      color: color,
    );
    return model.toDomain();
  }

  @override
  Future<void> updateEvent({
    required String id,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required bool isAllDay,
    String? assignedTo,
    String? color,
  }) =>
      _remote.updateEvent(
        id: id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        isAllDay: isAllDay,
        assignedTo: assignedTo,
        color: color,
      );

  @override
  Future<void> deleteEvent(String id) => _remote.deleteEvent(id);
}
