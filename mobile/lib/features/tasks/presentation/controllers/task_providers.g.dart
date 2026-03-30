// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskRemoteDatasourceHash() =>
    r'815a737d20f73ae54d8429f0a2d7afcbf5f731a8';

/// See also [taskRemoteDatasource].
@ProviderFor(taskRemoteDatasource)
final taskRemoteDatasourceProvider =
    AutoDisposeProvider<TaskRemoteDatasource>.internal(
  taskRemoteDatasource,
  name: r'taskRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRemoteDatasourceRef = AutoDisposeProviderRef<TaskRemoteDatasource>;
String _$taskRepositoryHash() => r'e63fca5c286ec3838881be358b72f66817c8dd51';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = AutoDisposeProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRepositoryRef = AutoDisposeProviderRef<TaskRepository>;
String _$tasksHash() => r'b41efffab4c8af9d8f97ebce95dcbe7c4845ae77';

/// See also [tasks].
@ProviderFor(tasks)
final tasksProvider = AutoDisposeStreamProvider<List<Task>>.internal(
  tasks,
  name: r'tasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksRef = AutoDisposeStreamProviderRef<List<Task>>;
String _$tasksGroupedHash() => r'e214cb4ce8041d2b72d6bf66bbaa659f4d903fe7';

/// See also [tasksGrouped].
@ProviderFor(tasksGrouped)
final tasksGroupedProvider =
    AutoDisposeProvider<Map<String?, List<Task>>>.internal(
  tasksGrouped,
  name: r'tasksGroupedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tasksGroupedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksGroupedRef = AutoDisposeProviderRef<Map<String?, List<Task>>>;
String _$pendingTasksForMemberHash() =>
    r'56d26e6b5922e27299b5e9d3458af720343d1e7c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [pendingTasksForMember].
@ProviderFor(pendingTasksForMember)
const pendingTasksForMemberProvider = PendingTasksForMemberFamily();

/// See also [pendingTasksForMember].
class PendingTasksForMemberFamily extends Family<List<Task>> {
  /// See also [pendingTasksForMember].
  const PendingTasksForMemberFamily();

  /// See also [pendingTasksForMember].
  PendingTasksForMemberProvider call(
    String userId,
  ) {
    return PendingTasksForMemberProvider(
      userId,
    );
  }

  @override
  PendingTasksForMemberProvider getProviderOverride(
    covariant PendingTasksForMemberProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pendingTasksForMemberProvider';
}

/// See also [pendingTasksForMember].
class PendingTasksForMemberProvider extends AutoDisposeProvider<List<Task>> {
  /// See also [pendingTasksForMember].
  PendingTasksForMemberProvider(
    String userId,
  ) : this._internal(
          (ref) => pendingTasksForMember(
            ref as PendingTasksForMemberRef,
            userId,
          ),
          from: pendingTasksForMemberProvider,
          name: r'pendingTasksForMemberProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pendingTasksForMemberHash,
          dependencies: PendingTasksForMemberFamily._dependencies,
          allTransitiveDependencies:
              PendingTasksForMemberFamily._allTransitiveDependencies,
          userId: userId,
        );

  PendingTasksForMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    List<Task> Function(PendingTasksForMemberRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PendingTasksForMemberProvider._internal(
        (ref) => create(ref as PendingTasksForMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Task>> createElement() {
    return _PendingTasksForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingTasksForMemberProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PendingTasksForMemberRef on AutoDisposeProviderRef<List<Task>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _PendingTasksForMemberProviderElement
    extends AutoDisposeProviderElement<List<Task>>
    with PendingTasksForMemberRef {
  _PendingTasksForMemberProviderElement(super.provider);

  @override
  String get userId => (origin as PendingTasksForMemberProvider).userId;
}

String _$streakForMemberHash() => r'31b101d8aa86297988052fce1f63c21f7c155eac';

/// See also [streakForMember].
@ProviderFor(streakForMember)
const streakForMemberProvider = StreakForMemberFamily();

/// See also [streakForMember].
class StreakForMemberFamily extends Family<int> {
  /// See also [streakForMember].
  const StreakForMemberFamily();

  /// See also [streakForMember].
  StreakForMemberProvider call(
    String userId,
  ) {
    return StreakForMemberProvider(
      userId,
    );
  }

  @override
  StreakForMemberProvider getProviderOverride(
    covariant StreakForMemberProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'streakForMemberProvider';
}

/// See also [streakForMember].
class StreakForMemberProvider extends AutoDisposeProvider<int> {
  /// See also [streakForMember].
  StreakForMemberProvider(
    String userId,
  ) : this._internal(
          (ref) => streakForMember(
            ref as StreakForMemberRef,
            userId,
          ),
          from: streakForMemberProvider,
          name: r'streakForMemberProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$streakForMemberHash,
          dependencies: StreakForMemberFamily._dependencies,
          allTransitiveDependencies:
              StreakForMemberFamily._allTransitiveDependencies,
          userId: userId,
        );

  StreakForMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    int Function(StreakForMemberRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StreakForMemberProvider._internal(
        (ref) => create(ref as StreakForMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _StreakForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StreakForMemberProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StreakForMemberRef on AutoDisposeProviderRef<int> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _StreakForMemberProviderElement extends AutoDisposeProviderElement<int>
    with StreakForMemberRef {
  _StreakForMemberProviderElement(super.provider);

  @override
  String get userId => (origin as StreakForMemberProvider).userId;
}

String _$taskActionsHash() => r'e2329d1bbfa6a16cae9f357c937922a028d60840';

/// See also [TaskActions].
@ProviderFor(TaskActions)
final taskActionsProvider =
    AutoDisposeNotifierProvider<TaskActions, AsyncValue<void>>.internal(
  TaskActions.new,
  name: r'taskActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
