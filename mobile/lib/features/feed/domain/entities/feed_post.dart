import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_post.freezed.dart';

@freezed
class FeedPost with _$FeedPost {
  const factory FeedPost({
    required String id,
    required String householdId,
    required String content,
    String? imageUrl,
    required String authorId,
    required DateTime createdAt,
  }) = _FeedPost;
}
