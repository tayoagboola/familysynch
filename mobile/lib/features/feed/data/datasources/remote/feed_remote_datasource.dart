import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/feed_post_model.dart';

class FeedRemoteDatasource {
  FeedRemoteDatasource(this._client);

  final SupabaseClient _client;

  Stream<List<FeedPostModel>> watchPosts(String householdId) {
    return _client
        .from('feed_posts')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(FeedPostModel.fromJson).toList());
  }

  Future<void> createPost({
    required String householdId,
    required String content,
    String? imageUrl,
  }) async {
    await _client.from('feed_posts').insert({
      'household_id': householdId,
      'content': content,
      'image_url': imageUrl,
      'author_id': _client.auth.currentUser!.id,
    });
  }

  Future<void> deletePost(String id) async {
    await _client.from('feed_posts').delete().eq('id', id);
  }
}
