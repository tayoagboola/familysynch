// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HouseholdMemberModelImpl _$$HouseholdMemberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$HouseholdMemberModelImpl(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      color: json['color'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      fcmToken: json['fcm_token'] as String?,
    );

Map<String, dynamic> _$$HouseholdMemberModelImplToJson(
        _$HouseholdMemberModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'user_id': instance.userId,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'color': instance.color,
      'role': instance.role,
      'joined_at': instance.joinedAt.toIso8601String(),
      'fcm_token': instance.fcmToken,
    };
