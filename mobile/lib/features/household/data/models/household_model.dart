import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/household.dart';

part 'household_model.freezed.dart';
part 'household_model.g.dart';

@freezed
class HouseholdModel with _$HouseholdModel {
  const factory HouseholdModel({
    required String id,
    required String name,
    @JsonKey(name: 'avatar_emoji') String? avatarEmoji,
    @JsonKey(name: 'invite_code') required String inviteCode,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _HouseholdModel;

  factory HouseholdModel.fromJson(Map<String, dynamic> json) =>
      _$HouseholdModelFromJson(json);
}

extension HouseholdModelX on HouseholdModel {
  Household toDomain() => Household(
        id: id,
        name: name,
        avatarEmoji: avatarEmoji,
        inviteCode: inviteCode,
        createdBy: createdBy,
        createdAt: createdAt,
      );
}
