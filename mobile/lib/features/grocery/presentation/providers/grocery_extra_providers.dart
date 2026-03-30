import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/grocery_item.dart';
import '../controllers/grocery_providers.dart';

// ── GroceryCategory model ─────────────────────────────────────────────────────

class GroceryCategory {
  const GroceryCategory({
    required this.key,
    required this.label,
    required this.emoji,
  });

  final String key;
  final String label;
  final String emoji;

  static GroceryCategory fromString(String? key) {
    return switch (key?.toLowerCase()) {
      'dairy' => const GroceryCategory(
          key: 'dairy', label: 'Dairy', emoji: '🥛'),
      'produce' => const GroceryCategory(
          key: 'produce', label: 'Produce', emoji: '🥦'),
      'meat' => const GroceryCategory(
          key: 'meat', label: 'Meat', emoji: '🥩'),
      'care' => const GroceryCategory(
          key: 'care', label: 'Care', emoji: '🧴'),
      _ => GroceryCategory(
          key: key ?? 'other', label: 'Other', emoji: '🛒'),
    };
  }
}

// ── Category inference ────────────────────────────────────────────────────────

String inferGroceryCategory(String name) {
  final lower = name.toLowerCase();
  if (['milk', 'cheese', 'yogurt', 'butter', 'cream']
      .any((k) => lower.contains(k))) { return 'dairy'; }
  if (['apple', 'banana', 'spinach', 'tomato', 'lettuce', 'carrot',
        'orange', 'grape', 'berry', 'fruit', 'vegetable']
      .any((k) => lower.contains(k))) { return 'produce'; }
  if (['chicken', 'beef', 'fish', 'pork', 'steak', 'ground', 'turkey', 'lamb']
      .any((k) => lower.contains(k))) { return 'meat'; }
  if (['shampoo', 'soap', 'toothpaste', 'towel', 'tissue', 'deodorant',
        'lotion', 'detergent']
      .any((k) => lower.contains(k))) { return 'care'; }
  return 'other';
}

// ── Category filter ───────────────────────────────────────────────────────────

// null = All categories
final selectedGroceryCategoryProvider = StateProvider<String?>((ref) => null);

// ── Filtered items ────────────────────────────────────────────────────────────

final filteredGroceryItemsProvider = Provider<List<GroceryItem>>((ref) {
  final items = ref.watch(groceryItemsProvider).valueOrNull ?? [];
  final category = ref.watch(selectedGroceryCategoryProvider);
  if (category == null) return items;
  return items.where((i) => (i.category ?? 'other') == category).toList();
});

// ── Filtered + grouped ────────────────────────────────────────────────────────

final filteredGroupedGroceryProvider =
    Provider<Map<String, List<GroceryItem>>>((ref) {
  final items = ref.watch(filteredGroceryItemsProvider);
  final map = <String, List<GroceryItem>>{};
  for (final item in items) {
    final key = item.category?.trim().isNotEmpty == true
        ? item.category!
        : 'other';
    (map[key] ??= []).add(item);
  }
  // Sort: named categories in spec order, "other" last
  const order = ['dairy', 'produce', 'meat', 'care'];
  final sorted = <String, List<GroceryItem>>{};
  for (final k in order) {
    if (map.containsKey(k)) sorted[k] = map[k]!;
  }
  for (final entry in map.entries) {
    if (!sorted.containsKey(entry.key)) sorted[entry.key] = entry.value;
  }
  return sorted;
});

// ── Progress ──────────────────────────────────────────────────────────────────

final groceryProgressProvider =
    Provider<({int checked, int total})>((ref) {
  final items = ref.watch(groceryItemsProvider).valueOrNull ?? [];
  return (
    checked: items.where((i) => i.checked).length,
    total: items.length,
  );
});

// ── Available categories ──────────────────────────────────────────────────────

final groceryCategoriesProvider =
    Provider<List<GroceryCategory>>((ref) {
  final items = ref.watch(groceryItemsProvider).valueOrNull ?? [];
  final keys = items
      .map((i) => i.category?.trim().isNotEmpty == true ? i.category! : 'other')
      .toSet();
  const order = ['dairy', 'produce', 'meat', 'care'];
  final sorted = [
    ...order.where((k) => keys.contains(k)),
    ...keys.where((k) => !order.contains(k)),
  ];
  return sorted.map(GroceryCategory.fromString).toList();
});
