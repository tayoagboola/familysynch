import 'package:freezed_annotation/freezed_annotation.dart';

part 'household_member.freezed.dart';

@freezed
class HouseholdMember with _$HouseholdMember {
  const factory HouseholdMember({
    required String id,
    required String householdId,
    required String userId,
    required String displayName,
    String? avatarUrl,
    required String color,
    required String role, // 'adult' | 'child'
    required DateTime joinedAt,
  }) = _HouseholdMember;
}
