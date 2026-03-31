/// FeedService — post CRUD + reactions + WebSocket real-time stream.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';
import 'package:familysynch/shared/services/ws_client.dart';

final feedServiceProvider = Provider<FeedService>((ref) {
  return FeedService(ref.read(apiClientProvider), ref.read(wsClientProvider));
});

class FeedService {
  final ApiClient _api;
  final WsClient _ws;
  FeedService(this._api, this._ws);

  // ── REST ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getFeed({
    String? type,
    String? cursor,
    int limit = 20,
  }) =>
      _api.get('/feed', queryParameters: {
        if (type != null) 'type': type,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      });

  Future<Map<String, dynamic>> createPost(Map<String, dynamic> body) =>
      _api.post('/feed', body: body);

  Future<void> deletePost(String postId) => _api.delete('/feed/$postId');

  Future<Map<String, dynamic>> toggleReaction(String postId, String emoji) =>
      _api.post('/feed/$postId/react', body: {'emoji': emoji});

  // ── WebSocket ──────────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> watchFeed() => _ws.connect('/ws/feed');

  Stream<Map<String, dynamic>> watchPresence() =>
      _ws.connect('/ws/presence');
}
