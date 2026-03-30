import '../entities/feed_post.dart';

abstract class FeedRepository {
  Stream<List<FeedPost>> watchPosts(String householdId);

  Future<void> createPost({
    required String householdId,
    required String content,
    String? imageUrl,
  });

  Future<void> deletePost(String id);
}
