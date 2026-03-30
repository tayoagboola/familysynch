import '../entities/grocery_item.dart';

abstract class GroceryRepository {
  Stream<List<GroceryItem>> watchItems(String householdId);

  Future<void> addItem({
    required String householdId,
    required String name,
    String? quantity,
    String? category,
  });

  Future<void> toggleCheck(String id, bool checked);

  Future<void> deleteItem(String id);

  Future<void> clearChecked(String householdId);

  /// Pull latest from Supabase and write to local cache.
  Future<void> syncFromRemote(String householdId);
}
