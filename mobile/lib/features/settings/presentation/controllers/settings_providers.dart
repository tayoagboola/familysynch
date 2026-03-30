import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/supabase_provider.dart';
import '../../../../shared/services/revenue_cat_service.dart';

part 'settings_providers.g.dart';

// ── Theme ──────────────────────────────────────────────────────────────────

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

// ── Pro status ─────────────────────────────────────────────────────────────

@riverpod
Future<bool> isProUser(Ref ref) async {
  return RevenueCatService.instance.isPro();
}

// ── Profile update ─────────────────────────────────────────────────────────

@riverpod
class ProfileActions extends _$ProfileActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> updateDisplayName(String name) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => client
        .from('household_members')
        .update({'display_name': name})
        .eq('user_id', userId));
    return !state.hasError;
  }

  Future<bool> updateAvatarUrl(String url) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => client
        .from('household_members')
        .update({'avatar_url': url})
        .eq('user_id', userId));
    return !state.hasError;
  }
}

// ── Household rename ───────────────────────────────────────────────────────

@riverpod
class HouseholdActions extends _$HouseholdActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> renameHousehold(String householdId, String name) async {
    final client = ref.read(supabaseClientProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => client
        .from('households')
        .update({'name': name})
        .eq('id', householdId));
    return !state.hasError;
  }

  Future<bool> removeMember(String memberId) async {
    final client = ref.read(supabaseClientProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => client
        .from('household_members')
        .delete()
        .eq('id', memberId));
    return !state.hasError;
  }
}
