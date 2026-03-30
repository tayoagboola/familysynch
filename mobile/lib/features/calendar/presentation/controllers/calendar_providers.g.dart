// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarRemoteDatasourceHash() =>
    r'4819a52ee8d8dfeb1124ff5947abedcd18bd6970';

/// See also [calendarRemoteDatasource].
@ProviderFor(calendarRemoteDatasource)
final calendarRemoteDatasourceProvider =
    AutoDisposeProvider<CalendarRemoteDatasource>.internal(
  calendarRemoteDatasource,
  name: r'calendarRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarRemoteDatasourceRef
    = AutoDisposeProviderRef<CalendarRemoteDatasource>;
String _$calendarRepositoryHash() =>
    r'70e6d004001828decc01b81ebe8ee16e8a69964b';

/// See also [calendarRepository].
@ProviderFor(calendarRepository)
final calendarRepositoryProvider =
    AutoDisposeProvider<CalendarRepository>.internal(
  calendarRepository,
  name: r'calendarRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarRepositoryRef = AutoDisposeProviderRef<CalendarRepository>;
String _$calendarEventsHash() => r'483061ea56776fd50beb6e922c4be0bfe56d313f';

/// See also [calendarEvents].
@ProviderFor(calendarEvents)
final calendarEventsProvider =
    AutoDisposeStreamProvider<List<CalendarEvent>>.internal(
  calendarEvents,
  name: r'calendarEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarEventsRef = AutoDisposeStreamProviderRef<List<CalendarEvent>>;
String _$calendarEventsMapHash() => r'57dbd9c1709c7b4cb06a1fbe1a8381e51486944b';

/// See also [calendarEventsMap].
@ProviderFor(calendarEventsMap)
final calendarEventsMapProvider =
    AutoDisposeProvider<Map<DateTime, List<CalendarEvent>>>.internal(
  calendarEventsMap,
  name: r'calendarEventsMapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarEventsMapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarEventsMapRef
    = AutoDisposeProviderRef<Map<DateTime, List<CalendarEvent>>>;
String _$eventsForSelectedDayHash() =>
    r'20e8a67832c7c57088cac8e852e4046b3f14b57c';

/// See also [eventsForSelectedDay].
@ProviderFor(eventsForSelectedDay)
final eventsForSelectedDayProvider =
    AutoDisposeProvider<List<CalendarEvent>>.internal(
  eventsForSelectedDay,
  name: r'eventsForSelectedDayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventsForSelectedDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventsForSelectedDayRef = AutoDisposeProviderRef<List<CalendarEvent>>;
String _$selectedDayHash() => r'a08efadb8b178a21cf81be7bc117c96976601bf8';

/// See also [SelectedDay].
@ProviderFor(SelectedDay)
final selectedDayProvider =
    AutoDisposeNotifierProvider<SelectedDay, DateTime>.internal(
  SelectedDay.new,
  name: r'selectedDayProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDay = AutoDisposeNotifier<DateTime>;
String _$calendarActionsHash() => r'ec82dcd3ace154270ff179b204d7107b31f759e5';

/// See also [CalendarActions].
@ProviderFor(CalendarActions)
final calendarActionsProvider =
    AutoDisposeNotifierProvider<CalendarActions, AsyncValue<void>>.internal(
  CalendarActions.new,
  name: r'calendarActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
