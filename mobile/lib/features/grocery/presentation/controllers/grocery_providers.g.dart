// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groceryRemoteDatasourceHash() =>
    r'2de83b7b01aaad084ff152125a288e418f843395';

/// See also [groceryRemoteDatasource].
@ProviderFor(groceryRemoteDatasource)
final groceryRemoteDatasourceProvider =
    AutoDisposeProvider<GroceryRemoteDatasource>.internal(
  groceryRemoteDatasource,
  name: r'groceryRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groceryRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryRemoteDatasourceRef
    = AutoDisposeProviderRef<GroceryRemoteDatasource>;
String _$groceryLocalDatasourceHash() =>
    r'ab90a9fdc4fe42c7248823967fd9bead852f72bc';

/// See also [groceryLocalDatasource].
@ProviderFor(groceryLocalDatasource)
final groceryLocalDatasourceProvider =
    AutoDisposeFutureProvider<GroceryLocalDatasource>.internal(
  groceryLocalDatasource,
  name: r'groceryLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groceryLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryLocalDatasourceRef
    = AutoDisposeFutureProviderRef<GroceryLocalDatasource>;
String _$groceryRepositoryHash() => r'1223fbf302de8e8c5beb607ba8dde7ae4664aa7e';

/// See also [groceryRepository].
@ProviderFor(groceryRepository)
final groceryRepositoryProvider =
    AutoDisposeFutureProvider<GroceryRepository>.internal(
  groceryRepository,
  name: r'groceryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groceryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryRepositoryRef = AutoDisposeFutureProviderRef<GroceryRepository>;
String _$groceryItemsHash() => r'4139c32bbc487a012d366c4f7ee5f7eac1e3b946';

/// See also [groceryItems].
@ProviderFor(groceryItems)
final groceryItemsProvider =
    AutoDisposeStreamProvider<List<GroceryItem>>.internal(
  groceryItems,
  name: r'groceryItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$groceryItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryItemsRef = AutoDisposeStreamProviderRef<List<GroceryItem>>;
String _$groceryItemsByCategoryHash() =>
    r'05e44d85b47f8384a994c8583ab668aa0daf4a9e';

/// See also [groceryItemsByCategory].
@ProviderFor(groceryItemsByCategory)
final groceryItemsByCategoryProvider =
    AutoDisposeProvider<Map<String, List<GroceryItem>>>.internal(
  groceryItemsByCategory,
  name: r'groceryItemsByCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groceryItemsByCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryItemsByCategoryRef
    = AutoDisposeProviderRef<Map<String, List<GroceryItem>>>;
String _$uncheckedCountHash() => r'ac58cd34d86426e1277ded54c409787a65a1de20';

/// See also [uncheckedCount].
@ProviderFor(uncheckedCount)
final uncheckedCountProvider = AutoDisposeProvider<int>.internal(
  uncheckedCount,
  name: r'uncheckedCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uncheckedCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UncheckedCountRef = AutoDisposeProviderRef<int>;
String _$groceryActionsHash() => r'd3f72177073e3b063e39b02c9b0669bf956f0c8d';

/// See also [GroceryActions].
@ProviderFor(GroceryActions)
final groceryActionsProvider =
    AutoDisposeNotifierProvider<GroceryActions, AsyncValue<void>>.internal(
  GroceryActions.new,
  name: r'groceryActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groceryActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GroceryActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
