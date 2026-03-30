import '../../domain/entities/feed_post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/remote/feed_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._datasource);

  final FeedRemoteDatasource _datasource;

  @override
  Stream<List<FeedPost>> watchPosts(String householdId) {
    return _datasource
        .watchPosts(householdId)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Future<void> createPost({
    required String householdId,
    required String content,
    String? imageUrl,
  }) =>
      _datasource.createPost(
          householdId: householdId, content: content, imageUrl: imageUrl);

  @override
  Future<void> deletePost(String id) => _datasource.deletePost(id);
}
