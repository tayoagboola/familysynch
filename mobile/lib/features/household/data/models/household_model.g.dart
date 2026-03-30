// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HouseholdModelImpl _$$HouseholdModelImplFromJson(Map<String, dynamic> json) =>
    _$HouseholdModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarEmoji: json['avatar_emoji'] as String?,
      inviteCode: json['invite_code'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$HouseholdModelImplToJson(
        _$HouseholdModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar_emoji': instance.avatarEmoji,
      'invite_code': instance.inviteCode,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
    };
