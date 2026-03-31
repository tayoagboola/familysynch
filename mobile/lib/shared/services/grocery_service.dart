/// GroceryService — item CRUD + offline sync + WebSocket real-time stream.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';
import 'package:familysynch/shared/services/ws_client.dart';

final groceryServiceProvider = Provider<GroceryService>((ref) {
  return GroceryService(ref.read(apiClientProvider), ref.read(wsClientProvider));
});

class GroceryService {
  final ApiClient _api;
  final WsClient _ws;
  GroceryService(this._api, this._ws);

  // ── REST ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getItems({
    String? category,
    bool? isChecked,
  }) =>
      _api.get('/grocery', queryParameters: {
        if (category != null) 'category': category,
        if (isChecked != null) 'is_checked': isChecked,
      });

  Future<Map<String, dynamic>> addItem(Map<String, dynamic> body) =>
      _api.post('/grocery', body: body);

  Future<Map<String, dynamic>> updateItem(
          String itemId, Map<String, dynamic> body) =>
      _api.put('/grocery/$itemId', body: body);

  Future<Map<String, dynamic>> toggleItem(String itemId) =>
      _api.post('/grocery/$itemId/toggle');

  Future<Map<String, dynamic>> clearChecked() =>
      _api.delete('/grocery/checked');

  Future<void> deleteItem(String itemId) => _api.delete('/grocery/$itemId');

  Future<Map<String, dynamic>> batchSync(List<Map<String, dynamic>> items) =>
      _api.post('/grocery/sync', body: {'items': items});

  // ── WebSocket ──────────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> watchItems() => _ws.connect('/ws/grocery');
}
