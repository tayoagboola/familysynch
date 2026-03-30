import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/feed_post.dart';

part 'feed_post_model.g.dart';

@JsonSerializable()
class FeedPostModel {
  const FeedPostModel({
    required this.id,
    required this.householdId,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.createdAt,
  });

  final String id;
  @JsonKey(name: 'household_id')
  final String householdId;
  final String content;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'author_id')
  final String authorId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory FeedPostModel.fromJson(Map<String, dynamic> json) =>
      _$FeedPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$FeedPostModelToJson(this);

  FeedPost toDomain() => FeedPost(
        id: id,
        householdId: householdId,
        content: content,
        imageUrl: imageUrl,
        authorId: authorId,
        createdAt: createdAt,
      );
}
