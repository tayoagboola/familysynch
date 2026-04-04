import 'dart:async';

import '../../models/grocery_item_local.dart';

class GroceryLocalDatasource {
  GroceryLocalDatasource._();

  static GroceryLocalDatasource? _instance;
  final Map<String, List<GroceryItemLocal>> _itemsByHousehold = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  static Future<GroceryLocalDatasource> getInstance() async {
    _instance ??= GroceryLocalDatasource._();
    return _instance!;
  }

  Stream<List<GroceryItemLocal>> watchItems(String householdId) async* {
    yield _sortedItems(householdId);
    yield* _changes.stream.map((_) => _sortedItems(householdId));
  }

  Future<List<GroceryItemLocal>> getItems(String householdId) {
    if (householdId.isEmpty) {
      return Future.value(
        _itemsByHousehold.values
            .expand((items) => items)
            .toList(growable: false),
      );
    }
    return Future.value(_sortedItems(householdId));
  }

  Future<void> putItem(GroceryItemLocal item) async {
    final items = _itemsByHousehold.putIfAbsent(
      item.householdId,
      () => <GroceryItemLocal>[],
    );
    final index = items.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    _emitChange();
  }

  Future<void> putAll(List<GroceryItemLocal> items) async {
    for (final item in items) {
      await putItem(item);
    }
  }

  Future<void> deleteItem(String id) async {
    var changed = false;
    for (final items in _itemsByHousehold.values) {
      final originalLength = items.length;
      items.removeWhere((item) => item.id == id);
      if (items.length != originalLength) {
        changed = true;
      }
    }
    if (changed) {
      _emitChange();
    }
  }

  Future<void> deleteChecked(String householdId) async {
    final items = _itemsByHousehold[householdId];
    if (items == null) return;
    items.removeWhere((item) => item.checked);
    _emitChange();
  }

  Future<void> replaceAll(
    String householdId,
    List<GroceryItemLocal> items,
  ) async {
    _itemsByHousehold[householdId] = List<GroceryItemLocal>.from(items);
    _emitChange();
  }

  List<GroceryItemLocal> _sortedItems(String householdId) {
    final items = List<GroceryItemLocal>.from(
      _itemsByHousehold[householdId] ?? const <GroceryItemLocal>[],
    );
    items.sort((a, b) {
      final categoryCompare = (a.category ?? '').compareTo(b.category ?? '');
      if (categoryCompare != 0) {
        return categoryCompare;
      }
      return a.name.compareTo(b.name);
    });
    return items;
  }

  void _emitChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}
