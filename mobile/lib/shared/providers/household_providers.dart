import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_notifier.dart';
import '../../features/household/data/models/household_member_model.dart';
import '../../features/household/data/repositories/household_repository_impl.dart';
import '../../features/household/domain/entities/household_member.dart';
import 'supabase_provider.dart';

part 'household_providers.g.dart';

@riverpod
HouseholdRepository householdRepository(HouseholdRepositoryRef ref) {
  return HouseholdRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<HouseholdMember?> currentHouseholdMember(
    CurrentHouseholdMemberRef ref) async {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null) return null;

  final data = await ref
      .watch(supabaseClientProvider)
      .from('household_members')
      .select()
      .eq('user_id', user.id)
      .limit(1)
      .maybeSingle();

  if (data == null) return null;
  return HouseholdMemberModel.fromJson(data).toDomain();
}

@riverpod
String? currentHouseholdId(CurrentHouseholdIdRef ref) {
  return ref.watch(currentHouseholdMemberProvider).valueOrNull?.householdId;
}

@riverpod
Stream<List<HouseholdMember>> householdMembers(HouseholdMembersRef ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();

  return ref
      .watch(supabaseClientProvider)
      .from('household_members')
      .stream(primaryKey: ['id'])
      .eq('household_id', householdId)
      .map((rows) =>
          rows.map((r) => HouseholdMemberModel.fromJson(r).toDomain()).toList());
}

@riverpod
Map<String, HouseholdMember> householdMembersMap(
    HouseholdMembersMapRef ref) {
  final members = ref.watch(householdMembersProvider).valueOrNull ?? [];
  return {for (final m in members) m.userId: m};
}
