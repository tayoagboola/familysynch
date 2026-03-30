import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/grocery_item_local.dart';

class GroceryLocalDatasource {
  GroceryLocalDatasource._();

  static GroceryLocalDatasource? _instance;
  static Isar? _isar;

  static Future<GroceryLocalDatasource> getInstance() async {
    _instance ??= GroceryLocalDatasource._();
    if (_isar == null || !_isar!.isOpen) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [GroceryItemLocalSchema],
        directory: dir.path,
      );
    }
    return _instance!;
  }

  Isar get _db => _isar!;

  Stream<List<GroceryItemLocal>> watchItems(String householdId) {
    return _db.groceryItemLocals
        .filter()
        .householdIdEqualTo(householdId)
        .sortByCategory()
        .thenByName()
        .watch(fireImmediately: true);
  }

  Future<List<GroceryItemLocal>> getItems(String householdId) {
    return _db.groceryItemLocals
        .filter()
        .householdIdEqualTo(householdId)
        .sortByCategory()
        .thenByName()
        .findAll();
  }

  Future<void> putItem(GroceryItemLocal item) async {
    await _db.writeTxn(() => _db.groceryItemLocals.put(item));
  }

  Future<void> putAll(List<GroceryItemLocal> items) async {
    await _db.writeTxn(() => _db.groceryItemLocals.putAll(items));
  }

  Future<void> deleteItem(String id) async {
    await _db.writeTxn(
        () => _db.groceryItemLocals.delete(fastHash(id)));
  }

  Future<void> deleteChecked(String householdId) async {
    final checked = await _db.groceryItemLocals
        .filter()
        .householdIdEqualTo(householdId)
        .checkedEqualTo(true)
        .findAll();
    final ids = checked.map((e) => e.isarId).toList();
    await _db.writeTxn(() => _db.groceryItemLocals.deleteAll(ids));
  }

  Future<void> replaceAll(
      String householdId, List<GroceryItemLocal> items) async {
    await _db.writeTxn(() async {
      // Remove all items for this household then insert fresh
      final existing = await _db.groceryItemLocals
          .filter()
          .householdIdEqualTo(householdId)
          .findAll();
      await _db.groceryItemLocals
          .deleteAll(existing.map((e) => e.isarId).toList());
      await _db.groceryItemLocals.putAll(items);
    });
  }
}
