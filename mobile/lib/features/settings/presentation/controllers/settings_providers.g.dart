// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isProUserHash() => r'd6cd277f051df51d56d00b11584da4b4a192c4f7';

/// See also [isProUser].
@ProviderFor(isProUser)
final isProUserProvider = AutoDisposeFutureProvider<bool>.internal(
  isProUser,
  name: r'isProUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isProUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsProUserRef = AutoDisposeFutureProviderRef<bool>;
String _$themeModeNotifierHash() => r'2c9e3987c2ec07cbbd408bb4a652720ae512248a';

/// See also [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
  ThemeModeNotifier.new,
  name: r'themeModeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeModeNotifier = AutoDisposeNotifier<ThemeMode>;
String _$profileActionsHash() => r'd667ffd19f4719ef4f51146341dc6aa2ec012b1f';

/// See also [ProfileActions].
@ProviderFor(ProfileActions)
final profileActionsProvider =
    AutoDisposeNotifierProvider<ProfileActions, AsyncValue<void>>.internal(
  ProfileActions.new,
  name: r'profileActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileActions = AutoDisposeNotifier<AsyncValue<void>>;
String _$householdActionsHash() => r'2c48d29f182ef36ed3a309a2231b0df42c01737d';

/// See also [HouseholdActions].
@ProviderFor(HouseholdActions)
final householdActionsProvider =
    AutoDisposeNotifierProvider<HouseholdActions, AsyncValue<void>>.internal(
  HouseholdActions.new,
  name: r'householdActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$householdActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HouseholdActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
