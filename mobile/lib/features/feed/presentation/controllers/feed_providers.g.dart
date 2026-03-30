// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedRemoteDatasourceHash() =>
    r'f401d8a6099770b8565bc8c3dca3ecd0079a1fa2';

/// See also [feedRemoteDatasource].
@ProviderFor(feedRemoteDatasource)
final feedRemoteDatasourceProvider =
    AutoDisposeProvider<FeedRemoteDatasource>.internal(
  feedRemoteDatasource,
  name: r'feedRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedRemoteDatasourceRef = AutoDisposeProviderRef<FeedRemoteDatasource>;
String _$feedRepositoryHash() => r'01c75dbf15ff0a430928cf5a092e0487113c5f25';

/// See also [feedRepository].
@ProviderFor(feedRepository)
final feedRepositoryProvider = AutoDisposeProvider<FeedRepository>.internal(
  feedRepository,
  name: r'feedRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedRepositoryRef = AutoDisposeProviderRef<FeedRepository>;
String _$feedPostsHash() => r'80baf9d28660b88584b948af2041f6e94d2b048b';

/// See also [feedPosts].
@ProviderFor(feedPosts)
final feedPostsProvider = AutoDisposeStreamProvider<List<FeedPost>>.internal(
  feedPosts,
  name: r'feedPostsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$feedPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedPostsRef = AutoDisposeStreamProviderRef<List<FeedPost>>;
String _$feedActionsHash() => r'ca6f41ce5a1afdf5c98a77a7b9abf47f75ef07a3';

/// See also [FeedActions].
@ProviderFor(FeedActions)
final feedActionsProvider =
    AutoDisposeNotifierProvider<FeedActions, AsyncValue<void>>.internal(
  FeedActions.new,
  name: r'feedActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$feedActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FeedActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
