import 'package:isar/isar.dart';

import '../../domain/entities/grocery_item.dart';

part 'grocery_item_local.g.dart';

@collection
class GroceryItemLocal {
  GroceryItemLocal({
    required this.id,
    required this.householdId,
    required this.name,
    this.quantity,
    this.category,
    required this.checked,
    required this.addedBy,
    this.checkedBy,
    required this.createdAtMs,
  });

  Id get isarId => fastHash(id);

  final String id;
  final String householdId;
  final String name;
  final String? quantity;
  final String? category;
  final bool checked;
  final String addedBy;
  final String? checkedBy;
  final int createdAtMs;

  GroceryItem toDomain() => GroceryItem(
        id: id,
        householdId: householdId,
        name: name,
        quantity: quantity,
        category: category,
        checked: checked,
        addedBy: addedBy,
        checkedBy: checkedBy,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      );

  static GroceryItemLocal fromDomain(GroceryItem item) => GroceryItemLocal(
        id: item.id,
        householdId: item.householdId,
        name: item.name,
        quantity: item.quantity,
        category: item.category,
        checked: item.checked,
        addedBy: item.addedBy,
        checkedBy: item.checkedBy,
        createdAtMs: item.createdAt.millisecondsSinceEpoch,
      );
}

/// FNV-1a 64-bit hash — stable deterministic int ID from a UUID string.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  for (final byte in string.codeUnits) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash;
}
