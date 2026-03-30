// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedPostModel _$FeedPostModelFromJson(Map<String, dynamic> json) =>
    FeedPostModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      authorId: json['author_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$FeedPostModelToJson(FeedPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'content': instance.content,
      'image_url': instance.imageUrl,
      'author_id': instance.authorId,
      'created_at': instance.createdAt.toIso8601String(),
    };
