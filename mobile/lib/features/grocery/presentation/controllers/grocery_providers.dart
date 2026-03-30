import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../data/datasources/local/grocery_local_datasource.dart';
import '../../data/datasources/remote/grocery_remote_datasource.dart';
import '../../data/repositories/grocery_repository_impl.dart';
import '../../domain/entities/grocery_item.dart';
import '../../domain/repositories/grocery_repository.dart';

part 'grocery_providers.g.dart';

@riverpod
GroceryRemoteDatasource groceryRemoteDatasource(Ref ref) {
  return GroceryRemoteDatasource(ref.watch(supabaseClientProvider));
}

@riverpod
Future<GroceryLocalDatasource> groceryLocalDatasource(Ref ref) async {
  return GroceryLocalDatasource.getInstance();
}

@riverpod
Future<GroceryRepository> groceryRepository(Ref ref) async {
  final local = await ref.watch(groceryLocalDatasourceProvider.future);
  final remote = ref.watch(groceryRemoteDatasourceProvider);
  return GroceryRepositoryImpl(local: local, remote: remote);
}

@riverpod
Stream<List<GroceryItem>> groceryItems(Ref ref) async* {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) {
    yield [];
    return;
  }

  final repo = await ref.watch(groceryRepositoryProvider.future);

  // Kick off a background sync on first load.
  unawaited(repo.syncFromRemote(householdId));

  yield* repo.watchItems(householdId);
}

// Items grouped by category — null category goes last as "Other"
@riverpod
Map<String, List<GroceryItem>> groceryItemsByCategory(Ref ref) {
  final items = ref.watch(groceryItemsProvider).valueOrNull ?? [];
  final map = <String, List<GroceryItem>>{};
  for (final item in items) {
    final key = item.category?.trim().isNotEmpty == true
        ? item.category!
        : 'Other';
    (map[key] ??= []).add(item);
  }
  // Sort: named categories alphabetically, "Other" always last
  final sorted = Map.fromEntries(
    map.entries.toList()
      ..sort((a, b) {
        if (a.key == 'Other') return 1;
        if (b.key == 'Other') return -1;
        return a.key.compareTo(b.key);
      }),
  );
  return sorted;
}

@riverpod
int uncheckedCount(Ref ref) {
  final items = ref.watch(groceryItemsProvider).valueOrNull ?? [];
  return items.where((i) => !i.checked).length;
}

@riverpod
class GroceryActions extends _$GroceryActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> addItem({
    required String name,
    String? quantity,
    String? category,
  }) async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(groceryRepositoryProvider.future);
      await repo.addItem(
        householdId: householdId,
        name: name,
        quantity: quantity,
        category: category,
      );
    });
    return !state.hasError;
  }

  Future<void> toggleCheck(String id, bool checked) async {
    final repo = await ref.read(groceryRepositoryProvider.future);
    await repo.toggleCheck(id, checked);
  }

  Future<void> deleteItem(String id) async {
    final repo = await ref.read(groceryRepositoryProvider.future);
    await repo.deleteItem(id);
  }

  Future<bool> clearChecked() async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(groceryRepositoryProvider.future);
      await repo.clearChecked(householdId);
    });
    return !state.hasError;
  }
}
