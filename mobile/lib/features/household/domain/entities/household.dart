import 'package:freezed_annotation/freezed_annotation.dart';

part 'household.freezed.dart';

@freezed
class Household with _$Household {
  const factory Household({
    required String id,
    required String name,
    String? avatarEmoji,
    required String inviteCode,
    required String createdBy,
    required DateTime createdAt,
  }) = _Household;
}
