import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/grocery_item_model.dart';

class GroceryRemoteDatasource {
  GroceryRemoteDatasource(this._client);

  final SupabaseClient _client;
  final _uuid = const Uuid();

  Stream<List<GroceryItemModel>> watchItems(String householdId) {
    return _client
        .from('grocery_items')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('category')
        .map((rows) => rows.map(GroceryItemModel.fromJson).toList());
  }

  Future<List<GroceryItemModel>> fetchItems(String householdId) async {
    final rows = await _client
        .from('grocery_items')
        .select()
        .eq('household_id', householdId)
        .order('category');
    return rows.map(GroceryItemModel.fromJson).toList();
  }

  Future<GroceryItemModel> addItem({
    required String householdId,
    required String name,
    String? quantity,
    String? category,
  }) async {
    final data = await _client.from('grocery_items').insert({
      'id': _uuid.v4(),
      'household_id': householdId,
      'name': name,
      'quantity': quantity,
      'category': category,
      'checked': false,
      'added_by': _client.auth.currentUser!.id,
    }).select().single();
    return GroceryItemModel.fromJson(data);
  }

  Future<void> toggleCheck(String id, bool checked) async {
    await _client.from('grocery_items').update({
      'checked': checked,
      'checked_by':
          checked ? _client.auth.currentUser!.id : null,
    }).eq('id', id);
  }

  Future<void> deleteItem(String id) async {
    await _client.from('grocery_items').delete().eq('id', id);
  }

  Future<void> clearChecked(String householdId) async {
    await _client
        .from('grocery_items')
        .delete()
        .eq('household_id', householdId)
        .eq('checked', true);
  }
}
