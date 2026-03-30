import '../../domain/entities/grocery_item.dart';
import '../../domain/repositories/grocery_repository.dart';
import '../datasources/local/grocery_local_datasource.dart';
import '../datasources/remote/grocery_remote_datasource.dart';
import '../models/grocery_item_local.dart';

class GroceryRepositoryImpl implements GroceryRepository {
  GroceryRepositoryImpl({
    required this.local,
    required this.remote,
  });

  final GroceryLocalDatasource local;
  final GroceryRemoteDatasource remote;

  /// Isar is the source of truth — UI watches this stream.
  @override
  Stream<List<GroceryItem>> watchItems(String householdId) {
    return local
        .watchItems(householdId)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<void> addItem({
    required String householdId,
    required String name,
    String? quantity,
    String? category,
  }) async {
    // Write to Supabase first to get the server-assigned id, then cache locally.
    final model = await remote.addItem(
      householdId: householdId,
      name: name,
      quantity: quantity,
      category: category,
    );
    await local.putItem(GroceryItemLocal.fromDomain(model.toDomain()));
  }

  @override
  Future<void> toggleCheck(String id, bool checked) async {
    // Optimistic local update, then sync remote.
    final items = await local.getItems('');
    final existing = items.where((i) => i.id == id).firstOrNull;
    if (existing != null) {
      await local.putItem(GroceryItemLocal(
        id: existing.id,
        householdId: existing.householdId,
        name: existing.name,
        quantity: existing.quantity,
        category: existing.category,
        checked: checked,
        addedBy: existing.addedBy,
        checkedBy: existing.checkedBy,
        createdAtMs: existing.createdAtMs,
      ));
    }
    await remote.toggleCheck(id, checked);
  }

  @override
  Future<void> deleteItem(String id) async {
    await local.deleteItem(id);
    await remote.deleteItem(id);
  }

  @override
  Future<void> clearChecked(String householdId) async {
    await local.deleteChecked(householdId);
    await remote.clearChecked(householdId);
  }

  @override
  Future<void> syncFromRemote(String householdId) async {
    final models = await remote.fetchItems(householdId);
    final locals = models
        .map((m) => GroceryItemLocal.fromDomain(m.toDomain()))
        .toList();
    await local.replaceAll(householdId, locals);
  }
}
