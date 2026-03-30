import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/household_member.dart';

part 'household_member_model.freezed.dart';
part 'household_member_model.g.dart';

@freezed
class HouseholdMemberModel with _$HouseholdMemberModel {
  const factory HouseholdMemberModel({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    required String color,
    required String role,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
    @JsonKey(name: 'fcm_token') String? fcmToken,
  }) = _HouseholdMemberModel;

  factory HouseholdMemberModel.fromJson(Map<String, dynamic> json) =>
      _$HouseholdMemberModelFromJson(json);
}

extension HouseholdMemberModelX on HouseholdMemberModel {
  HouseholdMember toDomain() => HouseholdMember(
        id: id,
        householdId: householdId,
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        color: color,
        role: role,
        joinedAt: joinedAt,
      );
}
